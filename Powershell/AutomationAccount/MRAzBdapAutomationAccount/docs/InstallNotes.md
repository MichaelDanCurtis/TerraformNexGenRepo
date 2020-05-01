# Installing MRAzBdapAutomationAccount

You can install MRAzBdapAutomationAccount
``` PowerShell
Copy-Item MRAzBdapAutomationAccount "$HOME\Documents\WindowsPowerShell\Modules\MRAzBdapAutomationAccount"
Import-Module MRAzBdapAutomationAccount
```

## Build and Test

Run tests from folder `.\MRAzBdapAutomationAccount\Test`:

``` PowerShell
.\MRAzBdapAutomationAccount\Test\Get-Name.Tests.ps1
.\MRAzBdapAutomationAccount\Test\New-Component.Tests.ps1
```

Or:
``` PowerShell
Invoke-Pester .\MRAzBdapAutomationAccount\Test
```

Using `"Ctrl+Shift+T"` you can execute the testing task automatically. If not set up already, you can find the description at
[link](https://apps-munichre.visualstudio.com/Big%20Data%20and%20Analytics%20Platform/_wiki/wikis/Big%20Data%20and%20Analytics%20Platform%20(BDAP)?wikiVersion=GBmaster&pagePath=%2FDevelopment%20Guidelines%2FPowerShell%20Guidelines&anchor=testing-task)
