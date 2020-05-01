# Introduction

Repositories for the creation of the Azure AutomationAccount

Naming Convention: `<Company>-<Application>-<Environment>`

- mr-bdap-dev
- mr-bdap-sbx

## Getting Started

``` PowerShell
Import-Module .\MRAzBdapAutomationAccount\MRAzBdapAutomationAccount.psd1
Get-Command -Module MRAzBdapAutomationAccount
```

``` PowerShell
# Generates naming conveniton
Get-MRAzBdapAutomationAccountName -Company 'MR' -Application 'BDAP'  -Environment 'tt'
# 'mr-bdap-tt'
```

``` PowerShell
# Creates Azure Automation Account
New-MRAzBdapAutomationAccountComponent -Company 'MR' -Application 'BDAP'  -Environment 'tt' -ResourceGroupName $ResourceGroupName -Location 'WestEurope'
# 'mr-bdap-tt'
```

## Build and Test

Run tests from folder `.\MRAzBdapAutomationAccount\Test`

``` PowerShell
.\MRAzBdapAutomationAccount\Test\Get-Name.Tests.ps1
.\MRAzBdapAutomationAccount\Test\New-Component.Tests.ps1
```