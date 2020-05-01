class DatabricksRequestObject {
    [string] $RequestURI
    [string] $RequestMethod
    [hashtable] $RequestHeaders = [pscustomobject] @{}
    [hashtable] $RequestBody = [pscustomobject] @{}
    [bool] $IgnoreResponse = $False
    [bool] $UseBasicParsing = $False
    hidden $RequestResponse
    hidden [int] $UnavailableRetries = 0
    hidden [int] $MaxUnavailableRetries = 5
    hidden [string] $RawResponse 

    AddHeader([string] $Key, [string] $Value) {
        $this.RequestHeaders.Add($key, $Value)
    }

    AddBody([string] $key, $Value) {
        $this.RequestBody.Add($key, $Value)                
    }
    $Body=$False;
    AddJsonBody($Value) {
        $this.Body=$Value;
        $this.Body = $this.Body | ConvertTo-Json -Depth 20
       # $this.RequestBody.Add($key, $Value)                
    }

    [System.Object] Submit() {
        [string] $ReasonText = $null
        [string] $WhereFrom = $null

        $ResponseObject = [PSCustomObject] @{
            TimeStamp = Get-Date
            ResponseIgnored = $False
        }
        $IWRParams = @{
            URI=$this.RequestURI;
            Headers=$this.RequestHeaders;
            Method=$this.RequestMethod;
        }
        if ($this.RequestMethod -eq "POST") {
            $IWRParams.Add('Body',($this.RequestBody | ConvertTo-Json -Depth 99))
        }
        if ($this.UseBasicParsing -eq $True) {
            $IWRParams.Add('UseBasicParsing',$True)
        }
        try {

            if(!$this.Body)
            {
                $this.RawResponse = Invoke-RestMethod -Uri $this.RequestURI; -Method $this.RequestMethod -Headers $this.RequestHeaders; -Body $this.Body
                 #$this.RawResponse = Invoke-WebRequest @IWRParams
            } 
            else {
                Write-Verbose "Non-GET request - converting Body to JSON ..."               
                
                #Write-Verbose "Body: `n$($Body)"           
                $IWRParamss = @{
                    Uri=$this.RequestURI;
                    Headers=$this.RequestHeaders;
                    Method=$this.RequestMethod;
                    Body=$this.Body
                }
                
                $this.RawResponse = Invoke-RestMethod @IWRParamss
            }
                # for POST requests we have to convert the body to JSON
               


        } catch {
            if ($_.ErrorDetails.Message) {
                $ErrorMessages = ($_.ErrorDetails.Message).Split([System.Environment]::NewLine)
                $WhereFrom = $ErrorMessages | Where-Object {$_ -like "Problem Accessing*"}
                $ReasonPosition = $ErrorMessages.IndexOf($WhereFrom)
                $ReasonText = $ErrorMessages[$ReasonPosition+1].Trim()
                if ($ReasonText.Contains("TEMPORARILY_UNAVAILABLE")) {
                    $this.UnavailableRetries = $this.UnavailableRetries + 1
                    if ($this.UnavailableRetries -ge $this.MaxUnavailableRetries) {
                        $TotalRetries = $this.UnavailableRetries
                        throw "The Databricks API has been unavailable for $TotalRetries. There must be a larger issue. Please check the Databricks services."
                    } else {
                        Write-Warning "The Databricks API was temporarily unavailable. Let's wait 120 seconds and try again"
                        Start-Sleep -Seconds 120
                        $this.Submit()
                    }
                } elseif ($ReasonText.Contains("INTERNAL_ERROR")) {
                    $this.UnavailableRetries = $this.UnavailableRetries + 1
                    if ($this.UnavailableRetries -ge $this.MaxUnavailableRetries) {
                        $TotalRetries = $this.UnavailableRetries
                        throw "The Databricks API has been unavailable for $TotalRetries. There must be a larger issue. Please check the Databricks services."
                    } else {
                        Write-Warning "The Databricks API returned an internal error. Let's wait 120 seconds and try again"
                        Start-Sleep -Seconds 120
                        $this.Submit()
                    }                
                } else {
                    throw ($WhereFrom + " " + $ReasonText)
                }
            } else {
                $ErrorMessage = $_
                throw ("Generic error: $ErrorMessage")                
            }
        }
        if ($this.IgnoreResponse -eq $False) {
            $ResponseJSON = $this.RawResponse | ConvertFrom-Json
            $ReturnedProperties = $ResponseJSON | Get-Member | Where-Object {$_.MemberType -eq "NoteProperty"}
            ForEach ($r in $ReturnedProperties) {
                $ResponseObject | Add-Member -MemberType NoteProperty -Name $r.Name -Value ($ResponseJSON.($r.Name))
            }
        } else {
            $ResponseObject.ResponseIgnored = $True
        }
        return $ResponseObject
    }
}