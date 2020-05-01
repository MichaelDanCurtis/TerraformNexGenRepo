<#
.SYNOPSIS
Remove a specified Azure DataFactory deployment in a specific Resource Group

.DESCRIPTION
Remove a specified  Azure DataFactory deployment deployed during Set-Up.ps1. The resource group, if empty, will be removed seperately
using a scheduled job to remove empty resource groups.

.PARAMETER Config
Component configuration

.PARAMETER ConfigPath
Path to component configuration

.PARAMETER WhatIf
Dry run of script, returns theoretical values

.PARAMETER Confirm
Before impacting system ask to confirm

.EXAMPLE
Remove-MRAzBdapAdfDeployment -Config $config

Remove the deployment matching the given configuration
#>
function Remove-Deployment {

    [CmdletBinding(
        SupportsShouldProcess = $true
    )]
    param (
        [Parameter(Mandatory = $true, ParameterSetName = 'Config')]
        [PSCustomObject] $Config,

        [Parameter(Mandatory = $true, ParameterSetName = 'ConfigPath')]
        [String] $ConfigPath
    )

    if (-not ([String]::IsNullOrEmpty($configPath))) {
        if (-not (Test-Path -Path $configPath)) {
            throw "ConfigPath '$configPath' doesn't exist."
        }
        else {
            $Config = (Get-Content -Raw $configPath) | ConvertFrom-Json
        }
    }

    Write-Verbose "Config loaded"
    Write-Verbose "Parameters"
    Write-Verbose "=========="
    $Config
    Write-Verbose "=========="
    Write-Verbose "# 0. Gather information #"
    Write-Verbose "#########################"
    Write-Verbose "Get-MRLocation"

    $MrLocation = Get-MRAzBdapSharedLocation -Location $config.Location

    $InputObjectResourceGroup = @{
        Company     = $config.Company
        Application = $config.Application
        Environment = $config.Environment
        Component   = $config.Component
        Descriptor  = $config.Description
        MrLocation  = $MrLocation
    }
    $ResourceGroupName = Get-MRAzBdapResourceGroupName @InputObjectResourceGroup -Verbose

    # STORAGE ACCOUNT INFO
    $StorageNameInput = @{
        Company     = $config.Company
        Application = $config.Application
        Environment = $config.Environment
        MrLocation  = $MrLocation
        Descriptor  = $config.Description
    }
    $StorageAccountName = Get-MRAzBdapStorageName @StorageNameInput

    # ADF INFO
    if ([string]::IsNullOrEmpty($Config.ComponentName)) {
        $adfNameInput = @{
            Company     = $config.Company
            Application = $config.Application
            Environment = $config.Environment
            MrLocation  = $MrLocation
            Description = $config.Description
        }
        $AdfComponentName = Get-MrAzBdapAdfName @adfNameInput
    }
    else {
        $AdfComponentName = $Config.ComponentName
    }

    # KVLT INFO
    $adfNameInput = @{
        Company     = $config.Company
        Application = $config.Application
        Environment = $config.Environment
        MrLocation  = $MrLocation
        Description = $config.Description
    }
    $KvltComponentName = Get-MrAzBdapAdfName @adfNameInput # Actually uses this function

    Write-Verbose "# 1. Remove ADF deployment #"
    Write-Verbose "############################"
    if ($PSCmdlet.ShouldProcess("Azure DataFactory '$AdfComponentName' from Resource Group '$ResourceGroupName'", "Remove")) {
        try {
            # REMOVE ADF
            Remove-AzDataFactoryV2 -Name $AdfComponentName -ResourceGroupName $ResourceGroupName -Force -ErrorAction Stop
            Write-Verbose "Azure DataFactory $AdfComponentName removed"
            Write-Verbose "################################"
        }
        catch {
            Write-Verbose "Azure DataFactory '$AdfComponentName' does not exist in Resource Group '$ResourceGroupName'"
            Write-Verbose "################################################################################"
            Write-Verbose ("Error: {0}" -f $_.Exception.Message)
        }
    }

    if ($PSCmdlet.ShouldProcess("Storage Account '$StorageAccountName' from Resource Group '$ResourceGroupName'", "Remove")) {
        try {
            # REMOVE STORAGE ACCOUNT
            Remove-AzStorageAccount -Name $StorageAccountName -ResourceGroupName $ResourceGroupName -Force -ErrorAction Stop
            Write-Verbose "Storage Account $StorageAccountName removed"
            Write-Verbose "################################"
        }
        catch {
            Write-Verbose "Storage Account '$StorageAccountName' does not exist in Resource Group '$ResourceGroupName'"
            Write-Verbose "################################################################################"
            Write-Verbose ("Error: {0}" -f $_.Exception.Message)
        }
    }

    # REMOVE KEY VAULT
    if ($PSCmdlet.ShouldProcess("Key Vault '$KvltComponentName' from Resource Group '$ResourceGroupName'", "Remove")) {
        try {
            Remove-AzKeyVault -VaultName $KvltComponentName -ResourceGroupName $ResourceGroupName -ErrorAction Stop -Force
            Write-Verbose "Key Vault $KvltComponentName removed"
            Write-Verbose "####################################"
        }
        catch {
            Write-Verbose "Key Vault '$KvltComponentName' does not exist in Resource Group '$ResourceGroupName'"
            Write-Verbose "################################################################################"
            Write-Verbose ("Error: {0}" -f $_.Exception.Message)
        }
    }
}
