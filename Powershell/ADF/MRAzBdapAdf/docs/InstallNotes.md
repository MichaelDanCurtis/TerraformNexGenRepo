# Installing MRAzBdapAdf

You can install MRAzBdapAdf
```PowerShell
Copy-Item MRAzBdapAdf "C:\Users\$env:USERNAME\Documents\WindowsPowerShell\Modules\MRAzBdapAdf"
Import-Module MRAzBdapAdf
```


# Installing MRAzBdapAdf

You can install MRAzBdapAdf

```PowerShell
git clone  https://apps-munichre.visualstudio.com/DefaultCollection/Big%20Data%20and%20Analytics%20Platform/_git/<repo> --branch master --single-branch [<folder>]

Copy-Item MRAzBdapAdf "C:\Users\$env:USERNAME\Documents\WindowsPowerShell\Modules\MRAzBdapAdf"
Import-Module MRAzBdapAdf
```

## Import

You can load MRAzBdapAdf

``` PowerShell
Import-Module .\MRAzBdapAdf\MRAzBdapAdf.psd1
Get-Command -Module MRAzBdapAdf
```

## Build and Test

Run individual tests from folder `.\MRAzBdapAdf\Test`

```PowerShell
Invoke-Pester .\MRAzBdapAdf\Test\
```

## Setup

Edit `config.json` in Setup folder an run in `Setup` the `.\setup.ps1`

```JSON
{
    "Company": "MR",
    "Environment": "SBX",
    "Application": "BDAP",
    "Location": "westeurope",
    ...
}
```
