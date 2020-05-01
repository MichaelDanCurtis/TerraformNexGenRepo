. "$PSScriptRoot\Shared.ps1"

Describe "Get-Name function parameter validation" -Tags Unit {
    It "Rule Get-Name without parameter should throw" {
        {
            $Company = ''
            $Application = ''
            $Environment = ''

            Get-MRAzBdapAutomationAccountName -Company $Company -Application $Application  -Environment $Environment
        } | Should Throw

    }

    It "Rule Get-Name Environment parameter should throw" {
        {
            $Company = 'MR'
            $Application = 'BDAP'
            $Environment = 'FALSE' #        [ValidateSet("prd", "int", "dev", "sbx", "tt")]

            Get-MRAzBdapAutomationAccountName -Company $Company -Application $Application  -Environment $Environment
        } | Should Throw
    }

    It "Rule Get-Name with ParemeterSet Default" {

        $Company = 'MR'
        $Application = 'BDAP'
        $Environment = 'TT'


        $ComponentName = 'mr-bdap-tt'

        $AutomationAccountName = Get-MRAzBdapAutomationAccountName -Company $Company -Application $Application  -Environment $Environment

        $AutomationAccountName | should BeLike "$Company*"
        $AutomationAccountName | should BeLike "*$Application*"
        $AutomationAccountName | should BeLike "*$Environment*"
        $AutomationAccountName | should BeLike "*-*" # Delimiter
        $AutomationAccountName | should Not BeLike "*-" # no trailing delimiter
        $AutomationAccountName | should BeExactly $ComponentName
    }

    It "Rule Get-Name with ParemeterSet with descriptor" {

        $Company = 'MR'
        $Application = 'BDAP'
        $Environment = 'TT'
        $Descriptor = 'testDesc'


        $ComponentName = "$company-$application-$environment-$Descriptor".ToLower()

        $AutomationAccountName = Get-MRAzBdapAutomationAccountName -Company $Company -Application $Application  -Environment $Environment -Descriptor $Descriptor

        $AutomationAccountName | should Not BeLike "-*" # no preceeding delimiter
        $AutomationAccountName | should Not BeLike "*-" # no trailing delimiter
        $AutomationAccountName | should BeExactly $ComponentName
    }

}
