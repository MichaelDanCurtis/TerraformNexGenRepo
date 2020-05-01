function New-ApiRequest {
    <#
        .SYNOPSIS
            this is the main helper class for all the databricks API connections
        .DESCRIPTION
             this is the main helper class for all the databricks API connections
        .PARAMETER Uri
            The base URI of the API path being called
        .PARAMETER AccessToken
            The required access token that has been created to allow access to the Databricks API (see: https://docs.databricks.com/api/latest/authentication.html)
            TODO: As of now it depands on PAT token , first time genration of PAT token looks like manual as of now. Need to check it further
        .PARAMETER RequestMethod
             GET or POST
        .PARAMETER ExpectingNoReply
            Should the response from the API be parsed or ignored? Some API calls return empty JSON objects that cannot be parsed like most other responses. This optional switch
            tells our request that we should "ignore" the response from the API
        .PARAMETER UseBasicParsing
            How should we handle the response from the API (robust or basic)?

        .LINK

        .EXAMPLE
    #>
    Param (
        [Parameter(Mandatory = $true)] [uri] $Uri,
        [Parameter(Mandatory = $true)] [string] $AccessToken,
        [Parameter(Mandatory = $false)] [ValidateSet("GET", "POST")] [string] $RequestMethod = "GET",
        [Parameter(Mandatory = $false)] [switch] $ExpectingNoReply,
        [Parameter(Mandatory = $false)] [bool] $UseBasicParsing = $False
    )

    process {
        $DatabricksRequestObject = New-Object DatabricksRequestObject
        $DatabricksRequestObject.RequestURI = $Uri
        $DatabricksRequestObject.RequestMethod = $RequestMethod
        if ($UseBasicParsing -eq $True) {
            $DatabricksRequestObject.UseBasicParsing = $True
        }
        $DatabricksRequestObject.AddHeader("Authorization", "Bearer $AccessToken")
        if ($ExpectingNoReply) {
            $DatabricksRequestObject.IgnoreResponse = $True
        }
        $DatabricksRequestObject
    }
}