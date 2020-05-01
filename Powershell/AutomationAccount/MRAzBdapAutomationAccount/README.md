# MRAzBdapAutomationAccount
Author: MR BDAP Automation Team <p0060002256@munichre.com>

PowerShell Module for Azure Infrastructure as Code / automation code for Key Vaults

## Introduction

Repositories for the creation of the Azure AutomationAccount

Naming Convention: `<Company>-<Application>-<Environment>`

- mr-bdap-dev
- mr-bdap-sbx
## Installing MRAzBdapAutomationAccount

You can install MRAzBdapAutomationAccount
``` PowerShell
Copy-Item MRAzBdapAutomationAccount "$HOME\Documents\WindowsPowerShell\Modules\MRAzBdapAutomationAccount"
Import-Module MRAzBdapAutomationAccount
```

### Build and Test

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
## Release:  MRAzBdapAutomationAccount v0.1.0

Adds

- Get-MRAzBdapAutomationName
- New-MRAzBdapAutomationComponent
## Functions

### Get-MRAzBdapAutomationAccountArmTemplate

#### SYNOPSIS
Returns the link to the modules ARM template

#### SYNTAX

```
Get-MRAzBdapAutomationAccountArmTemplate [<CommonParameters>]
```

#### DESCRIPTION
Returns the link to the modules ARM template
Can be configured in Modulemanifest (MRAzBdapApp.psd1)  Attribute FileList = @('./static/azuredeploy.json')

#### EXAMPLES

##### EXAMPLE 1
```
Get-MRAzBdapAppArmTemplate
```

*.\bdap-az-automation-cosmos\MRAzBdapApp\static\azuredeploy.json

#### PARAMETERS

##### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

#### INPUTS

#### OUTPUTS

#### NOTES

#### RELATED LINKS
  ---

### Get-MRAzBdapAutomationAccountName

#### SYNOPSIS
Get the azure automation account name by naming convention \<Company\>-\<Application\>-\<Environment\>

#### SYNTAX

```
Get-MRAzBdapAutomationAccountName -Company <String> -Application <String> -Environment <String>
 [-Descriptor <String>] [-Delimiter <String>] [<CommonParameters>]
```

#### DESCRIPTION
Naming patterns \<Company\>-\<Application\>-\<Environment\>

Examples:
- mr-bdap-dev
- mr-bdap-sbx

Notes:
There is only one Azure Automation Account for every \<Environment\> which is always deployed to "West Europe"
There is also only one Service Account used for every \<Environment\> - e.g.
Ser-CEP-bd\<Environment\>auto

#### EXAMPLES

##### EXAMPLE 1
```
Get-MRAzBdapAutomationAccountName -Company 'MR' -Application 'BDAP'  -Environment 'SBX'
```

Generates naming conveniton:'mr-bdap-tt'

#### PARAMETERS

##### -Company
Name of Company - e.g.
MR

```yaml
Type: String
Parameter Sets: (All)
Aliases: Co

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

##### -Application
Name of Application - e.g.
BDAP

```yaml
Type: String
Parameter Sets: (All)
Aliases: App

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

##### -Environment
Name of Environment - e.g.
SBX
\[ValidateSet("prd", "int", "dev", "sbx", "tt")\]

```yaml
Type: String
Parameter Sets: (All)
Aliases: Env

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

##### -Descriptor
Descriptor if needed, incremental value or description

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

##### -Delimiter
Delimiter if needed

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: -
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

##### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

#### INPUTS

#### OUTPUTS

##### System.String
#### NOTES

#### RELATED LINKS
  ---

### Install-MRAzBdapAutomationAccountCustomModule

#### SYNOPSIS
Uploads the requested module from a Powershell Repository to Munich Re storage account and installs them on a given automation account

#### SYNTAX

##### ConfNoStorageAccount
```
Install-MRAzBdapAutomationAccountCustomModule -ModuleConfig <PSObject> -Environment <String>
 -AutomationAccountName <String> -ResourceGroupName <String> [-WhatIf] [-Confirm] [<CommonParameters>]
```

##### ConfStorageAccount
```
Install-MRAzBdapAutomationAccountCustomModule -ModuleConfig <PSObject> -StorageAccountName <String>
 -AutomationAccountName <String> -ResourceGroupName <String> [-WhatIf] [-Confirm] [<CommonParameters>]
```

##### NoConfNoStorageAccount
```
Install-MRAzBdapAutomationAccountCustomModule -ModuleConfigPath <String> -Environment <String>
 -AutomationAccountName <String> -ResourceGroupName <String> [-WhatIf] [-Confirm] [<CommonParameters>]
```

##### NoConfStorageAccount
```
Install-MRAzBdapAutomationAccountCustomModule -ModuleConfigPath <String> -StorageAccountName <String>
 -AutomationAccountName <String> -ResourceGroupName <String> [-WhatIf] [-Confirm] [<CommonParameters>]
```

#### DESCRIPTION
Uploads given modules by \`-ModuleNames\`, this is an array of module names that can be installed on a given Automation Account.
Modules can be from a private nuget feed or from PSGallery.
Modules will be also be uploaded to the given StorageAccount.
Using a convention of  \`$($ModuleName + '\' + $Version + '\' + $Package.BaseName + '.zip')\` where ModuleName is the parent Module and the \`Package.BaseName\` the dependent modules.
E.g.
DSVM consist of different internal Modules that need to be present on the automation account too.

// TODO: Currently it will only upload to an automation worker - not a hybrid worker!

#### EXAMPLES

##### EXAMPLE 1
```
Install-MRAzBdapAutomationAccountCustomModule -AutomationAccountName $accountName -ResourceGroupName $rgName -StorageAccountName $storageName -ModuleConfig @{ "RequiredModules": [{"Name":"AzureAD","Version":"2.0.2.16","Repository":"PSGallery"}]}  -Verbose
```

Upload and install module 'AzureAD' in version 2.0.2.16 on storage account $accountName

##### EXAMPLE 2
```
Install-MRAzBdapAutomationAccountCustomModule -AutomationAccountName $accountName -ResourceGroupName $rgName -StorageAccountName $storageName -ModuleConfig @{ "RequiredModules": [{"Name":"AzureAD","Repository":"PSGallery"}]}  -Verbose
```

Upload and install module 'AzureAD' in the latest version on storage account $accountName

##### EXAMPLE 3
```
Install-MRAzBdapAutomationAccountCustomModule -AutomationAccountName $accountName -ResourceGroupName $rgName -StorageAccountName $storageName -ModuleConfigPath 'C:/config.modules.json' -Verbose
```

Upload and install the modules specified in the given config path on the storage account $accoutName

#### PARAMETERS

##### -ModuleConfig
Object with module specifics.
E.g.
@{ "RequiredModules": \[{"Name":"AzureAD","Version":"2.0.2.16","Repository":"PSGallery"}\]}

```yaml
Type: PSObject
Parameter Sets: ConfNoStorageAccount, ConfStorageAccount
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

##### -ModuleConfigPath
Path to a json file with module specifics

```yaml
Type: String
Parameter Sets: NoConfNoStorageAccount, NoConfStorageAccount
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

##### -StorageAccountName
Name of the storage account to upload modules to (optional).
If not set, uses default (e.g.
'mrbdapsbxweauto')

```yaml
Type: String
Parameter Sets: ConfStorageAccount, NoConfStorageAccount
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

##### -Environment
Required Environment param if not storage account name is provided to find default storage account

```yaml
Type: String
Parameter Sets: ConfNoStorageAccount, NoConfNoStorageAccount
Aliases: Env

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

##### -AutomationAccountName
Name of the automation account to upload the modules to

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

##### -ResourceGroupName
Name of the resource group of the automation account

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

##### -WhatIf
Dry run of the script

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

##### -Confirm
Will promt user to confirm the action to create invasible commands

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

##### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

#### INPUTS

#### OUTPUTS

#### NOTES

#### RELATED LINKS
  ---

### Install-MRAzBdapAutomationAccountRunbook

#### SYNOPSIS
Iterates through a given path
- searching for a folder called Runbook
- itereates through each file in given runbook folder
- checks if its a runbook (by name - excludes test)
- uploades runbook given the file name (without type)
    - publish
    - sets logging and tracing on

#### SYNTAX

```
Install-MRAzBdapAutomationAccountRunbook [-Path] <String> [-AutomationAccountName] <String>
 [-ResourceGroupName] <String> [-WhatIf] [-Confirm] [<CommonParameters>]
```

#### DESCRIPTION
Iterates through a given path
- searching for a folder called Runbook
- itereates through each file in given runbook folder
- checks if its a runbook (by name - excludes test)
- uploades runbook given the file name (without type)
    - publish
    - sets logging and tracing on

#### EXAMPLES

##### EXAMPLE 1
```
Install-MRAzBdapAutomationAccountRunbook -Path $Path -AutomationAccount $AutomationAccountName -ResourceGroupName $ResourceGroupName -Verbose
```

Uploads the runbooks found in Path to given AutomationAccount

#### PARAMETERS

##### -Path
Path that should be searched for Runbooks folder

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

##### -AutomationAccountName
Name of AutomationAccount to upload

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

##### -ResourceGroupName
Name of ResourceGroup of Automation Account

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

##### -WhatIf
Dry run of the script

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

##### -Confirm
Will promt user to confirm the action to create invasible commands

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

##### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

#### INPUTS

#### OUTPUTS

#### NOTES

#### RELATED LINKS
  ---

### New-MRAzBdapAutomationAccountComponent

#### SYNOPSIS
Creates the azure automation account

#### SYNTAX

```
New-MRAzBdapAutomationAccountComponent [-ComponentName] <String> [-ResourceGroupName] <String>
 [-LogAnalyticsWorkspace] <String> [-WhatIf] [-Confirm] [<CommonParameters>]
```

#### DESCRIPTION
Creates the azure automation account

#### EXAMPLES

##### EXAMPLE 1
```
New-MRAzBdapAutomationAccountComponent -ResourceGroupName 'MR-BDAP-WE-TT-AUTO' -ComponentName 'mr-bdap-tt' -LogAnalyticsWorkspace $la
```

Creates an Azure Automation Account named after the parameter ComponentName.
Az module an RunAsConnection will be added automatically.

#### PARAMETERS

##### -ComponentName
Component Name - e.g.
\<Company\>-\<Application\>-\<Environment\>

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

##### -ResourceGroupName
Resource Group Name - e.g.
\<Company\>-\<Application\>-\<Environment\>-\<Location\>-\<Component\>\[-\<Description or Incremental Number\>\]

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

##### -LogAnalyticsWorkspace
Log analytics workspace name to link to

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

##### -WhatIf
Dry run of the script

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

##### -Confirm
Will promt user to confirm the action to create invasible commands

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

##### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

#### INPUTS

#### OUTPUTS

##### Microsoft.Azure.Commands.ResourceManager.Cmdlets.SdkModels.PSResourceGroupDeployment
#### NOTES
There is only one Azure Automation Account for every \<Environment\> which is always deployed to "West Europe"
There is also only one Service Account used for every \<Environment\> - e.g.
Ser-CEP-bd\<Environment\>auto

#### RELATED LINKS
  ---

### New-MRAzBdapAutomationAccountConnection

#### SYNOPSIS
Creates an Azure Automation connection

#### SYNTAX

```
New-MRAzBdapAutomationAccountConnection [-Environment] <String> [[-MrLocation] <String>]
 [-AutomationAccountName] <String> [-ResourceGroupName] <String> [[-ConnectionName] <String>]
 [[-CertificateSubject] <String>] [[-Company] <String>] [[-Application] <String>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

#### DESCRIPTION
Creates an Azure Automation connection of type AzureServicePrincipal, named 'AzureRunAsConnection', with Contributor role on the subscription.

#### EXAMPLES

##### EXAMPLE 1
```
New-MRAzBdapAutomationAccount -Environment 'tt' -MrLocation 'we' -AutomationAccountName 'mr-bdap-tt' -ResourceGroupName 'MR-BDAP-WE-TT-AUTO'
```

Creates a Connection for the Automation Account  'mr-bdap-tt'

#### PARAMETERS

##### -Environment
Name of Environment - e.g.
SBX
\[ValidateSet("prd", "int", "dev", "sbx", "tt")\]

```yaml
Type: String
Parameter Sets: (All)
Aliases: Env

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

##### -MrLocation
Name of MunichRe location - e.g.
we

```yaml
Type: String
Parameter Sets: (All)
Aliases: MrLoc

Required: False
Position: 2
Default value: WE
Accept pipeline input: False
Accept wildcard characters: False
```

##### -AutomationAccountName
Name of the Automation Account where the connection will be used.

```yaml
Type: String
Parameter Sets: (All)
Aliases: AaName

Required: True
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

##### -ResourceGroupName
Name of the Resource Group where the Automation Account was created

```yaml
Type: String
Parameter Sets: (All)
Aliases: Rg

Required: True
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

##### -ConnectionName
Name of the connection.
It is recommended to use the default value.

```yaml
Type: String
Parameter Sets: (All)
Aliases: Name

Required: False
Position: 5
Default value: AzureRunAsConnection
Accept pipeline input: False
Accept wildcard characters: False
```

##### -CertificateSubject
Subject of the Certificate.
It is recommended to use the default value.

```yaml
Type: String
Parameter Sets: (All)
Aliases: Subject

Required: False
Position: 6
Default value: CN=MRAzBdapAutomationConnection
Accept pipeline input: False
Accept wildcard characters: False
```

##### -Company
Name of the company - e.g.
MR

```yaml
Type: String
Parameter Sets: (All)
Aliases: Co

Required: False
Position: 7
Default value: MR
Accept pipeline input: False
Accept wildcard characters: False
```

##### -Application
Name of the application - e.g.
BDAP

```yaml
Type: String
Parameter Sets: (All)
Aliases: App

Required: False
Position: 8
Default value: BDAP
Accept pipeline input: False
Accept wildcard characters: False
```

##### -WhatIf
Dry run of the script

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

##### -Confirm
Will promt user to confirm the action to create invasible commands

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

##### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

#### INPUTS

#### OUTPUTS

##### Microsoft.Azure.Commands.Automation.Model.Connection
#### NOTES

#### RELATED LINKS
  ---

### Set-MRAzBdapAutomationAccountKeyVaultAccess

#### SYNOPSIS
Sets access policy to key vaults for a service principal

#### SYNTAX

##### Default (Default)
```
Set-MRAzBdapAutomationAccountKeyVaultAccess -ServicePrincipalName <String> -Company <String>
 -Application <String> [-WhatIf] [-Confirm] [<CommonParameters>]
```

##### KeyVault
```
Set-MRAzBdapAutomationAccountKeyVaultAccess -ServicePrincipalName <String> -KeyVault <String[]> [-WhatIf]
 [-Confirm] [<CommonParameters>]
```

#### DESCRIPTION
By default, target key vaults are defined by the naming convention, calculated from Company and Application parameters.
All region are always included and the environment is derived from the current context.
As an alternative it is possible to provide a list of key vaults.

The list of permissions is configured in the ModuleConfig.psd1 file

#### EXAMPLES

##### EXAMPLE 1
```
Set-MrAzBdapAutomationAccountKeyVaultAccess -ServicePrincipalName $Sp.DisplayName -Application $Application -Company $Company
```

Assigns permissions in all the key vault that follow the naming convention "\[company\]-\[application\]-*"

##### EXAMPLE 2
```
Set-MrAzBdapAutomationAccountKeyVaultAccess -ServicePrincipalName $Sp.DisplayName -KeyVault @("mr-bdap-tt-we","mr-bdap-tt-eus2")
```

Assigns permissions in all the listed key vaults

#### PARAMETERS

##### -ServicePrincipalName
Display name of the Service Principal

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

##### -Company
Company identifier - e.g.
MR

```yaml
Type: String
Parameter Sets: Default
Aliases: Co

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

##### -Application
Application identifier - e.g.
BDAP

```yaml
Type: String
Parameter Sets: Default
Aliases: App

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

##### -KeyVault
Array of target key vaults

```yaml
Type: String[]
Parameter Sets: KeyVault
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

##### -WhatIf
Dry run of the script

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

##### -Confirm
Will promt user to confirm the action to create invasible commands

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

##### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

#### INPUTS

#### OUTPUTS

#### NOTES

#### RELATED LINKS
  ---

### Set-MRAzBdapAutomationAccountUp

#### SYNOPSIS
Create an AutomationAccount with MunichRE specific post-deployment conditions

#### SYNTAX

##### Config
```
Set-MRAzBdapAutomationAccountUp -Config <PSObject> [-WhatIf] [-Confirm] [<CommonParameters>]
```

##### ConfigPath
```
Set-MRAzBdapAutomationAccountUp -configPath <String> [-WhatIf] [-Confirm] [<CommonParameters>]
```

#### DESCRIPTION
Create an AutomationAccount with MunichRE specific post-deployment conditions

#### EXAMPLES

##### EXAMPLE 1
```
Set-MRAzBdapAutomationAccountUp -Config $config
```

Deploy an AutomationAccount with a given configuration

#### PARAMETERS

##### -Config
Component configuration

```yaml
Type: PSObject
Parameter Sets: Config
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

##### -configPath
Path to a component configuration

```yaml
Type: String
Parameter Sets: ConfigPath
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

##### -WhatIf
Dry run of script, returns theoretical values

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

##### -Confirm
Before impacting system ask to confirm

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

##### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

#### INPUTS

#### OUTPUTS

#### NOTES

#### RELATED LINKS
  ---

### Update-MRAzBdapAutomationAccountModuleLibrary

#### SYNOPSIS
Uploads the requested module from a Powershell Repository to Munich Re storage account.

#### SYNTAX

##### StorageAccountName
```
Update-MRAzBdapAutomationAccountModuleLibrary -StorageAccountName <String> [-ModuleName <String>]
 [-Version <String>] [-Repository <String>] [-Credential <PSCredential>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

##### NoStorageAccountName
```
Update-MRAzBdapAutomationAccountModuleLibrary -Environment <String> [-ModuleName <String>] [-Version <String>]
 [-Repository <String>] [-Credential <PSCredential>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

#### DESCRIPTION
Uploads the requested module to Munich Re storage account.
The storage account changes based on the environment and is configurable in the ModuleConfig.psd1 file.

#### EXAMPLES

##### EXAMPLE 1
```
Update-MRAzBdapAutomationAccount -Environment PRD
```

Uploads Az module (with all dependencies), latest version

##### EXAMPLE 2
```
Update-MRAzBdapAutomationAccount -Environment PRD -ModuleName AzureAD -Version 2.0.2.16
```

Uploads AzureAD module, version 2.0.2.16

##### EXAMPLE 3
```
Update-MRAzBdapAutomationAccountModuleLibrary -Environment PRD -ModuleName MRAzBdapDsvm -Repository bdap_nuget_releases -Credential $Creds
```

Uploads MRAzBdapDsvm module (with all dependencies), latest version, from bdap PS repository.

#### PARAMETERS

##### -StorageAccountName
Name of the storage account to upload modules to

```yaml
Type: String
Parameter Sets: StorageAccountName
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

##### -Environment
Environment such as SBX (Sandbox), DEV (Development), INT (Integration), PRD (Production)

```yaml
Type: String
Parameter Sets: NoStorageAccountName
Aliases: Env

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

##### -ModuleName
Name of the Module.
Default is 'Az'

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: Az
Accept pipeline input: False
Accept wildcard characters: False
```

##### -Version
Version of the module.
Default is 'latest'.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: Latest
Accept pipeline input: False
Accept wildcard characters: False
```

##### -Repository
Target repository for dependency resolution

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: PSGallery
Accept pipeline input: False
Accept wildcard characters: False
```

##### -Credential
Repository credentials

```yaml
Type: PSCredential
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

##### -WhatIf
Dry run of the script

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

##### -Confirm
Will promt user to confirm the action to create invasible commands

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

##### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

#### INPUTS

#### OUTPUTS

##### System.String
#### NOTES

#### RELATED LINKS
  ---
