class AzureDatabricksJobStatusClusterInfo {
    [string] $ClusterID
    [string] $SparkContextID

    [String] ToString()
    {
        return "{ClusterID: " + $this.ClusterID + ", SparkContextID: " + $this.SparkContextID + "}"
    }

}