[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "", Justification = "Variables are used inside Pester blocks.")]
param()
. "$PSScriptRoot\Shared.ps1"

$testConfPath = Join-Path $PSScriptRoot 'resources'
$TestValueFiles = (Get-ChildItem -Path "$testConfPath/*" -Include "*config.test.new.component.*.json").FullName

if ($TestValueFiles -is [array]) {
    $TestValueFile = $TestValueFiles[0]
}
else {
    $TestValueFile = $TestValueFiles
}

Foreach ($testConfigPath in $TestValueFiles) {

    Write-Verbose "Load configuration test file from '$testConfigPath' ..."
    $testConfig = Get-Content $testConfigPath -Raw | ConvertFrom-Json
    $testConfig

    Describe ('New-MRAzBdapAutomationAccountComponent parameter tests') -Tags Unit {

        Write-Verbose "Load configuration test file from '$TestValueFile' ..."
        $testConfig = Get-Content $testConfigPath -Raw | ConvertFrom-Json
        $testConfig

        Context "Parameter Invalid - Parameter Set: Default" {
            $TestCases = @(
                @{
                    ResourceGroupName     = $testConfig.ResourceGroupName
                    LogAnalyticsWorkspace = $testConfig.LogAnalyticsWorkspace
                    Expected              = 'ComponentName'
                },
                @{
                    ComponentName         = $testConfig.TComponentName
                    LogAnalyticsWorkspace = $testConfig.LogAnalyticsWorkspace
                    Expected              = 'ResourceGroupName'
                },
                @{
                    ComponentName     = $testConfig.TComponentName
                    ResourceGroupName = $testConfig.ResourceGroupName
                    Expected          = 'LogAnalyticsWorkspace'
                }

            )
            It "Given <ResourceGroupName> as ResourceGroupName, <LogAnalyticsWorkspace> as LogAnalyticsWorkspace and <LogAnalyticsWorkspace> as LogAnalyticsWorkspace - should throw an exception containing <Expected>" -TestCases $TestCases {
                param(
                    $ResourceGroupName,
                    $LogAnalyticsWorkspace,
                    $ComponentName,
                    $Expected
                )
                {
                    $InputObject = @{
                        ResourceGroupName     = $ResourceGroupName
                        LogAnalyticsWorkspace = $LogAnalyticsWorkspace
                        ComponentName         = $ComponentName
                    }
                    New-MRAzBdapAutomationAccountComponent @InputObject -WhatIf
                } | Should Throw $Expected
            }
        }
    }

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

    if ([string]::IsNullOrEmpty($testConfig.ComponentName)) {
        $InputObjectComponent = @{
            Company     = $testConfig.Company
            Application = $testConfig.Application
            Environment = $testConfig.Environment
            Descriptor  = $testConfig.Descriptor
        }
        $ComponentName = Get-MRAzBdapAutomationAccountName @InputObjectComponent
    }
    else {
        $ComponentName = $testConfig.ComponentName
    }
    Write-Verbose "ComponentName: '$ComponentName'"

    $Location = 'WestEurope' # its always gonna be West Europe.

    Describe ('{0} - New-MRAzBdapAutomationAccountComponent integration tests' -f (Split-Path $testConfig -Leaf)) -Tags Integration {

        BeforeAll {
            $VerbosePreference = "Continue"
            Write-Verbose "BeforeAll: Remove resource group '$resourceGroupName' containing AutomationAccount '$ComponentName'"
            Get-AzResourceGroup -Name $ResourceGroupName  -ErrorAction SilentlyContinue | Remove-AzResourceGroup -Force
            Write-Verbose "BeforeAll: Removed AutomationAccount resource "

            Write-Verbose "BeforeAll: Setup resource group '$resourceGroupName'"
            $null = New-AzResourceGroup -Name $ResourceGroupName -Location $Location
            $VerbosePreference = "SilentlyContinue"
        }
        AfterAll {
            $VerbosePreference = "Continue"
            # Remove test environment
            Write-Information 'Removing test environment...'
            Get-AzResourceGroup -Name $ResourceGroupName -ErrorAction SilentlyContinue | Remove-AzResourceGroup -Force -AsJob
            $VerbosePreference = "SilentlyContinue"
        }

        Context  "General validation" {

            It "Deployment should not throw any exception" {
                {
                    $testConfig = @{
                        ComponentName         = $componentName
                        ResourceGroupName     = $resourceGroupName
                        LogAnalyticsWorkspace = $testConfig.LogAnalyticsWorkspace
                    }
                    New-MRAzBdapAutomationAccountComponent @testConfig
                } | Should -Not -Throw
            }

            It "AutomationAccount '$ComponentName' should be deployed" {
                $autoAccount = Get-AzAutomationAccount -Name $ComponentName -ResourceGroupName $resourceGroupName
                $autoAccount | Should -Not -BeNullOrEmpty
            }
        }

        $AutomationAccountResource = Get-AzResource -Name $ComponentName -ResourceType 'Microsoft.Automation/automationAccounts'
        $AutomationAccount = Get-AzAutomationAccount -Name $ComponentName -ResourceGroupName $resourceGroupName

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
    }
}
