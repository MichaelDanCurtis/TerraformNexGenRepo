---
external help file: MRAzBdapAutomationAccount-help.xml
Module Name: MRAzBdapAutomationAccount
online version:
schema: 2.0.0
---

# Install-MRAzBdapAutomationAccountRunbook

## SYNOPSIS
Iterates through a given path
- searching for a folder called Runbook
- itereates through each file in given runbook folder
- checks if its a runbook (by name - excludes test)
- uploades runbook given the file name (without type)
    - publish
    - sets logging and tracing on

## SYNTAX

```
Install-MRAzBdapAutomationAccountRunbook [-Path] <String> [-AutomationAccountName] <String>
 [-ResourceGroupName] <String> [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Iterates through a given path
- searching for a folder called Runbook
- itereates through each file in given runbook folder
- checks if its a runbook (by name - excludes test)
- uploades runbook given the file name (without type)
    - publish
    - sets logging and tracing on

## EXAMPLES

### EXAMPLE 1
```
Install-MRAzBdapAutomationAccountRunbook -Path $Path -AutomationAccount $AutomationAccountName -ResourceGroupName $ResourceGroupName -Verbose
```

Uploads the runbooks found in Path to given AutomationAccount

## PARAMETERS

### -Path
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

### -AutomationAccountName
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

### -ResourceGroupName
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
