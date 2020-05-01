---
external help file: MRAzBdapDatabricks-help.xml
Module Name: MRAzBdapDatabricks
online version:
schema: 2.0.0
---

# Get-MRAzBdapDatabricksArmTemplate

## SYNOPSIS
Returns the link to the modules ARM template

## SYNTAX

```
Get-MRAzBdapDatabricksArmTemplate [-Path] <String> [-Source] <String> [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Returns the link to the modules ARM template
Can be configured in Modulemanifest (MRAzBdapDatabricks.psd1)  Attribute FileList = @('./static/azuredeploy.json')

## EXAMPLES

### EXAMPLE 1
```
Get-MRAzBdapDatabricksArmTemplate
```

*.\bdap-az-automation-databricks\MRAzBdapDatabricks\static\azuredeploy.json

## PARAMETERS

### -Path
Enter path to a template folder or a template file

```yaml
Type: String
Parameter Sets: (All)
Aliases: Loc

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Source
Select source as a local path or an Azure storage account

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

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

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
Prompts you for confirmation before running the cmdlet.

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
