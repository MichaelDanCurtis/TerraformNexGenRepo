# Introduction
Repositories for the creation of the Azure Data Factory

- [Wiki](https://apps-munichre.visualstudio.com/Big%20Data%20and%20Analytics%20Platform/_wiki/wikis/Big-Data-and-Analytics-Platform.wiki?pagePath=%2FComponents%2FAzure%20Data%20Factory%20(ADF)&pageId=2004&wikiVersion=GBwikiMaster)

Naming Convention: ``` <Company>-<Application>-<Environment>-<MRLocation>-<Description and/or Incremental Number>```

- mr-bdap-prd-we-e0001
- mr-bdap-sbx-eus2-adf-e123

Note: Maximum character length of 23

The ADF instance, a Storage Account and an associated Key Vault get deployed together into a dedicated Resource Group. The Key Vault has the same name as the Azure Data Factory.

# Getting Started

``` PowerShell
Import-Module .\MRAzBdapAdf\MRAzBdapAdf.psd1
Get-Command -Module MRAzBdapAdf
```

``` PowerShell
# Generates naming convention
Get-MRAzBdapAdfName -Company 'mr' -Application 'bdap' -Environment 'sbx' -MRLocation 'we' -Description 'test56'
# "mr-bdap-sbx-we-test56"
```

``` PowerShell
# Creates Azure Data Factory
New-MRAzBdapAdfComponent -Company 'mr' -Application 'bdap' -Environment 'sbx' -Location 'we' -Component 'test' -Descriptor '123'
    -LogAnalyticsWorkspace mr-bdap-sbx-eu NumberOfAzIRs 3
# 'mr-bdap-sbx-we-test-123'
```


# Build and Test
Run tests from folder ```.\MRAzBdapAdf\Test```

``` PowerShell
Invoke-Pester .\MRAzBdapAdf\Test
```
