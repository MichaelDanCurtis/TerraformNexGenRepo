---
external help file: MRAzBdapAutomationAccount-help.xml
Module Name: MRAzBdapAutomationAccount
online version:
schema: 2.0.0
---

# Install-MRAzBdapAutomationAccountCustomModule

## SYNOPSIS
Uploads the requested module from a Powershell Repository to Munich Re storage account and installs them on a given automation account

## SYNTAX

### ConfNoStorageAccount
```
Install-MRAzBdapAutomationAccountCustomModule -ModuleConfig <PSObject> -Environment <String>
 -AutomationAccountName <String> -ResourceGroupName <String> [-WhatIf] [-Confirm] [<CommonParameters>]
```

### ConfStorageAccount
```
Install-MRAzBdapAutomationAccountCustomModule -ModuleConfig <PSObject> -StorageAccountName <String>
 -AutomationAccountName <String> -ResourceGroupName <String> [-WhatIf] [-Confirm] [<CommonParameters>]
```

### NoConfNoStorageAccount
```
Install-MRAzBdapAutomationAccountCustomModule -ModuleConfigPath <String> -Environment <String>
 -AutomationAccountName <String> -ResourceGroupName <String> [-WhatIf] [-Confirm] [<CommonParameters>]
```

### NoConfStorageAccount
```
Install-MRAzBdapAutomationAccountCustomModule -ModuleConfigPath <String> -StorageAccountName <String>
 -AutomationAccountName <String> -ResourceGroupName <String> [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Uploads given modules by \`-ModuleNames\`, this is an array of module names that can be installed on a given Automation Account.
Modules can be from a private nuget feed or from PSGallery.
Modules will be also be uploaded to the given StorageAccount.
Using a convention of  \`$($ModuleName + '\' + $Version + '\' + $Package.BaseName + '.zip')\` where ModuleName is the parent Module and the \`Package.BaseName\` the dependent modules.
E.g.
DSVM consist of different internal Modules that need to be present on the automation account too.

// TODO: Currently it will only upload to an automation worker - not a hybrid worker!

## EXAMPLES

### EXAMPLE 1
```
Install-MRAzBdapAutomationAccountCustomModule -AutomationAccountName $accountName -ResourceGroupName $rgName -StorageAccountName $storageName -ModuleConfig @{ "RequiredModules": [{"Name":"AzureAD","Version":"2.0.2.16","Repository":"PSGallery"}]}  -Verbose
```

Upload and install module 'AzureAD' in version 2.0.2.16 on storage account $accountName

### EXAMPLE 2
```
Install-MRAzBdapAutomationAccountCustomModule -AutomationAccountName $accountName -ResourceGroupName $rgName -StorageAccountName $storageName -ModuleConfig @{ "RequiredModules": [{"Name":"AzureAD","Repository":"PSGallery"}]}  -Verbose
```

Upload and install module 'AzureAD' in the latest version on storage account $accountName

### EXAMPLE 3
```
Install-MRAzBdapAutomationAccountCustomModule -AutomationAccountName $accountName -ResourceGroupName $rgName -StorageAccountName $storageName -ModuleConfigPath 'C:/config.modules.json' -Verbose
```

Upload and install the modules specified in the given config path on the storage account $accoutName

## PARAMETERS

### -ModuleConfig
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

### -ModuleConfigPath
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

### -StorageAccountName
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

### -Environment
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

### -AutomationAccountName
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

### -ResourceGroupName
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

### -WhatIf
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

### -Confirm
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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
