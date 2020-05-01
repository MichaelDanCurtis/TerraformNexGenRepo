---
external help file: MRAzBdapAutomationAccount-help.xml
Module Name: MRAzBdapAutomationAccount
online version:
schema: 2.0.0
---

# Set-MRAzBdapAutomationAccountUp

## SYNOPSIS
Create an AutomationAccount with MunichRE specific post-deployment conditions

## SYNTAX

### Config
```
Set-MRAzBdapAutomationAccountUp -Config <PSObject> [-WhatIf] [-Confirm] [<CommonParameters>]
```

### ConfigPath
```
Set-MRAzBdapAutomationAccountUp -configPath <String> [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Create an AutomationAccount with MunichRE specific post-deployment conditions

## EXAMPLES

### EXAMPLE 1
```
Set-MRAzBdapAutomationAccountUp -Config $config
```

Deploy an AutomationAccount with a given configuration

## PARAMETERS

### -Config
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

### -configPath
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

### -WhatIf
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

### -Confirm
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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
