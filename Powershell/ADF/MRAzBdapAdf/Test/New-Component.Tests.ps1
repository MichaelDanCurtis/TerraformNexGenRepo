param(
    $TestValueFile
)
. $PSScriptRoot\Shared.ps1

if ([string]::isNullOrEmpty($TestValueFile)) {
    $TestValueFiles = (Get-Childitem -Path "$ModuleBase\Test\resources" -Include "config.component.*test.json" -Recurse).FullName
}

Foreach ($TestValueFile in $TestValueFiles) {
    $Env:TestValueFile = $TestValueFile
    $TestValues = Get-Content $TestValueFile | ConvertFrom-Json

    Describe "New-MRAzBdapAdfComponent parameter tests" -Tags Unit {

        Context "Parameter Invalid - Parameter Set: Default" {
            $TestCases = @(
                @{
                    Company               = $TestValues.Company
                    Application           = $TestValues.Application
                    Environment           = $TestValues.Environment
                    MrLocation            = $TestValues.MrLocation
                    LogAnalyticsWorkspace = $TestValues.LogAnalyticsWorkspace
                    ResourceGroupName     = $TestValues.ResourceGroupName
                    Location              = $TestValues.Location
                    NumberOfAzIRs         = $TestValues.NumberOfAzIRs
                    Expected              = 'Description'
                },
                @{
                    Description           = $TestValues.Description
                    Application           = $TestValues.Application
                    Environment           = $TestValues.Environment
                    MrLocation            = $TestValues.MrLocation
                    LogAnalyticsWorkspace = $TestValues.LogAnalyticsWorkspace
                    ResourceGroupName     = $TestValues.ResourceGroupName
                    Location              = $TestValues.Location
                    NumberOfAzIRs         = $TestValues.NumberOfAzIRs
                    Expected              = 'Company'
                },
                @{
                    Description           = $TestValues.Description
                    Company               = $TestValues.Company
                    Environment           = $TestValues.Environment
                    MrLocation            = $TestValues.MrLocation
                    LogAnalyticsWorkspace = $TestValues.LogAnalyticsWorkspace
                    ResourceGroupName     = $TestValues.ResourceGroupName
                    Location              = $TestValues.Location
                    NumberOfAzIRs         = $TestValues.NumberOfAzIRs
                    Expected              = 'Application'
                },
                @{
                    Description           = $TestValues.Description
                    Company               = $TestValues.Company
                    Application           = $TestValues.Application
                    MrLocation            = $TestValues.MrLocation
                    LogAnalyticsWorkspace = $TestValues.LogAnalyticsWorkspace
                    ResourceGroupName     = $TestValues.ResourceGroupName
                    Location              = $TestValues.Location
                    NumberOfAzIRs         = $TestValues.NumberOfAzIRs
                    Expected              = 'Environment'
                },
                @{
                    Description           = $TestValues.Description
                    Company               = $TestValues.Company
                    Application           = $TestValues.Application
                    Environment           = $TestValues.Environment
                    LogAnalyticsWorkspace = $TestValues.LogAnalyticsWorkspace
                    ResourceGroupName     = $TestValues.ResourceGroupName
                    Location              = $TestValues.Location
                    NumberOfAzIRs         = $TestValues.NumberOfAzIRs
                    Expected              = 'MrLocation'
                },
                @{
                    Description       = $TestValues.Description
                    Company           = $TestValues.Company
                    Application       = $TestValues.Application
                    Environment       = $TestValues.Environment
                    MrLocation        = $TestValues.MrLocation
                    ResourceGroupName = $TestValues.ResourceGroupName
                    Location          = $TestValues.Location
                    NumberOfAzIRs     = $TestValues.NumberOfAzIRs
                    Expected          = 'LogAnalyticsWorkspace'
                },
                @{
                    Description           = $TestValues.Description
                    Company               = $TestValues.Company
                    Application           = $TestValues.Application
                    Environment           = $TestValues.Environment
                    MrLocation            = $TestValues.MrLocation
                    LogAnalyticsWorkspace = $TestValues.LogAnalyticsWorkspace
                    Location              = $TestValues.Location
                    NumberOfAzIRs         = $TestValues.NumberOfAzIRs
                    Expected              = 'ResourceGroupName'
                },
                @{
                    Description           = $TestValues.Description
                    Company               = $TestValues.Company
                    Application           = $TestValues.Application
                    Environment           = $TestValues.Environment
                    MrLocation            = $TestValues.MrLocation
                    LogAnalyticsWorkspace = $TestValues.LogAnalyticsWorkspace
                    ResourceGroupName     = $TestValues.ResourceGroupName
                    NumberOfAzIRs         = $TestValues.NumberOfAzIRs
                    Expected              = 'Location'
                }
            )
            It "Given <Description> as Description, <Company> as Company, <Application> as Application, <Environment> as Environment, <MrLocation> as MrLocation, <LogAnalyticsWorkspace> as LogAnalyticsWorkspace, <ResourceGroupName> as ResourceGroupName, and <Location> as Location - should throw an exception containing <Expected>" -TestCases $TestCases {
                param(
                    $Description,
                    $Company,
                    $Application,
                    $Environment,
                    $MrLocation,
                    $LogAnalyticsWorkspace,
                    $ResourceGroupName,
                    $Location,
                    $NumberOfAzIRs,
                    $Expected
                )
                {
                    $InputObject = @{
                        Description           = $Description
                        Company               = $Company
                        Application           = $Application
                        Environment           = $Environment
                        MrLocation            = $MrLocation
                        LogAnalyticsWorkspace = $LogAnalyticsWorkspace
                        ResourceGroupName     = $ResourceGroupName
                        Location              = $Location
                        NumberOfAzIRs         = $NumberOfAzIRs
                    }
                    New-MRAzBdapAdfComponent @InputObject -WhatIf
                } | Should Throw $Expected
            }
        }
        InModuleScope -ModuleName MRAzBdapAdf -ScriptBlock {

            $TestValues = Get-Content $Env:TestValueFile | ConvertFrom-Json

            Context "Parameter valid - Parameter Set: Default" {
                Mock Get-AzResourceGroup { return @{ResourceGroupName = $TestValues.ResourceGroupName } } -ModuleName MRAzBdapAdf


                $TestCases = @(
                    @{
                        Description           = $TestValues.Description
                        Company               = $TestValues.Company
                        Application           = $TestValues.Application
                        Environment           = $TestValues.Environment
                        MrLocation            = $TestValues.MrLocation
                        LogAnalyticsWorkspace = $TestValues.LogAnalyticsWorkspace
                        ResourceGroupName     = $TestValues.ResourceGroupName
                        Location              = $TestValues.Location
                        NumberOfAzIRs         = $TestValues.NumberOfAzIRs
                    }
                )
                It "Given <Description> as Description, <Company> as Company, <Application> as Application, <Environment> as Environment, <MrLocation> as MrLocation, <LogAnalyticsWorkspace> as LogAnalyticsWorkspace, <ResourceGroupName> as ResourceGroupName, <NumberOfAzIRs> as NumberOfAzIRs, and <Location> as Location - function should not throw" -TestCases $TestCases {
                    param(
                        $Description,
                        $Company,
                        $Application,
                        $Environment,
                        $MrLocation,
                        $LogAnalyticsWorkspace,
                        $ResourceGroupName,
                        $Location,
                        $NumberOfAzIRs,
                        $Expected
                    )

                    {
                        $InputObject = @{
                            Description           = $Description
                            Company               = $Company
                            Application           = $Application
                            Environment           = $Environment
                            MrLocation            = $MrLocation
                            LogAnalyticsWorkspace = $LogAnalyticsWorkspace
                            ResourceGroupName     = $ResourceGroupName
                            Location              = $Location
                            NumberOfAzIRs         = $NumberOfAzIRs
                        }
                        New-MRAzBdapAdfComponent @InputObject -WhatIf
                    } | Should Not Throw
                }

                ## Add Assert-MockCalled here.
            }
        }
        Context "Parameter Invalid - Parameter Set: ComponentName" {
            $TestCases = @(
                @{
                    Location = $TestValues.Location
                    Expected = 'ResourceGroupName'
                },
                @{
                    ResourceGroupName = $TestValues.ResourceGroupName
                    Expected          = 'Location'
                }
            )
            It "Given <ResourceGroupName> as ResourceGroupName, and <Location> as Location - should throw an exception containing <Expected>" -TestCases $TestCases {
                param(
                    $ResourceGroupName,
                    $Location,
                    $Expected
                )
                {
                    $InputObject = @{
                        ResourceGroupName = $ResourceGroupName
                        Location          = $Location
                    }
                    New-MRAzBdapAdfComponent @InputObject -WhatIf
                } | Should Throw $Expected
            }
        }
        InModuleScope -ModuleName MRAzBdapAdf -ScriptBlock {

            $TestValues = Get-Content $Env:TestValueFile | ConvertFrom-Json

            Context "Parameter valid - Parameter Set: ComponentName" {
                Mock Get-AzResourceGroup { return @{ResourceGroupName = $TestValues.ResourceGroupName } } -ModuleName MRAzBdapAdf

                $TestCases = @(
                    @{
                        ResourceGroupName = $TestValues.ResourceGroupName
                        Location          = $TestValues.Location
                    }
                )
                It "Given <ResourceGroupName> as ResourceGroupName, and <Location> as Location - function should not throw" -TestCases $TestCases {
                    param(
                        $ResourceGroupName,
                        $Location,
                        $Expected
                    )

                    {
                        $InputObject = @{
                            ResourceGroupName     = $ResourceGroupName
                            Location              = $Location
                            Description           = $TestValues.Description
                            Company               = $TestValues.Company
                            Application           = $TestValues.Application
                            Environment           = $TestValues.Environment
                            MrLocation            = $TestValues.MrLocation
                            LogAnalyticsWorkspace = $TestValues.LogAnalyticsWorkspace
                            NumberOfAzIRs         = $TestValues.NumberOfAzIRs

                        }
                        New-MRAzBdapAdfComponent @InputObject -WhatIf
                    } | Should Not Throw
                }

                ## Add Assert-MockCalled here.
            }
        }
    }
}
Foreach ($TestValueFile in $TestValueFiles) {

    $TestValues = Get-Content $TestValueFile | ConvertFrom-Json

    $descLength = 6
    $number = (Get-Random).ToString()
    $description = $number.Substring(($number.Length - $descLength))

    Describe "New-MRAzBdapAdfComponent integration tests" -Tags Integration {

        BeforeAll {
            # Create test environment
            $ResourceGroupName = 'MR-BDAP-TT-' + (Get-Date -Format FileDateTimeUniversal)
            Write-Verbose 'Creating test environment...'
            Get-AzResourceGroup -Name $ResourceGroupName -ErrorAction SilentlyContinue | Remove-AzResourceGroup -Force
            $null = New-AzResourceGroup -Name $ResourceGroupName -Location 'WestEurope'
        }
        AfterAll {
            # Remove test environment
            Write-Verbose 'Removing test environment...'
            Get-AzResourceGroup -Name $ResourceGroupName | Remove-AzResourceGroup -Force -AsJob
        }

        Context "Deploy Azure Data Factory" {
            It "Should deploy an Azure Data Factory to Azure with no erros" {
                {


                    $InputObject = @{
                        ResourceGroupName     = $ResourceGroupName
                        Location              = $TestValues.Location
                        Description           = $description
                        Company               = $TestValues.Company
                        Application           = $TestValues.Application
                        Environment           = $TestValues.Environment
                        MrLocation            = $TestValues.MrLocation
                        LogAnalyticsWorkspace = $TestValues.LogAnalyticsWorkspace
                        NumberOfAzIRs         = $TestValues.NumberOfAzIRs
                    }

                    $Component = New-MRAzBdapAdfComponent @InputObject -Verbose
                    $Component
                } | Should Not Throw
            }

            $AzIRs = Get-AzDataFactoryV2IntegrationRuntime -ResourceGroupName $ResourceGroupName -DataFactoryName "mr-bdap-tt-we-$description" | Measure-Object
            $TestValue = $AzIRs.count
            $TestValue

            It "ADF has correct number of Azure Hosted IRs configured" {
                $AzIRs.Count | Should -Be $TestValues.NumberOfAzIRs
            }

        }
    }
}
