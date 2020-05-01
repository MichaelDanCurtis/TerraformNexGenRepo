function New-ClusterConnection {
<#
        .SYNOPSIS
             connection to an Azure Databricks instance by using  PAT and  URL.
        .DESCRIPTION
            This function returns a connection object that is required for all other functions in this module, and this function should be the first thing you
            call to return a connection object. Supports PS5 and PSCore 6, and different TLS configurations for HTTPS.
        .PARAMETER BaseUI
            base URI(e.g. https://eastus2.azuredatabricks.net)
        .PARAMETER AccessToken
            Your Azure Databricks access token.PAT
        .PARAMETER Protocol
            If needed you can specify a TLS or SSL protocol, or "All." Use this if you receive certificate and/or HTTPS errors with your current security settings.
        .PARAMETER UseBasicParsing
            A pass-thru parameter for the underlying Invoke-WebRequest functions these functions rely on. Use if needed.
        .NOTES

        .LINK

        .EXAMPLE
            PS C:\> $Connection = New-MrAzBdapDatabricksClusterConnection -BaseURI https://eastus2.azuredatabricks.net -AccessToken x
            Creates a new connection object in $Connection that contains your base URI and API key for all other functions in the module.
    #>
    Param (
        [Parameter(Mandatory=$true)] [Uri] $BaseURI,
        [Parameter(Mandatory=$true)] [string] $AccessToken,
        [Parameter(Mandatory=$false)] [ValidateSet('SSL3','TLS','TLS11','TLS12','All')] [string] $Protocol,
        [Parameter(Mandatory=$false)] [switch] $UseBasicParsing
    )

    begin {
        if ($Protocol) {
            if ($Protocol -eq "All") {
                $UseProtocols = 'SSL3,TLS,TLS11,TLS12'
            } else {
                $UseProtocols = $Protocol
            }
            $SecurityMethod = [System.Net.SecurityProtocolType]"$UseProtocols"
            [System.Net.ServicePointManager]::SecurityProtocol = $SecurityMethod
        }
    }

    process {
        $ConnectionObject = New-Object AzureDataBricksConnection($BaseURI, $AccessToken, $UseProtocols, $UseBasicParsing)
        $ConnectionObject.UseBasicParsing
        return $ConnectionObject

        <#if (Test-AzureDatabricksConnection $ConnectionObject) {
            return $ConnectionObject
        } else {
            return $null
        }#>
    }
}