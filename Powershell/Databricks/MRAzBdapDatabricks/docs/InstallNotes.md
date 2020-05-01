# Installing MRAzBdapDatabricks

You can install MRAzBdapDatabricks

```PowerShell
Copy-Item MRAzBdapDatabricks "C:\Users\$env:USERNAME\Documents\WindowsPowerShell\Modules\MRAzBdapDatabricks"
Import-Module MRAzBdapDatabricks
```


# Installing MRAzBdapDatabricks

You can install MRAzBdapDatabricks

```PowerShell
git clone  https://apps-munichre.visualstudio.com/DefaultCollection/Big%20Data%20and%20Analytics%20Platform/_git/<repo> --branch master --single-branch [<folder>]

Copy-Item MRAzBdapDatabricks "C:\Users\$env:USERNAME\Documents\WindowsPowerShell\Modules\MRAzBdapDatabricks"
Import-Module MRAzBdapDatabricks
```

## Import

You can load MRAzBdapDatabricks

``` PowerShell
Import-Module .\MRAzBdapDatabricks\MRAzBdapDatabricks.psd1
Get-Command -Module MRAzBdapDatabricks
```

## Build and Test

Run individual tests from folder `.\MRAzBdapDatabricks\Test`

```PowerShell
Invoke-Pester .\MRAzBdapDatabricks\Test\
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
