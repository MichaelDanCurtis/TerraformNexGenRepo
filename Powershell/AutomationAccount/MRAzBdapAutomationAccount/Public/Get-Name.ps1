#REQUIRES -Version 5.0
#REQUIRES #-Modules
#REQUIRES #-RunAsAdministrator
function Get-Name {
    <#
        .SYNOPSIS
        Get the azure automation account name by naming convention <Company>-<Application>-<Environment>

        .DESCRIPTION
        Naming patterns <Company>-<Application>-<Environment>

        Examples:
        - mr-bdap-dev
        - mr-bdap-sbx

        Notes:
        There is only one Azure Automation Account for every <Environment> which is always deployed to "West Europe"
        There is also only one Service Account used for every <Environment> - e.g. Ser-CEP-bd<Environment>auto

        .EXAMPLE
        Get-MRAzBdapAutomationAccountName -Company 'MR' -Application 'BDAP'  -Environment 'SBX'

        Generates naming conveniton:'mr-bdap-tt'

        .PARAMETER Company
        Name of Company - e.g. MR

        .PARAMETER Application
        Name of Application - e.g. BDAP

        .PARAMETER Environment
        Name of Environment - e.g. SBX
        [ValidateSet("prd", "int", "dev", "sbx", "tt")]

        .PARAMETER Descriptor
        Descriptor if needed, incremental value or description

        .PARAMETER Delimiter
        Delimiter if needed
    #>

    [CmdletBinding(DefaultParameterSetName = "Default")]
    [OutputType([String])]
    param(
        [Parameter(Mandatory = $true)]
        [Alias("Co")]
        [ValidateNotNullOrEmpty()]
        [string]  $Company,

        [Parameter(Mandatory = $true)]
        [Alias("App")]
        [ValidateNotNullOrEmpty()]
        [string] $Application,

        [Parameter(Mandatory = $true)]
        [ValidateSet("prd", "int", "dev", "sbx", "tt")]
        [Alias("Env")]
        [ValidateNotNullOrEmpty()]
        [string] $Environment,

        [Parameter(Mandatory = $false)]
        [AllowEmptyString()]
        [string]$Descriptor = "",

        [Parameter(Mandatory = $false)]
        [ValidatePattern("(\-|\s)")] # matches dash or space
        [ValidateLength(1, 1)]
        [string] $Delimiter = "-"
    )

    process {

        $ComponentName = ("{1}{0}{2}{0}{3}{0}{4}" -f $Delimiter, $Company.ToLower(), $Application.ToLower(), $Environment.ToLower(), $Descriptor.ToLower())
        $ComponentName = $ComponentName.TrimEnd($Delimiter) # In case descriptor is empty
        Write-Verbose  "Created ComponentName $ComponentName"

        Write-Output $ComponentName
    }
}