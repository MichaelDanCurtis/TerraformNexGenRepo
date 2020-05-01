class AzureDataBricksConnection {
    [uri] $BaseURI
    [string] $AccessToken
    [string] $Protocols
    [bool] $UseBasicParsing = $False

    AzureDataBricksConnection([Uri] $BaseURI, [string] $AccessToken, [string] $Protocols, [bool] $UseBasicParsing) {
        $this.BaseURI = $BaseURI
        $this.AccessToken = $AccessToken
        $this.Protocols = $Protocols
        $this.UseBasicParsing = $UseBasicParsing
    }

    [String] ToString()
    {
        return ($this.BaseURI).ToString() + ":" + $this.AccessToken
    }
}