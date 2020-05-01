function Set-LogAnalyticsWorkspace {
    [CmdletBinding(
        SupportsShouldProcess = $true,
        DefaultParameterSetName = "Default"
    )]
    param(
        [Parameter(Mandatory = $true)]
        [string] $LogAnalyticsWorkspaceName,

        [Parameter(Mandatory = $true)]
        [string] $LogAnalyticsResourceGroupName,

        [Parameter(Mandatory = $true)]
        [string] $DatabricksWorkspaceName,

        [Parameter(Mandatory = $true)]
        [string] $ResourceGroupName


    )




    try {

        Write-Verbose "Adding diganostic seetings for databricks workspace  :  $DatabricksWorkspaceName "
        $enabled = $true

        $EPlist = New-Object 'System.Collections.Generic.List[String]'
        $EPlist.AddRange([String[]]("Microsoft.Storage", "Microsoft.KeyVault", "Microsoft.Sql", "Microsoft.EventHub"))
        $logAnalytics = Get-AzResource -ResourceGroupName $LogAnalyticsResourceGroupName -ResourceName $LogAnalyticsWorkspaceName -ResourceType "Microsoft.OperationalInsights/workspaces"
        $databricks = Get-AzResource -ResourceGroupName $ResourceGroupName -ResourceName $DatabricksWorkspaceName -ResourceType "Microsoft.Databricks/workspaces"
        Set-AzDiagnosticSetting -ResourceId $databricks.ResourceId -WorkspaceId $logAnalytics.ResourceId -Enabled $enabled -name "diagnosticsetting"

    }
    catch [Exception] {
        Write-Error "$($_.Exception) found"
        Write-Verbose "$($_.ScriptStackTrace)"
        throw $_
    }


}