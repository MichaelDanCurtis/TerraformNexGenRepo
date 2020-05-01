---
external help file: MRAzBdapDatabricks-help.xml
Module Name: MRAzBdapDatabricks
online version:
schema: 2.0.0
---

# Get-MRAzBdapDatabricksName

## SYNOPSIS
Get the name by naming convention \<Company\>-\<Application\>-\<Environment\>-\<MRLocation\>-\<Description and/or Incremental Number\>

## SYNTAX

```
Get-MRAzBdapDatabricksName [-Company] <String> [-Application] <String> [-Environment] <String>
 -MrLocation <String> -Descriptor <String> [-Delimiter <String>] [-CHARACTER_NAME_LIMIT <Int32>]
 [<CommonParameters>]
```

## DESCRIPTION
Naming patterns lowercase \<Company\>-\<Application\>-\<Environment\>-\<MRLocation\>-\<Description and/or Incremental Number\>

Examples:
- mr-bdap-prd-we-databricks

## EXAMPLES

### EXAMPLE 1
```
Get-MRAzBdapDatabricksName -Company 'MR' -Application 'BDAP' -Environment 'SBX' -MrLocation 'We' -Description 'usecase1'
```

Generates naming conveniton:'mr-bdap-prd-we-databricks'

## PARAMETERS

### -Company
Name of Company - e.g.
MR

```yaml
Type: String
Parameter Sets: (All)
Aliases: Co

Required: True
Position: 1
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
Position: 2
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
Position: 3
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -MrLocation
Name of MrLocation - e.g.
we (Get-MrAzBdapSharedLocation -Loation $Location)

```yaml
Type: String
Parameter Sets: (All)
Aliases:

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

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
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

### -CHARACTER_NAME_LIMIT
Maximum character limit of component = 16

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 30
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
