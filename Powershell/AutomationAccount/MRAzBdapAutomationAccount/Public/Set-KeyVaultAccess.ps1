function Set-KeyVaultAccess {
    <#
    .SYNOPSIS
    Sets access policy to key vaults for a service principal

    .DESCRIPTION
    By default, target key vaults are defined by the naming convention, calculated from Company and Application parameters. All region are always included and the environment is derived from the current context.
    As an alternative it is possible to provide a list of key vaults.

    The list of permissions is configured in the ModuleConfig.psd1 file

    .PARAMETER ServicePrincipalName
    Display name of the Service Principal

    .PARAMETER Company
    Company identifier - e.g. MR

    .PARAMETER Application
    Application identifier - e.g. BDAP

    .PARAMETER KeyVault
    Array of target key vaults

    .PARAMETER Confirm
    Will promt user to confirm the action to create invasible commands

    .PARAMETER WhatIf
    Dry run of the script

    .EXAMPLE
     Set-MrAzBdapAutomationAccountKeyVaultAccess -ServicePrincipalName $Sp.DisplayName -Application $Application -Company $Company

     Assigns permissions in all the key vault that follow the naming convention "[company]-[application]-*"

    .EXAMPLE
    Set-MrAzBdapAutomationAccountKeyVaultAccess -ServicePrincipalName $Sp.DisplayName -KeyVault @("mr-bdap-tt-we","mr-bdap-tt-eus2")

    Assigns permissions in all the listed key vaults
    #>

    [CmdletBinding(
        SupportsShouldProcess = $true,
        DefaultParameterSetName = 'Default'
    )]
    param (
        [Parameter(Mandatory = $true)]
        [string]$ServicePrincipalName,

        [Parameter(
            Mandatory = $true,
            ParameterSetName = 'Default'
        )]
        [Alias("Co")]
        [string]$Company,

        [Parameter(
            Mandatory = $true,
            ParameterSetName = 'Default'
        )]
        [Alias("App")]
        [string]$Application,

        [Parameter(
            Mandatory = $true,
            ParameterSetName = 'KeyVault'
        )]
        [string[]]$KeyVault
    )

    begin {
        $KeyVaultPermissions = $Script:CONFIG.KeyVaultPermissions
        $KeyPermissions = $KeyVaultPermissions.Key
        $SecretPermissions = $KeyVaultPermissions.Secret
        $CertificatePermissions = $KeyVaultPermissions.Certificate
    }
    process {
        $ServicePrincipalName = (Get-AzADServicePrincipal -DisplayName $ServicePrincipalName).ApplicationId
        [array]$KeyVaultList = Get-AzKeyVault
        if ($PSCmdlet.ParameterSetName -eq 'Default') {
            [array]$KeyVaultList = $KeyVaultList | Where-Object { $_.VaultName -like "$Company-$Application-*" }
        }
        else {
            [array]$KeyVaultList = $KeyVaultList | Where-Object { $KeyVault -contains $_.VaultName }
        }

        Foreach ($KV in $KeyVaultList) {

            if ($PSCmdlet.ShouldProcess("Key Vault $($KV.VaultName )", "Set Access Policy")) {
                $null = Set-AzKeyVaultAccessPolicy -VaultName $KV.VaultName -ResourceGroupName $KV.ResourceGroupName -ServicePrincipalName $ServicePrincipalName -PermissionsToKeys $KeyPermissions -PermissionsToSecrets $SecretPermissions -PermissionsToCertificates $CertificatePermissions
                Write-Verbose "$($Sp.DisplayName) was granted Key permissions on Vault $($KV.VaultName): $($KeyPermissions -join ", ")"
                Write-Verbose "$($Sp.DisplayName) was granted Secret permissions on Vault $($KV.VaultName): $($SecretPermissions -join ", ")"
                Write-Verbose "$($Sp.DisplayName) was granted Certificate permissions on Vault $($KV.VaultName): $($CertificatePermissions -join ", ")"
            }
        }
    }
}