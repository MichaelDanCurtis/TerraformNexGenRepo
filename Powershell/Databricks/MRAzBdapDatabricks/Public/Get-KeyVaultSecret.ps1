function Get-KeyVaultSecret {
    <#
    .SYNOPSIS
    Returns the used KeyVault secrets

    .DESCRIPTION
    Returns the used KeyVault secrets
    Can be configured in PowerShellfile (KeyVaultSecrets.psd1) in root

    .EXAMPLE
    Get-MRAzBdapKeyVaulSecret
    $Secret
    #>

    [CmdletBinding()]
    param (

    )

    begin {
        $moduleBase = $script:MyInvocation.MyCommand.Path
        $moduleDir = Split-Path $moduleBase
        $KeyVaultSecrets = Import-LocalizedData -BaseDirectory $moduleDir -FileName KeyVaultSecrets
    }

    process {
        $KeyVaultSecrets
    }

    end {
    }
}