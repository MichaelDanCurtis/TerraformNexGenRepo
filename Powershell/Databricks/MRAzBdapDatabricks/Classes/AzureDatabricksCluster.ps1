class AzureDatabricksCluster {
    [string] $ClusterID
    [string] $Name
    [int] $NumberOfWorkers
    [int] $AutoscaleMinWorkers
    [int] $AutoscaleMaxWorkers
    [int] $ClusterMemoryMB
    [int] $ClusterCores
    [string] $Creator
    [string] $DriverNodeTypeID
    [object] $Driver
    [string] $NodeTypeID
    [object[]] $SparkNodes
    [int64] $SparkContextID
    [int] $JBDCPort
    [string] $SparkVersion
    [PSCustomObject] $SparkEnvironment
    [int] $AutoTerminateMinutes
    [bool] $EnableElasticDisk
    [string] $ClusterState
    [string] $ClusterStateMessage
    [nullable[datetime]] $StartTime
    [nullable[datetime]] $TerminatedTime
    [nullable[datetime]] $LastStateLossTime
    [nullable[datetime]] $LastActivityTime
    [string] $TerminationCode
    [PSCustomObject] $Tags
}