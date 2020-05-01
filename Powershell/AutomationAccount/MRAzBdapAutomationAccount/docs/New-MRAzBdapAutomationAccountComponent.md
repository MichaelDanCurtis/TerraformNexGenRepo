---
external help file: MRAzBdapAutomationAccount-help.xml
Module Name: MRAzBdapAutomationAccount
online version:
schema: 2.0.0
---

# New-MRAzBdapAutomationAccountComponent

## SYNOPSIS
Creates the azure automation account

## SYNTAX

```
New-MRAzBdapAutomationAccountComponent [-ComponentName] <String> [-ResourceGroupName] <String>
 [-LogAnalyticsWorkspace] <String> [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Creates the azure automation account

## EXAMPLES

### EXAMPLE 1
```
New-MRAzBdapAutomationAccountComponent -ResourceGroupName 'MR-BDAP-WE-TT-AUTO' -ComponentName 'mr-bdap-tt' -LogAnalyticsWorkspace $la
```

Creates an Azure Automation Account named after the parameter ComponentName.
Az module an RunAsConnection will be added automatically.

## PARAMETERS

### -ComponentName
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

### -ResourceGroupName
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

### -LogAnalyticsWorkspace
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

### Microsoft.Azure.Commands.ResourceManager.Cmdlets.SdkModels.PSResourceGroupDeployment
## NOTES
There is only one Azure Automation Account for every \<Environment\> which is always deployed to "West Europe"
There is also only one Service Account used for every \<Environment\> - e.g.
Ser-CEP-bd\<Environment\>auto

## RELATED LINKS
