---
external help file: MRAzBdapDatabricks-help.xml
Module Name: MRAzBdapDatabricks
online version:
schema: 2.0.0
---

# New-MRAzBdapDatabricksClusterConnection

## SYNOPSIS
connection to an Azure Databricks instance by using  PAT and  URL.

## SYNTAX

```
New-MRAzBdapDatabricksClusterConnection [-BaseURI] <Uri> [-AccessToken] <String> [[-Protocol] <String>]
 [-UseBasicParsing] [<CommonParameters>]
```

## DESCRIPTION
This function returns a connection object that is required for all other functions in this module, and this function should be the first thing you
call to return a connection object.
Supports PS5 and PSCore 6, and different TLS configurations for HTTPS.

## EXAMPLES

### EXAMPLE 1
```
$Connection = New-MrAzBdapDatabricksClusterConnection -BaseURI https://eastus2.azuredatabricks.net -AccessToken x
```

Creates a new connection object in $Connection that contains your base URI and API key for all other functions in the module.

## PARAMETERS

### -BaseURI
{{ Fill BaseURI Description }}

```yaml
Type: Uri
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AccessToken
Your Azure Databricks access token.PAT

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

### -Protocol
If needed you can specify a TLS or SSL protocol, or "All." Use this if you receive certificate and/or HTTPS errors with your current security settings.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -UseBasicParsing
A pass-thru parameter for the underlying Invoke-WebRequest functions these functions rely on.
Use if needed.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
