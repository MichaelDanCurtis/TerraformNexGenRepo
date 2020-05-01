class AzureDataBricksParameterPair {
    [string] $Key
    [string] $Value

    [string] ToString() {
        return $this.Key
    }
}