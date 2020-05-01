param(
    [string[]] $TestValueFiles
)
. "$PSScriptRoot\Shared.ps1"

if ($TestValueFiles.Count -eq 0) {
    $TestValueFiles = (Get-Childitem -Path "$ModuleBase\Test\resources" -Include "config.test.new.component.*.json" -Recurse).FullName
}

Foreach ($TestValueFile in $TestValueFiles) {
    $Env:TestValueFile = $TestValueFile
    $TestValues = Get-Content $TestValueFile | ConvertFrom-Json

    Describe ('{0} -Update-MRAzBdapAutomationAccountModuleLibrary parameter tests' -f (Split-Path $TestValueFile  -Leaf)) -Tags Unit {

        Context "Parameter Invalid - Parameter Set: __AllParameterSets" {
            $TestCases = @(
                @{
                    Expected = 'Environment'
                }
            )
            It "Given and <Environment> as Environment - should throw an exception containing <Expected>" -TestCases $TestCases {
                param(
                    $Environment,
                    $Expected
                )
                {
                    $InputObject = @{
                        Environment = $Environment
                    }
                    Update-MRAzBdapAutomationAccountModuleLibrary @InputObject -WhatIf
                } | Should Throw $Expected
            }
        }
        InModuleScope -ModuleName MRAzBdapAutomationAccount -ScriptBlock {

            $TestValues = Get-Content $Env:TestValueFile | ConvertFrom-Json

            Context "Parameter valid - Parameter Set: __AllParameterSets" {
                $TestCases = @(
                    @{
                        Environment = $TestValues.Environment
                    }
                )
                It "Given and <Environment> as Environment - function should not throw" -TestCases $TestCases {
                    param(
                        $Environment
                    )

                    {
                        $InputObject = @{
                            Environment = $Environment
                        }
                        Update-MRAzBdapAutomationAccountModuleLibrary @InputObject -WhatIf
                    } | Should Not Throw
                }
            }
        }
    }
}
