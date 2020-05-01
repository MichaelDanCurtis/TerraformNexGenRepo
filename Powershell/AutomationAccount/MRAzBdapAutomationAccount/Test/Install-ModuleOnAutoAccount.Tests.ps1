
param(
    [string[]] $testConfigPaths
)
. "$PSScriptRoot\Shared.ps1"
. "$ModuleBase\Private\Get-StorageAccountNameForEnvironment.ps1"
. "$ModuleBase\Private\Install-ModuleOnAutoAccount.ps1"

Describe "Install-ModuleOnAutoAccount parameter tests" -Tags Unit {

    Context "Parameter Invalid - Parameter Set: __AllParameterSets" {
        $TestCases = @(
            @{
                ResourceGroupName = 'ResourceGroupName'
                UploadedModule    = @( "dummyValue" )
                Expected          = 'AutomationAccountName'
            },
            @{
                AutomationAccountName = 'AutomationAccountName'
                UploadedModule        = @( "dummyValue" )
                Expected              = 'ResourceGroupName'
            },
            @{
                AutomationAccountName = 'AutomationAccountName'
                ResourceGroupName     = 'ResourceGroupName'
                Expected              = 'UploadedModule'
            }
        )
        It "Given <AutomationAccountName> as AutomationAccountName, <ResourceGroupName> as ResourceGroupName, and <UploadedModule> as UploadedModule - should throw an exception containing <Expected>" -TestCases $TestCases {
            param(
                $AutomationAccountName,
                $ResourceGroupName,
                $UploadedModule,
                $Expected
            )
            {
                $InputObject = @{
                    AutomationAccountName = $AutomationAccountName
                    ResourceGroupName     = $ResourceGroupName
                    UploadedModule        = $UploadedModule
                }
                Install-ModuleOnAutoAccount @InputObject -WhatIf
            } | Should Throw $Expected
        }
    }
}


if ($testConfigPaths.Count -eq 0) {
    $testConfigPaths = (Get-Childitem -Path "$PSScriptRoot\resources" -Include "config.test.install.module.*.json" -Recurse).FullName
}

Foreach ($testConfigPath in $testConfigPaths) {

    Write-Verbose "Load configuration test file from '$testConfigPath' ..."
    $testConfig = Get-Content $testConfigPath -Raw | ConvertFrom-Json

    Write-Output "Config loaded"
    Write-Output "Parameters"
    Write-Output "=========="
    $testConfig
    Write-Output "=========="

    $testDate = (Get-Date -Format FileDateTimeUniversal).TrimEnd('Z')

    $testConfig.Descriptor = ("{0}{1}" -f $testConfig.Descriptor, $testDate.Substring($testDate.Length - 4))

    $ResourceGroupInputObject = @{
        Company     = $testConfig.Company
        Application = $testConfig.Application
        Environment = $testConfig.Environment
        Component   = 'Auto'
        MrLocation  = 'WE'
    }
    $resourceGroupName = ('{0}-{1}' -f (Get-MRAzBdapResourceGroupName @ResourceGroupInputObject), $testConfig.Descriptor)
    Write-Verbose "ResourceGroupName: '$resourceGroupName'"

    $InputObjectComponent = @{
        Company     = $testConfig.Company
        Application = $testConfig.Application
        Environment = $testConfig.Environment
        Descriptor  = $testConfig.Descriptor
    }
    $ComponentName = Get-MRAzBdapAutomationAccountName @InputObjectComponent
    Write-Verbose "ComponentName: '$ComponentName'"

    $Location = 'WestEurope' # its always gonna be West Europe.
    $StorageAccountName = ('mrbdaptt{0}we{1}' -f $testConfig.Environment, $testConfig.Descriptor).ToLower()

    $testModuleWithVersions = Find-Module -Name $testConfig.RequiredModules.Name -Repository $testConfig.RequiredModules.Repository  -AllVersions
    $LatestVersion = $testModuleWithVersions[0].Version
    $OlderVersion = $testModuleWithVersions[-1].Version
    Write-Verbose ("Used latest version of module {0} is {1}" -f $testConfig.RequiredModules.Name, $LatestVersion)
    Write-Verbose ("Used older version of module {0} is {1}" -f $testConfig.RequiredModules.Name, $OlderVersion)

    $env:testConfigPath = $testConfigPath
    $env:testConfig = $testConfig
    $env:resourceGroupName = $resourceGroupName
    $env:ComponentName = $ComponentName
    $env:Location = $Location
    $env:StorageAccountName = $StorageAccountName
    $env:testModuleWithVersions = $testModuleWithVersions
    $env:LatestVersion = $LatestVersion
    $env:OlderVersion = $OlderVersion

    InModuleScope MRAzBdapAutomationAccount {

        $testConfigPath = $env:testConfigPath
        $testConfig = Get-Content $testConfigPath -Raw | ConvertFrom-Json

        $resourceGroupName = $env:resourceGroupName
        $ComponentName = $env:ComponentName
        $Location = $env:Location
        $StorageAccountName = $env:StorageAccountName
        $testModuleWithVersions = $env:testModuleWithVersions
        $LatestVersion = $env:LatestVersion
        $OlderVersion = $env:OlderVersion

        Describe ('{0} - Automation Account integration tests' -f (Split-Path $testConfigPath -Leaf)) -Tags Integration {

            BeforeAll {
                $VerbosePreference = "Continue"
                Write-Verbose "BeforeAll: Remove resource group '$resourceGroupName' containing AutomationAccount '$ComponentName'"
                Get-AzResourceGroup -Name $ResourceGroupName  -ErrorAction SilentlyContinue | Remove-AzResourceGroup -Force
                Write-Verbose "BeforeAll: Removed AutomationAccount resource "

                Write-Verbose "BeforeAll: Setup resource group '$resourceGroupName'"
                $null = New-AzResourceGroup -Name $ResourceGroupName -Location $Location
                Write-Verbose "BeforeAll: Setup storage account '$StorageAccountName'"
                $null = New-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccountName -Location $Location -SkuName Standard_LRS

                Write-Verbose "BeforeAll: Setup automation account '$ComponentName'"
                $null = New-MRAzBdapAutomationAccountComponent -ComponentName $ComponentName -ResourceGroupName $ResourceGroupName -LogAnalyticsWorkspace $testConfig.LogAnalyticsWorkspace
                $VerbosePreference = "SilentlyContinue"
            }
            AfterAll {
                $VerbosePreference = "Continue"
                # Remove test environment
                Write-Information 'Removing test environment...'
                Get-AzResourceGroup -Name $ResourceGroupName -ErrorAction SilentlyContinue | Remove-AzResourceGroup -Force -AsJob
                $VerbosePreference = "SilentlyContinue"
            }

            Mock Get-StorageAccountNameForEnvironment { return ($env:StorageAccountName) }

            Context "Update-MRAzBdapAutomationAccountModuleLibrary - Import module from PSGallery to Storage Account" {

                It "Should not throw - latest version" {
                    {
                        $null = Update-MRAzBdapAutomationAccountModuleLibrary -Environment $testConfig.Environment -ModuleName $testConfig.RequiredModules.Name -Repository $testConfig.RequiredModules.Repository -Verbose
                    } | Should Not Throw
                }

                It "Should create blob for module packages - latest version" {
                    $Blob = ('{0}/{1}/{0}.zip' -f $testConfig.RequiredModules.Name, $LatestVersion)
                    $Package = Get-AzStorageBlob -Blob $Blob -Container 'modules'
                    $Package | Should -Not -BeNullOrEmpty
                    $Package | Should BeOfType 'Microsoft.WindowsAzure.Commands.Common.Storage.ResourceModel.AzureStorageBlob'
                }

                It "Should not throw - different version" {
                    {
                        $null = Update-MRAzBdapAutomationAccountModuleLibrary -Environment $testConfig.Environment -ModuleName $testConfig.RequiredModules.Name -Version $OlderVersion -Repository $testConfig.RequiredModules.Repository -Verbose
                    } | Should Not Throw
                }

                It "Should create blob for module packages - different version" {
                    $Blob = ('{0}/{1}/{0}.zip' -f $testConfig.RequiredModules.Name, $OlderVersion)
                    $Package = Get-AzStorageBlob -Blob $Blob -Container 'modules'
                    $Package | Should -Not -BeNullOrEmpty
                    $Package | Should BeOfType 'Microsoft.WindowsAzure.Commands.Common.Storage.ResourceModel.AzureStorageBlob'
                }
            }

            $StartTime = Get-Date
            $EndTime = $startTime.AddHours(0.5)

            $OldVersionName = ('{0}/{1}/{0}.zip' -f $testConfig.RequiredModules.Name, $OlderVersion)
            $OlderVersionSasLink = New-AzStorageBlobSASToken -Blob $OldVersionName -Container 'modules' -Permission r -StartTime $StartTime -ExpiryTime $EndTime
            $OlderVersionAbsoluteUri = 'https://{0}.blob.core.windows.net/modules/{1}{2}' -f $StorageAccountName, $OldVersionName, $OlderVersionSasLink
            Write-Verbose "Old Version Absolute URI: $OlderVersionAbsoluteUri"

            $NewVersionName = ('{0}/{1}/{0}.zip' -f $testConfig.RequiredModules.Name, $LatestVersion)
            $NewVersionSasLink = New-AzStorageBlobSASToken -Blob $NewVersionName -Container 'modules' -Permission r -StartTime $StartTime -ExpiryTime $EndTime
            $NewVersionAbsoluteUri = 'https://{0}.blob.core.windows.net/modules/{1}{2}' -f $StorageAccountName, $NewVersionName, $NewVersionSasLink
            Write-Verbose "New Version Absolute URI: $NewVersionAbsoluteUri"

            Context ("Install-ModuleOnAutoAccount - Import module '{0}' from Storage Account '$StorageAccountName' to Automation Account '$ComponentName'" -f $testConfig.RequiredModules.Name) {

                It "Should import older version of module" {
                    {
                        $InputObject = @{
                            AutomationAccountName = $ComponentName
                            ResourceGroupName     = $ResourceGroupName
                            UploadedModule        = @{
                                Name        = $testConfig.RequiredModules.Name
                                AbsoluteUri = $OlderVersionAbsoluteUri
                            }
                        }
                        Install-ModuleOnAutoAccount @InputObject
                    } | Should Not Throw

                    $InstalledModule = Get-AzAutomationModule -Name $testConfig.RequiredModules.Name -ResourceGroupName $ResourceGroupName -AutomationAccountName $ComponentName
                    $InstalledModule.Version -eq $OlderVersion | Should Be $true
                }

                It "Should update module to latest version" {
                    {
                        $InputObject = @{
                            AutomationAccountName = $ComponentName
                            ResourceGroupName     = $ResourceGroupName
                            UploadedModule        = @{
                                Name        = $testConfig.RequiredModules.Name
                                AbsoluteUri = $NewVersionAbsoluteUri
                            }
                        }
                        Install-ModuleOnAutoAccount @InputObject
                    } | Should Not Throw

                    $InstalledModule = Get-AzAutomationModule -Name $testConfig.RequiredModules.Name -ResourceGroupName $ResourceGroupName -AutomationAccountName $ComponentName
                    $InstalledModule.Version -eq $LatestVersion.ToString() | Should Be $true
                }
            }
        }
    }
}