function Test-Deployment {

    param(
        [PSCustomObject] $testConfig,
        [string] $ComponentName,
        [string] $resourceGroupName,
        [string] $MrLocation
    )

    Context "General validation" {

        It "Deployment should not throw any exception" {
            { Set-MRAzBdapAutomationAccountUp -Config $testConfig } | Should -Not -Throw
        }

        It "AutomationAccount '$ComponentName' should be deployed" {
            $autoAccount = Get-AzAutomationAccount -Name $ComponentName -ResourceGroupName $resourceGroupName
            $autoAccount | Should -Not -BeNullOrEmpty
        }
    }

    $moduleRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
    $moduleConfigData = Import-PowerShellDataFile -Path (Resolve-Path (Join-Path $moduleRoot 'ModuleConfig.psd1'))

    $AutomationAccountResource = Get-AzResource -Name $ComponentName -ResourceType 'Microsoft.Automation/automationAccounts'
    $autoAccount = Get-AzAutomationAccount -Name $ComponentName -ResourceGroupName $resourceGroupName

    $storageAccountName = Get-StorageAccountNameForEnvironment -environment $testConfig.Environment
    $storageAccountResource = Get-AzResource -Name $storageAccountName -ResourceType 'Microsoft.Storage/storageAccounts'
    $storageAccount = Get-AzStorageAccount  -Name $storageAccountName -ResourceGroupName $storageAccountResource.resourceGroupName

    Context "Tag validation" {

        $availableTags = $autoAccount.Tags

        $expectedReleaseIndentifierTag = $env:RELEASE_RELEASENAME
        It "Should have valid 'ReleaseIdentifier' tag '$expectedReleaseIndentifierTag'" {
            $availableTags.Keys | Should -Contain "ReleaseIdentifier"
            $availableTags['ReleaseIdentifier'] | Should -Be $expectedReleaseIndentifierTag
        }

        $moduleName = Split-Path $moduleRoot -Leaf
        $expectedModuleVersionTag = (Get-Module $moduleName).Version
        It "Should have valid 'DeploymentModuleVersion' tag '$expectedModuleVersionTag'" {
            $availableTags.Keys | Should -Contain "DeploymentModuleVersion"
            $availableTags['DeploymentModuleVersion'] | Should -Be $expectedModuleVersionTag
        }
    }

    Context "Diagnostic Settings validation" {

        $diagnosticSettings = Get-AzDiagnosticSetting -ResourceId $AutomationAccountResource.Id

        $requiredMetricAll = $diagnosticSettings.Metrics | Where-Object { $_.Category -eq 'AllMetrics' }
        It "METRICS: Should have 'All' set" {
            $requiredMetricAll | Should -Not -BeNullOrEmpty
        }

        It "METRICS: Should have 'All' enabled" {
            $requiredMetricAll.Enabled | Should Be $true
        }

        $requiredLogsJobLogs = $diagnosticSettings.Logs | Where-Object { $_.Category -eq 'JobLogs' }
        It "LOGS: Should have 'JobLogs' set" {
            $requiredLogsJobLogs | Should -Not -BeNullOrEmpty
        }
        It "LOGS: Should have 'JobLogs' enabled" {
            $requiredLogsJobLogs.Enabled | Should Be $true
        }

        $requiredLogsJobStreams = $diagnosticSettings.Logs | Where-Object { $_.Category -eq 'JobStreams' }
        It "LOGS: Should have 'JobStreams' set" {
            $requiredLogsJobStreams | Should -Not -BeNullOrEmpty
        }
        It "LOGS: Should have 'JobStreams' enabled" {
            $requiredLogsJobStreams.Enabled | Should Be $true
        }

        $requiredLogsDscNodeStatus = $diagnosticSettings.Logs | Where-Object { $_.Category -eq 'DscNodeStatus' }
        It "LOGS: Should have 'DscNodeStatus' set" {
            $requiredLogsDscNodeStatus | Should -Not -BeNullOrEmpty
        }
        It "LOGS: Should have 'DscNodeStatus' enabled" {
            $requiredLogsDscNodeStatus.Enabled | Should Be $true
        }
    }

    Context "Connection validation" {

        $servicePrincipalName = Get-MRAzBdapServicePrincipalName -MrLocation 'WE' -Environment $testConfig.Environment -Suffix '-connection'
        $servicePrincipal = Get-AzADServicePrincipal -DisplayName $servicePrincipalName

        It "Service Principal '$servicePrincipalName' should have role 'Contributor' on subscription level" {

            $Subscription = (Get-AzContext).Subscription
            $assignmentsInput = @{
                Scope              = ("/subscriptions/{0}" -f $Subscription.Id)
                RoleDefinitionName = "Contributor"
                ObjectId           = $servicePrincipal.Id
            }
            $matchingAssignments = Get-AzRoleAssignment @assignmentsInput
            $matchingAssignments | Should -Not -BeNullOrEmpty
        }

        $requiredPermissions = $moduleConfigData.KeyVaultPermissions
        [array]$KeyVaultList = Get-AzKeyVault -VaultName ('{0}-{1}*' -f $testConfig.Company, $testConfig.Application)
        Write-Verbose ("Testing {0} keyvaults" -f $KeyVaultList.Count)
        foreach ($keyVault in $KeyVaultList) {
            $keyVaultObject = Get-AzKeyVault -VaultName $keyVault.VaultName -ResourceGroupName $keyVault.ResourceGroupName
            $relAccessPolicies = $keyVaultObject.AccessPolicies | Where-Object { $_.DisplayName -like "*$servicePrincipalName*" }

            foreach ($keyPolicy in $requiredPermissions.Key) {
                It ("Service Principal '{0}' should have keyvault access policy for keyvault '{1}': KEYS - {2}" -f $servicePrincipalName, $keyVaultObject.VaultName, $keyPolicy) {
                    $relAccessPolicies.PermissionsToKeys | Should -Contain $keyPolicy
                }
            }

            foreach ($secretPolicy in $requiredPermissions.Secret) {
                It ("Service Principal '{0}' should have keyvault access policy for keyvault '{1}': SECRETS - {2}" -f $servicePrincipalName, $keyVaultObject.VaultName, $secretPolicy) {
                    $relAccessPolicies.PermissionsToSecrets | Should -Contain $secretPolicy
                }
            }

            foreach ($certificatePolicy in $requiredPermissions.Certificate) {
                It ("Service Principal '{0}' should have keyvault access policy for keyvault '{1}': CERTIFICATES - {2}" -f $servicePrincipalName, $keyVaultObject.VaultName, $certificatePolicy) {
                    $relAccessPolicies.PermissionsToCertificates | Should -Contain $certificatePolicy
                }
            }
        }

        It ("Service Principal '$servicePrincipalName' should have connection to automation account '{0}'" -f $ComponentName) {
            $InputObject = @{
                Name                  = 'AzureRunAsConnection'
                AutomationAccountName = $ComponentName
                ResourceGroupName     = $ResourceGroupName
            }
            $Connection = Get-AzAutomationConnection @InputObject -ErrorAction SilentlyContinue

            $Connection.ConnectionTypeName | Should Be  'AzureServicePrincipal'
            $Connection.FieldDefinitionValues.ApplicationId | Should Be $servicePrincipal.ApplicationId
        }

        $defaultKeyVaultName = Get-MrAzBdapKvltName -Company $testConfig.Company -Application $testConfig.Application -Environment $testConfig.Environment -MrLocation $MrLocation
        It "Service Principal '$servicePrincipalName' should have correct 'RunAs' certificate in default key vault '$defaultKeyVaultName'" {
            $availableCertificate = Get-AzKeyVaultCertificate -VaultName $defaultKeyVaultName -Name "$servicePrincipalName-pfx"
            $availableCertificate | Should -Not -BeNullOrEmpty

            $assignedCertificate = Get-AzAutomationCertificate -Name 'AzureRunAsCertificate' -ResourceGroupName $resourceGroupName -AutomationAccountName $ComponentName
            $assignedCertificate | Should -Not -BeNullOrEmpty
            $assignedCertificate.Thumbprint | Should Be $availableCertificate.Thumbprint
        }
    }

    Context "Module handling validation" {
        $containerName = $moduleConfigData.AutomationModuleContainer
        It ('Container "{0}" should exist in storage account "{1}"' -f $containerName, $storageAccount.StorageAccountName) {
            $fileSystem = Get-AzStorageContainer -Name $containerName -Context $storageAccount.Context -ErrorAction SilentlyContinue
            $fileSystem | Should -Not -BeNullOrEmpty
        }

        $requiredModules = $testConfig.RequiredModules

        # Storage Account Data
        $container = Get-AzStorageContainer -Name $containerName -Context $storageAccount.Context
        $folders = $container.CloudBlobContainer.ListBlobs().Prefix.TrimEnd('/')
        foreach ($requiredModule in $requiredModules) {
            It ('Module "{0}" shoud be uploaded to storage account' -f $requiredModule.Name) {
                $folders | Should -Contain $requiredModule.Name
            }
        }

        # Automation Account Data
        $deployedModules = Get-AzAutomationModule -ResourceGroupName $resourceGroupName -AutomationAccountName $ComponentName
        foreach ($requiredModule in $requiredModules) {
            It ('Module "{0}" shoud be installed in automation account' -f $requiredModule.Name) {
                $deployedModules.Name | Should -Contain $requiredModule.Name
            }
        }
    }
}