function Set-Subnetdelegation {

    [CmdletBinding(
        SupportsShouldProcess = $true,
        DefaultParameterSetName = "Default"
    )]
    param(
        [Parameter(Mandatory = $true)]
        [string] $privatesubnet,

        [Parameter(Mandatory = $true)]
        [string] $publicsubnet,

        [Parameter(Mandatory = $true)]
        [string] $Vnetname,

        [Parameter(Mandatory = $true)]
        [string] $Vnetresoursegroup
    )



    Write-Verbose "deligate subnets $privatesubnet to Microsoft.Databricks/workspaces "


    $delgateto = "Microsoft.Databricks/workspaces"

    try {

        $vnet = Get-AzVirtualNetwork -Name $Vnetname -ResourceGroupName $Vnetresoursegroup


        $privatesubnetobj = Get-AzVirtualNetworkSubnetConfig -Name $privatesubnet -VirtualNetwork $vnet
        $pdeligation = Get-AzDelegation -Subnet $privatesubnetobj
        $delegateservicename = $pdeligation.ServiceName

        if ( $delegateservicename -ne $delgateto ) {
            Add-AzDelegation -Name "databricksDel"  -ServiceName "Microsoft.Databricks/workspaces" -Subnet $privatesubnetobj
            Set-AzVirtualNetwork -VirtualNetwork $vnet
        }


        Write-Verbose "deligate subnets $publicsubnet to Microsoft.Databricks/workspaces "


        $vnet = Get-AzVirtualNetwork -Name $Vnetname -ResourceGroupName $Vnetresoursegroup

        $publicsubnetobj = Get-AzVirtualNetworkSubnetConfig -Name $publicsubnet -VirtualNetwork $vnet
        $pdeligation = Get-AzDelegation -Subnet $publicsubnetobj
        $delegateservicename = $pdeligation.ServiceName

        if ( $delegateservicename -ne $delgateto ) {
            Add-AzDelegation -Name "databricksDel"  -ServiceName "Microsoft.Databricks/workspaces" -Subnet $publicsubnetobj
            Set-AzVirtualNetwork -VirtualNetwork $vnet
        }
    }
    catch [Exception] {
        Write-Error "$($_.Exception) found"
        Write-Verbose "$($_.ScriptStackTrace)"
        throw $_
    }


}