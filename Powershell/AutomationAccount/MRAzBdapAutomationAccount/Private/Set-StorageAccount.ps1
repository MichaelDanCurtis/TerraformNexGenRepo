
function Set-StorageAccount {

    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true)]
        [string] $StorageAccountName
    )

    $StorageAccount = Get-AzResource -Name $StorageAccountName -ResourceType "Microsoft.Storage/storageAccounts" -ErrorAction Stop
    Write-Verbose "Got Storage account $StorageAccountName"
    if ($PSCmdlet.ShouldProcess("Storage Account context to '$StorageAccountName'", "Set")) {
        $null = Set-AzCurrentStorageAccount -Name $StorageAccountName -ResourceGroupName $StorageAccount.ResourceGroupName -ErrorAction SilentlyContinue
    }
}
