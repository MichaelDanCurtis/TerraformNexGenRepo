---
external help file: MRAzBdapAutomationAccount-help.xml
Module Name: MRAzBdapAutomationAccount
online version:
schema: 2.0.0
---

# Set-MRAzBdapAutomationAccountKeyVaultAccess

## SYNOPSIS
Sets access policy to key vaults for a service principal

## SYNTAX

### Default (Default)
```
Set-MRAzBdapAutomationAccountKeyVaultAccess -ServicePrincipalName <String> -Company <String>
 -Application <String> [-WhatIf] [-Confirm] [<CommonParameters>]
```

### KeyVault
```
Set-MRAzBdapAutomationAccountKeyVaultAccess -ServicePrincipalName <String> -KeyVault <String[]> [-WhatIf]
 [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
By default, target key vaults are defined by the naming convention, calculated from Company and Application parameters.
All region are always included and the environment is derived from the current context.
As an alternative it is possible to provide a list of key vaults.

The list of permissions is configured in the ModuleConfig.psd1 file

## EXAMPLES

### EXAMPLE 1
```
Set-MrAzBdapAutomationAccountKeyVaultAccess -ServicePrincipalName $Sp.DisplayName -Application $Application -Company $Company
```

Assigns permissions in all the key vault that follow the naming convention "\[company\]-\[application\]-*"

### EXAMPLE 2
```
Set-MrAzBdapAutomationAccountKeyVaultAccess -ServicePrincipalName $Sp.DisplayName -KeyVault @("mr-bdap-tt-we","mr-bdap-tt-eus2")
```

Assigns permissions in all the listed key vaults

## PARAMETERS

### -ServicePrincipalName
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

### -Company
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

### -Application
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

### -KeyVault
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
