[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "", Justification = "Variables are used inside Pester blocks.")]
param(
    $TestValueFile
)
. "$PSScriptRoot\Shared.ps1"

if ([string]::isNullOrEmpty($TestValueFile)) {
    $TestValueFiles = (Get-Childitem -Path "$ModuleBase\Test\resources" -Include "config.test.new.connection.*.json" -Recurse).FullName
}

Foreach ($TestValueFile in $TestValueFiles) {
    $Env:TestValueFile = $TestValueFile
    $TestValues = Get-Content $TestValueFile | ConvertFrom-Json

    Describe ('{0} -Automation Account integration tests' -f (Split-Path $TestValueFile  -Leaf)) -Tags Unit {

        Context "Parameter Invalid - Parameter Set: Default" {
            $TestCases = @(
                @{
                    AutomationAccountName = $TestValues.AutomationAccountName
                    ResourceGroupName     = $TestValues.ResourceGroupName
                    Expected              = 'Environment'
                },
                @{
                    Environment       = $TestValues.Environment
                    ResourceGroupName = $TestValues.ResourceGroupName
                    Expected          = 'AutomationAccountName'
                },
                @{
                    Environment           = $TestValues.Environment
                    AutomationAccountName = $TestValues.AutomationAccountName
                    Expected              = 'ResourceGroupName'
                }
            )
            It "Given <Environment> as Environment, <AutomationAccountName> as AutomationAccountName, and <ResourceGroupName> as ResourceGroupName - should throw an exception containing <Expected>" -TestCases $TestCases {
                param(
                    $Environment,
                    $AutomationAccountName,
                    $ResourceGroupName,
                    $Expected
                )
                {
                    $InputObject = @{
                        Environment           = $Environment
                        AutomationAccountName = $AutomationAccountName
                        ResourceGroupName     = $ResourceGroupName
                    }
                    New-MRAzBdapAutomationAccountConnection @InputObject -WhatIf
                } | Should Throw $Expected
            }
        }
        InModuleScope -ModuleName MRAzBdapAutomationAccount -ScriptBlock {

            $TestValues = Get-Content $Env:TestValueFile | ConvertFrom-Json

            Context "Parameter valid - Parameter Set: Default" {
                ## Add Mock here. Any function that affects external resources or attempts connection to external services should be mocked
                Mock Get-AzADServicePrincipal { return $null } -ModuleName MRAzBdapAutomationAccount

                $TestCases = @(
                    @{
                        Environment           = $TestValues.Environment
                        AutomationAccountName = $TestValues.AutomationAccountName
                        ResourceGroupName     = $TestValues.ResourceGroupName
                    }
                )
                It "Given <Environment> as Environment, <AutomationAccountName> as AutomationAccountName, and <ResourceGroupName> as ResourceGroupName - function should not throw" -TestCases $TestCases {
                    param(
                        $Environment,
                        $AutomationAccountName,
                        $ResourceGroupName
                    )

                    {
                        $InputObject = @{
                            Environment           = $Environment
                            AutomationAccountName = $AutomationAccountName
                            ResourceGroupName     = $ResourceGroupName
                        }
                        New-MRAzBdapAutomationAccountConnection @InputObject -WhatIf
                    } | Should Not Throw
                }

                ## Add Assert-MockCalled here.
            }
        }
    }
}
Foreach ($TestValueFile in $TestValueFiles) {
    $Env:TestValueFile = $TestValueFile

    InModuleScope -ModuleName MRAzBdapAutomationAccount -ScriptBlock {

        $TestValues = Get-Content $Env:TestValueFile | ConvertFrom-Json

        $testDate = (Get-Date -Format FileDateTimeUniversal).TrimEnd('Z')
        $TestValues.Descriptor = ("{0}{1}" -f $TestValues.Descriptor, $testDate.Substring($testDate.Length - 4))

        $InputObjectComponent = @{
            Company     = $TestValues.Company
            Application = $TestValues.Application
            Environment = $TestValues.Environment
            Descriptor  = $TestValues.Descriptor
        }
        $AutomationAccountName = Get-MRAzBdapAutomationAccountName @InputObjectComponent
        Write-Verbose "AutomationAccountName: '$AutomationAccountName'"
        $TestValues.AutomationAccountName = $AutomationAccountName

        $TestDateTime = Get-date -f yyyyMMdd-HHmm
        $Location = 'WestEurope'
        $ResourceGroupName = 'MR-BDAP-TT-' + $TestDateTime
        $ServicePrincipalName = 'autoAccSpIntgTest' + $TestDateTime
        $KeyVaultName = $TestValues.Company.ToLower() + '-' + $TestValues.Application.ToLower() + '-' + $TestValues.Environment.ToLower() + $TestDateTime

        Describe "New-MRAzBdapAutomationAccountConnection integration tests" -Tags Integration, ServicePrincipal {

            BeforeAll {
                # Create test environment
                Write-Verbose 'BeforeAll: Creating test environment...'
                Get-AzResourceGroup -Name $ResourceGroupName -ErrorAction SilentlyContinue | Remove-AzResourceGroup -Force

                Write-Verbose ('Creating resource group "{0}"...' -f $ResourceGroupName)
                $null = New-AzResourceGroup -Name $ResourceGroupName -Location $Location

                # Create Automation Account
                Write-Verbose ('Creating automation account "{0}"...' -f $TestValues.AutomationAccountName)
                Get-AzAutomationAccount | Where-Object { $_.AutomationAccountName -eq $TestValues.AutomationAccountName } | Foreach-Object { Remove-AzAutomationAccount -Name $_.AutomationAccountName -ResourceGroupName $_.ResourceGroupName -Force }
                $AutomationAccount = New-AzAutomationAccount -ResourceGroupName $ResourceGroupName -Name $TestValues.AutomationAccountName -Location $Location

                # Create KeyVault
                Write-Verbose "Creating key vault '$KeyVaultName'..."
                $KeyVault = New-AzKeyVault -Name $KeyVaultName -ResourceGroupName $ResourceGroupName -Location $Location -EnabledForDeployment -EnabledForTemplateDeployment

                # Assign access to keyvault for the current user
                $PermissionsToKeys = @('decrypt', 'encrypt', 'unwrapkey', 'wrapkey', 'verify', 'get', 'list', 'update', 'create', 'delete')
                $PermissionsToSecrets = @('get', 'list', 'set', 'delete')
                $PermissionsToCertificates = @('get', 'list', 'delete', 'create', 'import', 'update')
                $currAzAccount = (Get-AzContext).Account
                If ($currAzAccount.Type -eq "ServicePrincipal") {
                    $currentAzureADUserID = (Get-AzADApplication -ApplicationId $currAzAccount.Id | Get-AzADServicePrincipal).Id
                    $null = Set-AzKeyVaultAccessPolicy -VaultName $KeyVaultName -ResourceGroupName $ResourceGroupName -ObjectId $currentAzureADUserID -PermissionsToKeys $PermissionsToKeys -PermissionsToSecrets $PermissionsToSecrets -PermissionsToCertificates $PermissionsToCertificates
                    Write-Verbose "Enabled key vault access a service principal with object id $currentAzureADUserID"
                }
                else {
                    $null = Set-AzKeyVaultAccessPolicy -VaultName $KeyVaultName -ResourceGroupName $ResourceGroupName -UserPrincipalName $currAzAccount.Id -PermissionsToKeys $PermissionsToKeys -PermissionsToSecrets $PermissionsToSecrets -PermissionsToCertificates $PermissionsToCertificates
                    Write-Verbose ("Enable key vault access to user {0}" -f $currAzAccount.Id)
                }

                # Create service principal
                Write-Verbose "Service Principal: $ServicePrincipalName"
            }
            AfterAll {
                Write-Verbose "AfterAll: Remove test environment..."
                Write-Verbose "Remove ResourceGroup $ResourceGroupName..."
                Get-AzResourceGroup -Name  $ResourceGroupName -Location $Location | Remove-AzResourceGroup -Force
                Write-Verbose "Removing AD service principal and application '$ServicePrincipalName'..."
                $ServicePrincipal = Get-AzAdServicePrincipal -DisplayName $ServicePrincipalName -ErrorAction SilentlyContinue
                if ($ServicePrincipal) {
                    Remove-AzADServicePrincipal -ObjectId $ServicePrincipal.Id -Force -ErrorAction SilentlyContinue
                    $ADApplication = Get-AzADApplication -DisplayName $ServicePrincipalName -ErrorAction SilentlyContinue
                    Remove-AzADApplication -ObjectId $ADApplication.ObjectId -Force -ErrorAction SilentlyContinue
                }
                else {
                    Write-Verbose "Service principal '$ServicePrincipalName' not found"
                }
            }

            Context "New Service Principal" {

                Mock Get-MRAzBdapServicePrincipalName { return $ServicePrincipalName }
                Mock Get-MrAzBdapKvltName { return "$KeyVaultName" }

                It "Should create a connection with Contributor role on the subscription" {

                    $InputObject = @{
                        Environment           = 'tt'
                        AutomationAccountName = $TestValues.AutomationAccountName
                        ResourceGroupName     = $ResourceGroupName
                    }

                    try {
                        New-MRAzBdapAutomationAccountConnection @InputObject -ErrorAction SilentlyContinue | Out-Null
                    }
                    catch [Exception] {
                        Write-Error "$($_.Exception) found"
                        Write-Verbose "$($_.ScriptStackTrace)"
                        throw $_
                    }

                    $Connection = Get-AzAutomationConnection -Name 'AzureRunAsConnection' -ResourceGroupName $ResourceGroupName -AutomationAccountName $TestValues.AutomationAccountName
                    $Script:Thumbprint = $Connection.FieldDefinitionValues['CertificateThumbprint']

                    (!$Connection) | Should Be $false
                    $SubscriptionId = (Get-AzContext).Subscription.SubscriptionId

                    [Array]$RoleAssignement = Get-AzRoleAssignment -Scope "/subscriptions/$SubscriptionId" | Where-Object { $_.DisplayName -eq $ServicePrincipalName }
                    ($RoleAssignement.Count -ge 1) | Should Be $true
                    ($RoleAssignement | Where-Object { $_.RoleDefinitionName -eq 'Contributor' }).Count | Should Be 1
                }

                It "Should add a certificate in the Automation Account certificate store with the same thumbprint as the Connection" {
                    $Certificate = Get-AzAutomationCertificate -Name 'AzureRunAsCertificate' -ResourceGroupName $ResourceGroupName -AutomationAccountName $TestValues.AutomationAccountName

                    $Certificate.Thumbprint | Should Be $Script:Thumbprint
                }
            }

            Context "Existing Service Principal" {

                Mock Get-MRAzBdapServicePrincipalName { return $ServicePrincipalName }
                Mock Get-MrAzBdapKvltName { return "$KeyVaultName" }

                Write-Verbose "Removing certificate and connection..."
                $null = Remove-AzAutomationCertificate -Name 'AzureRunAsCertificate' -ResourceGroupName $ResourceGroupName -AutomationAccountName $TestValues.AutomationAccountName -ErrorAction SilentlyContinue
                $null = Remove-AzAutomationConnection -Name 'AzureRunAsConnection' -ResourceGroupName $ResourceGroupName -AutomationAccountName $TestValues.AutomationAccountName -Force -ErrorAction SilentlyContinue

                It "Should create a connection with Contributor role on the subscription" {

                    Mock Get-MRAzBdapServicePrincipalName { return $ServicePrincipalName }

                    $InputObject = @{
                        Environment           = 'tt'
                        AutomationAccountName = $TestValues.AutomationAccountName
                        ResourceGroupName     = $ResourceGroupName
                    }

                    try {
                        $null = New-MRAzBdapAutomationAccountConnection @InputObject -ErrorAction SilentlyContinue
                    }
                    catch [Exception] {
                        Write-Error "$($_.Exception) found"
                        Write-Verbose "$($_.ScriptStackTrace)"
                        throw $_
                    }

                    $Script:Connection = Get-AzAutomationConnection -Name 'AzureRunAsConnection' -ResourceGroupName $ResourceGroupName -AutomationAccountName $TestValues.AutomationAccountName
                    $Script:Thumbprint = $Connection.FieldDefinitionValues['CertificateThumbprint']

                    (!$Connection) | Should Be $false

                    $SubscriptionId = (Get-AzContext).Subscription.SubscriptionId

                    [Array]$RoleAssignement = Get-AzRoleAssignment -Scope "/subscriptions/$SubscriptionId" | Where-Object { $_.DisplayName -eq $ServicePrincipalName }
                    ($RoleAssignement.Count -ge 1) | Should Be $true
                    ($RoleAssignement | Where-Object { $_.RoleDefinitionName -eq 'Contributor' }).Count | Should Be 1
                }

                It "Should add a certificate in the Automation Account certificate store with the same thumbprint as the Connection" {
                    $Certificate = Get-AzAutomationCertificate -Name 'AzureRunAsCertificate' -ResourceGroupName $ResourceGroupName -AutomationAccountName $TestValues.AutomationAccountName

                    $Certificate.Thumbprint | Should Be $Script:Thumbprint
                }

                It "Automation account service principal should have access to key vaults" {
                    $KeyVaultList = Get-AzKeyVault | Where-Object { $_.VaultName -like ("{0}-{1}-*" -f $TestValues.Company.ToLower(), $TestValues.Application) }
                    $Connection = $Script:Connection
                    $Application = Get-AzADApplication -ApplicationId $Connection.FieldDefinitionValues.ApplicationId

                    $Variables = Import-PowerShellDataFile $PSScriptRoot\..\ModuleConfig.psd1
                    $KeyPermissions = $Variables.KeyVaultPermissions.Key
                    $SecretPermissions = $Variables.KeyVaultPermissions.Secret
                    $CertificatePermissions = $Variables.KeyVaultPermissions.Certificate

                    Foreach ($KeyVault in $KeyVaultList) {
                        Write-Verbose ("Check KVLT {0} for App {1}" -f $KeyVault.VaultName, $Application.DisplayName)
                        $KeyVault = Get-AzKeyVault -VaultName $KeyVault.VaultName #Access policies are only obtained when the key vault is queried directly
                        $KvPolicy = $KeyVault.AccessPolicies | Where-Object { $_.DisplayName -like ("{0}*" -f $Application.DisplayName) }

                        $KeyPermissions | Should -BeIn $KvPolicy.PermissionsToKeys
                        $SecretPermissions | Should -BeIn $KvPolicy.PermissionsToSecrets
                        $CertificatePermissions | Should -BeIn $KvPolicy.PermissionsToCertificates
                    }
                }
            }
        }
    }
}