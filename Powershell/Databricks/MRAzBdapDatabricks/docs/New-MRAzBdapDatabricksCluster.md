---
external help file: MRAzBdapDatabricks-help.xml
Module Name: MRAzBdapDatabricks
online version:
schema: 2.0.0
---

# New-MRAzBdapDatabricksCluster

## SYNOPSIS
Returns an object representing defined Azure Databricks clusters.

## SYNTAX

```
New-MRAzBdapDatabricksCluster [-Connection] <Object> [-config] <PSObject> [[-ClusterID] <String>]
 [<CommonParameters>]
```

## DESCRIPTION
Returns an object representing defined Azure Databricks clusters.
If a cluster ID is supplied, it will filter for a specific cluster, otherwise it will return an
array of cluster objects.

## EXAMPLES

### EXAMPLE 1
```
NEw-MRAzbdapDatabricksCluster -Connection $Connection - config $config
```

Returns an array of Databricks cluster objects defined in the Azure databricks instance defined in $Connection

### EXAMPLE 2
```

```

## PARAMETERS

### -Connection
An object that represents an Azure Databricks API connection where you want to get your clusters from.

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -config
{{ Fill config Description }}

```yaml
Type: PSObject
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ClusterID
The cluster ID of the specific databricks cluster you want to return.

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
