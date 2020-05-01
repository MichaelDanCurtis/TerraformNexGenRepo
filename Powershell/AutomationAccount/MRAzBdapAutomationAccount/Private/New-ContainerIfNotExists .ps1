function New-ContainerIfNotExisting {

    [CmdletBinding(SupportsShouldProcess = $true)]
    [OutputType([String])]
    param (
        [parameter(Mandatory = $false)]
        [string] $ContainerName = $Script:CONFIG.AutomationModuleContainer
    )

    $ContainerName = $ContainerName.ToLower()
    $container = Get-AzStorageContainer -Name $ContainerName -ErrorAction SilentlyContinue
    if (!$container) {
        if ($PSCmdlet.ShouldProcess(('Container with name "{0}"' -f $ContainerName), 'Create')) {
            $container = New-AzStorageContainer -Name $ContainerName -Permission Off
        }
        Write-Verbose "New container $($ContainerName) created"
    }
    return $ContainerName
}
