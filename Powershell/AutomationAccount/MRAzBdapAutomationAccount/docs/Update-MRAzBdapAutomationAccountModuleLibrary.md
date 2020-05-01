---
external help file: MRAzBdapAutomationAccount-help.xml
Module Name: MRAzBdapAutomationAccount
online version:
schema: 2.0.0
---

# Update-MRAzBdapAutomationAccountModuleLibrary

## SYNOPSIS
Uploads the requested module from a Powershell Repository to Munich Re storage account.

## SYNTAX

### StorageAccountName
```
Update-MRAzBdapAutomationAccountModuleLibrary -StorageAccountName <String> [-ModuleName <String>]
 [-Version <String>] [-Repository <String>] [-Credential <PSCredential>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

### NoStorageAccountName
```
Update-MRAzBdapAutomationAccountModuleLibrary -Environment <String> [-ModuleName <String>] [-Version <String>]
 [-Repository <String>] [-Credential <PSCredential>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Uploads the requested module to Munich Re storage account.
The storage account changes based on the environment and is configurable in the ModuleConfig.psd1 file.

## EXAMPLES

### EXAMPLE 1
```
Update-MRAzBdapAutomationAccount -Environment PRD
```

Uploads Az module (with all dependencies), latest version

### EXAMPLE 2
```
Update-MRAzBdapAutomationAccount -Environment PRD -ModuleName AzureAD -Version 2.0.2.16
```

Uploads AzureAD module, version 2.0.2.16

### EXAMPLE 3
```
Update-MRAzBdapAutomationAccountModuleLibrary -Environment PRD -ModuleName MRAzBdapDsvm -Repository bdap_nuget_releases -Credential $Creds
```

Uploads MRAzBdapDsvm module (with all dependencies), latest version, from bdap PS repository.

## PARAMETERS

### -StorageAccountName
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

### -Environment
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

### -ModuleName
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

### -Version
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

### -Repository
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

### -Credential
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

### System.String
## NOTES

## RELATED LINKS
