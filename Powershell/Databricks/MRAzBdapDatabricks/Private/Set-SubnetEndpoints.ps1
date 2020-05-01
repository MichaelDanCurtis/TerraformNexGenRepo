function Set-SubnetEndpoints {

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
        [string] $Vnetresoursegroup,
        [Parameter(Mandatory = $true)]
        [string] $Nsg,
        [Parameter(Mandatory = $true)]
        [string] $nsgRg

    )



    Write-Verbose "Adding service end points to $privatesubnet   and $publicsubnet "



    try {
        $subnetlist = New-Object 'System.Collections.Generic.List[String]'
        $subnetlist.AddRange([String[]]($privatesubnet , $publicsubnet))
        $vnet = Get-AzVirtualNetwork -Name $Vnetname -ResourceGroupName $Vnetresoursegroup

        $EPlist = New-Object 'System.Collections.Generic.List[String]'
        $EPlist.AddRange([String[]]("Microsoft.Storage", "Microsoft.KeyVault", "Microsoft.Sql", "Microsoft.EventHub"))
        $nsgobj = Get-AzNetworkSecurityGroup -Name  $Nsg -ResourceGroupName $nsgRg
        $nsgid = $nsgobj.Id;

        foreach ($SN in $subnetlist) {
            Write-Verbose "Adding service end points to  subnet:-  $SN"

            #Get vnet
            $VirtualNetwork = Get-AzVirtualNetwork -ResourceGroupName $Vnetresoursegroup -Name $Vnetname | Get-AzVirtualNetworkSubnetConfig -Name $SN
            $SAP = $VirtualNetwork.AddressPrefix
            #Get existing service endpoints
            $ServiceEndPoint = New-Object 'System.Collections.Generic.List[String]'
            $VirtualNetwork.ServiceEndpoints | ForEach-Object { $ServiceEndPoint.Add($_.service) }

            foreach ($ep in $EPlist) {
                if (!$ServiceEndPoint.Contains($ep)) {
                    $ServiceEndPoint.Add($ep)
                }

            }


            #-Delegation : If we do not get deligation and pass on . it will be set to none . so get it and send it :(
            $privatesubnetobj = Get-AzVirtualNetworkSubnetConfig -Name $SN -VirtualNetwork $vnet
            $pdeligation = Get-AzDelegation -Subnet $privatesubnetobj

            #Add new service endpoint
            Get-AzVirtualNetwork -ResourceGroupName $Vnetresoursegroup -Name $Vnetname | Set-AzVirtualNetworkSubnetConfig -Name  $SN -Delegation $pdeligation  -AddressPrefix $SAP -ServiceEndpoint $ServiceEndPoint -NetworkSecurityGroupId $nsgid | Set-AzVirtualNetwork
        }
    }
    catch [Exception] {
        Write-Error "$($_.Exception) found"
        Write-Verbose "$($_.ScriptStackTrace)"
        throw $_
    }


}