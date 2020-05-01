<#
.SYNOPSIS
Remove an application/service principal by name

.DESCRIPTION
Try to remove both the application and service principal
If a vaultname is provided, also try to remove any AppId/Secret/AccessKey entries

.PARAMETER SPName
Name of the service principal to remove

.PARAMETER VaultName
Name of the vault to search secrets in to remove

.PARAMETER Confirm
Will promt user to confirm the action to create invasible commands

.PARAMETER WhatIf
Dry run of the script

.EXAMPLE
Remove-MRAzBdapAutomationAccountApplicationByName -SPName $clientSPName -VaultName $VaultName

Remove the provided SP and its encapsulating application as well as any secret in the keyvault refercing them
#>

function Remove-ApplicationByName {

    [CmdletBinding(
        SupportsShouldProcess = $true
    )]
    param(
        [Parameter(Mandatory = $true)]
        [string] $SPName,
        [Parameter(Mandatory = $false)]
        [string] $VaultName
    )

    Write-Verbose "$SPName SP"
    $Sp = Get-AzADServicePrincipal -DisplayName $SpName

    if ($Sp) {
        Write-Verbose "SP: Found by name $SpName"
        if ($PSCmdlet.ShouldProcess("Service principal", "remove")) {
            Remove-AzADServicePrincipal -ObjectId $Sp[0].Id -Force
        }
        Write-Verbose "SP: $SPName deleted"
    }
    else {
        Write-Warning "SP: None by the name $SpName found"
    }
    $Application = Get-AzADApplication -DisplayName $SpName
    if ($Application) {
        Write-Verbose "App: Found by name $SpName"
        if ($PSCmdlet.ShouldProcess("Application", "remove")) {
            Remove-AzADApplication -ApplicationId $Application[0].ApplicationId -Force
        }
        Write-Verbose "App: $SPName deleted"
    }
    else {
        Write-Warning "App: None by the name $SpName found"
    }
    try {
        Write-Verbose "Bin: Try empty bin"
        if ($PSCmdlet.ShouldProcess("Recycle bin", "empty")) {
            Remove-AzureADMSDeletedDirectoryObject -Id $Application[0].ObjectId
        }
        Write-Verbose "Bin: $SPName deleted"
    }
    catch {
        Write-Warning "Bin: Unable to remove app $SPName from bin"
    }

    if ($VaultName) {

        $suffixSet = @('Password')

        foreach ($suffix in $suffixSet) {
            # By default schema
            Remove-SecretByName -secretName "$SpName-$suffix" -vaultName $VaultName
        }
        Write-Verbose "###"
    }
}
function Remove-SecretByName {

    [CmdletBinding(
        SupportsShouldProcess = $true
    )]
    param(
        [string] $secretName,
        [string] $vaultName
    )

    if (Get-AzKeyVaultSecret -VaultName $VaultName -Name $secretName -ErrorAction Stop) {
        try {
            Write-Verbose "Secret: Try remove secret '$secretName'"
            if ($PSCmdlet.ShouldProcess("Secret by name '$secretName'", "remove")) {
                Remove-AzKeyVaultSecret -VaultName $VaultName -Name $secretName -PassThru -Force
            }
        }
        catch {
            Write-Warning "Secret: Unable to remove secret by name '$secretName' key"
        }
    }
    elseif (Get-AzKeyVaultSecret -VaultName $VaultName -Name $secretName.ToLower() -ErrorAction Stop) {
        try {
            Write-Verbose ("Secret: Try remove secret '{0}'" -f $secretName.ToLower())
            if ($PSCmdlet.ShouldProcess(("Secret by name '{0}'" -f $secretName.ToLower()), "Remove")) {
                Remove-AzKeyVaultSecret -VaultName $VaultName -Name $secretName.ToLower() -PassThru -Force
            }
        }
        catch {
            Write-Warning ("Secret: Unable to remove toLower secret by name '{0}' key" -f $secretName.ToLower())
        }
    }
    else {
        Write-Verbose "Secret: No secret by name '$secretName' in key vault"
    }
}
