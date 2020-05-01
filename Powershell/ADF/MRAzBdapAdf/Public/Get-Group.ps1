
function Get-Group {
    <#
    .SYNOPSIS

    Queries the provided AD group in Azure by Name

    .DESCRIPTION
    Queries the provided AD group in Azure by Name

    .PARAMETER GroupName
    Name of the AzureAD group

    .EXAMPLE
    Get-MRAzBdapLaGroup -GroupdName Fun-CED-bdap-dev-apac-oms-reader
    Group

    #>

    [CmdletBinding()]
    param(
        # Group Name to be searched
        [Parameter(Mandatory)]
        [string] $GroupName
    )

    Write-Verbose "[$(Get-Date)] Use $GroupName"

    if (!$GroupName) {
        throw [ArgumentException] "Illegal Name $GroupName"
    }

    $Group = Get-AzADGroup -DisplayName $GroupName -ErrorAction Stop

    if (!$Group) {
        throw "Group not found! $GroupName"
    }

    if ($Group.Count -gt 1) {
        throw "Ambigous group name $GroupName, multiple groups found $Group"
    }

    $Group
}