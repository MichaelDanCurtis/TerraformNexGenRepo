function Update-ModuleLibrary {
    <#
    .SYNOPSIS
    Uploads the requested module from a Powershell Repository to Munich Re storage account.

    .DESCRIPTION
    Uploads the requested module to Munich Re storage account.
    The storage account changes based on the environment and is configurable in the ModuleConfig.psd1 file.

    .PARAMETER Environment
    Environment such as SBX (Sandbox), DEV (Development), INT (Integration), PRD (Production)

    .PARAMETER ModuleName
    Name of the Module. Default is 'Az'

    .PARAMETER Version
    Version of the module. Default is 'latest'.

    .PARAMETER Repository
    Target repository for dependency resolution

    .PARAMETER Credential
    Repository credentials

    .PARAMETER StorageAccountName
    Name of the storage account to upload modules to

    .PARAMETER Confirm
    Will promt user to confirm the action to create invasible commands

    .PARAMETER WhatIf
    Dry run of the script

    .EXAMPLE
    Update-MRAzBdapAutomationAccount -Environment PRD

    Uploads Az module (with all dependencies), latest version

    .EXAMPLE
    Update-MRAzBdapAutomationAccount -Environment PRD -ModuleName AzureAD -Version 2.0.2.16

    Uploads AzureAD module, version 2.0.2.16

    .EXAMPLE
    Update-MRAzBdapAutomationAccountModuleLibrary -Environment PRD -ModuleName MRAzBdapDsvm -Repository bdap_nuget_releases -Credential $Creds

    Uploads MRAzBdapDsvm module (with all dependencies), latest version, from bdap PS repository.
    #>

    [CmdletBinding(SupportsShouldProcess = $True)]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "StorageAccountName")]
        [string] $StorageAccountName,

        [Parameter(Mandatory = $true, ParameterSetName = "NoStorageAccountName")]
        [ValidateSet("prd", "int", "dev", "sbx", "tt", "prp", "inp", "dep", "sbp")]
        [Alias("Env")]
        [string] $Environment,

        [Parameter(Mandatory = $false)]
        [string]$ModuleName = 'Az',

        [Parameter(Mandatory = $false)]
        [string]$Version = 'latest',

        [Parameter(Mandatory = $false)]
        [string]$Repository = 'PSGallery',

        [Parameter(Mandatory = $false)]
        [PSCredential]$Credential
    )

    begin {
        $null = Register-AzResourceProvider -ProviderNamespace 'Microsoft.Automation'
        $Script:TempFolder = $Env:TEMP + '\UpdateModuleLibrary-' + (Get-Random -Minimum 1000 -Maximum 9999)
        $null = New-Item -Path $Script:TempFolder -ItemType Directory -Force -ErrorAction Stop
        Write-Verbose "Temp folder created: $Script:TempFolder"
    }

    process {
        if ([String]::IsNullOrEmpty($StorageAccountName)) {
            Write-Verbose ("No storage account provided. Getting '{0}' default." -f $Environment)
            $StorageAccountName = Get-StorageAccountNameForEnvironment -environment $Environment
        }
        Write-Verbose "Use storage account '$StorageAccountName' for upload"
        if(-not $StorageAccountName) { throw "No storage account name available" }
        $Script:Repository = $Repository

        $ModuleVersionInputObject = @{
            Version    = $Version
            Repository = $Repository
            ModuleName = $ModuleName
        }
        if ($Credential) {
            Write-Verbose "Using credentials"
            $Script:Credential = $Credential
            $ModuleVersionInputObject += @{ Credential = $Credential }
        }
        Write-Verbose ('Find version "{0}" of module "{1}" in repository "{2}"' -f $Version, $ModuleName, $Repository)
        $Version = Find-ModuleVersion @ModuleVersionInputObject -ErrorAction Stop

        if ($PSCmdlet.ShouldProcess("Temp folder", "Download module $ModuleName packages from $Script:Repository")) {
            [array] $Packages = Save-PSModule -ModuleName $ModuleName -Version $Version -Repository $Repository -ErrorAction Stop
        }

        if ($PSCmdlet.ShouldProcess("Storage account $StorageAccountName", "Upload module packages")) {
            $moduleData = Copy-ModuleToAzure -Packages $Packages -ModuleName $ModuleName -Version $Version -StorageAccountName $StorageAccountName
        }

        return $moduleData
    }

    end {
        if (Test-Path -Path $Script:TempFolder) {
            $null = Remove-Item -Path $Script:TempFolder -Recurse -Force
            Write-Verbose "Temp folder deleted."
        }
    }
}

