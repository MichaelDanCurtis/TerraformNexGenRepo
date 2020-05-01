---
external help file: MRAzBdapAutomationAccount-help.xml
Module Name: MRAzBdapAutomationAccount
online version:
schema: 2.0.0
---

# Get-MRAzBdapAutomationAccountName

## SYNOPSIS
Get the azure automation account name by naming convention \<Company\>-\<Application\>-\<Environment\>

## SYNTAX

```
Get-MRAzBdapAutomationAccountName -Company <String> -Application <String> -Environment <String>
 [-Descriptor <String>] [-Delimiter <String>] [<CommonParameters>]
```

## DESCRIPTION
Naming patterns \<Company\>-\<Application\>-\<Environment\>

Examples:
- mr-bdap-dev
- mr-bdap-sbx

Notes:
There is only one Azure Automation Account for every \<Environment\> which is always deployed to "West Europe"
There is also only one Service Account used for every \<Environment\> - e.g.
Ser-CEP-bd\<Environment\>auto

## EXAMPLES

### EXAMPLE 1
```
Get-MRAzBdapAutomationAccountName -Company 'MR' -Application 'BDAP'  -Environment 'SBX'
```

Generates naming conveniton:'mr-bdap-tt'

## PARAMETERS

### -Company
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

### -Application
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

### -Environment
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

### -Descriptor
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

### -Delimiter
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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.String
## NOTES

## RELATED LINKS
