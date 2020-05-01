---
external help file: MRAzBdapAutomationAccount-help.xml
Module Name: MRAzBdapAutomationAccount
online version:
schema: 2.0.0
---

# New-MRAzBdapAutomationAccountConnection

## SYNOPSIS
Creates an Azure Automation connection

## SYNTAX

```
New-MRAzBdapAutomationAccountConnection [-Environment] <String> [[-MrLocation] <String>]
 [-AutomationAccountName] <String> [-ResourceGroupName] <String> [[-ConnectionName] <String>]
 [[-CertificateSubject] <String>] [[-Company] <String>] [[-Application] <String>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
Creates an Azure Automation connection of type AzureServicePrincipal, named 'AzureRunAsConnection', with Contributor role on the subscription.

## EXAMPLES

### EXAMPLE 1
```
New-MRAzBdapAutomationAccount -Environment 'tt' -MrLocation 'we' -AutomationAccountName 'mr-bdap-tt' -ResourceGroupName 'MR-BDAP-WE-TT-AUTO'
```

Creates a Connection for the Automation Account  'mr-bdap-tt'

## PARAMETERS

### -Environment
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

### -MrLocation
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

### -AutomationAccountName
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

### -ResourceGroupName
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

### -ConnectionName
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

### -CertificateSubject
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

### -Company
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

### -Application
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

### Microsoft.Azure.Commands.Automation.Model.Connection
## NOTES

## RELATED LINKS
