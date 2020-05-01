. "$PSScriptRoot\Shared.ps1"

Describe "Get-ArmTemplate unit test" -Tag Unit {
    It "Should return Automation account template" {
        $TemplateUri = Get-MRAzBdapAutomationAccountArmTemplate

        Test-Path $TemplateUri | Should Be $true
        $TemplateUri -like "*automation.automationaccounts.json" | Should Be $true
    }
}