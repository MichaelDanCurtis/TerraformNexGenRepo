function New-Cluster {
    <#
        .SYNOPSIS
            Returns an object representing defined Azure Databricks clusters.
        .DESCRIPTION
            Returns an object representing defined Azure Databricks clusters. If a cluster ID is supplied, it will filter for a specific cluster, otherwise it will return an
            array of cluster objects.
        .PARAMETER Connection
            An object that represents an Azure Databricks API connection where you want to get your clusters from.
        .PARAMETER ClusterID
            The cluster ID of the specific databricks cluster you want to return.

        .LINK

        .EXAMPLE
            PS C:\> NEw-MRAzbdapDatabricksCluster -Connection $Connection - config $config
            Returns an array of Databricks cluster objects defined in the Azure databricks instance defined in $Connection

        .EXAMPLE


        #>
    Param (
        [Parameter(Mandatory=$true)] [object] $Connection,
        [Parameter(Mandatory=$true)] [pscustomobject] $config,
        [Parameter(Mandatory=$false)] [string] $ClusterID
    )

    begin {
        if ($ClusterID) {
            $TargetURI = $Connection.BaseURI.AbsoluteUri + "api/2.0/clusters/get?cluster_id=$ClusterID"
        } else {
            $TargetURI = $Connection.BaseURI.AbsoluteUri + "api/2.0/clusters/create"
        }
    }

    process {
        try
        {
        $ClusterRequest =  New-ApiRequest  -Uri $TargetURI -AccessToken $Connection.AccessToken -UseBasicParsing $Connection.UseBasicParsing -RequestMethod POST

        $ClusterRequest.IgnoreResponse=$True #TODO : need to read the cluster Id
        $ClusterRequest.AddJsonBody($config)

        $ClusterResponse = $ClusterRequest.Submit()
    }
    catch [Exception] {
        Write-Error "$($_.Exception) found"
        Write-Verbose "$($_.ScriptStackTrace)"
        throw $_
    }

    }
}