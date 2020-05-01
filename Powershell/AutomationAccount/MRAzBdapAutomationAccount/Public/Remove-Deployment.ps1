<#
.SYNOPSIS
Remove a specified Automation Account in a specific Resource Group

.DESCRIPTION
Remove a specified Automation Account deployed during Set-Up.ps1. The resource group, if empty, will be removed seperately
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
Remove-MRAzBdapAutomationAccountDeployment -Config $config

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
    Write-Verbose "========================="
    Write-Verbose "# 0. Gather information #"
    Write-Verbose "#########################"

    $InputObjectComponent = @{
        Company     = $Config.Company
        Application = $Config.Application
        Environment = $Config.Environment
        Descriptor  = $Config.Descriptor
    }

    $MrLocation = Get-MRAzBdapSharedLocation -Location "westeurope"

    $ComponentName = Get-MRAzBdapAutomationAccountName @InputObjectComponent -Verbose

    $azAutomationResource = Get-AzResource -Name $componentName -resourcetype 'Microsoft.Automation/automationAccounts'
    $ResourceGroupName = $azAutomationResource.ResourceGroupName

    Write-Verbose "# 1. Removing Automation Account #"
    Write-Verbose "##################################"
    try {
        if ($PSCmdlet.ShouldProcess("Automation Account '$ComponentName' from Resource Group '$ResourceGroupName'", "Remove")) {
            Remove-AzAutomationAccount -Force -ResourceGroupName $ResourceGroupName -Name $ComponentName -ErrorAction Stop
            Write-Verbose "Automation Account $ComponentName removed"
        }
    }

    catch {
        Write-Verbose "Component '$ComponentName' does not exist in Resource Group '$ResourceGroupName'"
        Write-Verbose "################################################################################"
    }

    Write-Verbose "# 2. Removing Service Principal #"
    Write-Verbose "#################################"
    try {
        $spName = Get-MRAzBdapServicePrincipalName -MrLocation $MrLocation -Environment $Config.Environment -Suffix '-connection'
        $VaultName = Get-MrAzBdapKvltName -Company $Config.Company -Application $Config.Application -Environment $Config.Environment -MrLocation $MrLocation

        if ($PSCmdlet.ShouldProcess(("Service principal '{0}' and its secrets from key vault '{1}'" -f $spName, $VaultName), "Remove")) {
            Write-Verbose "Service Principal name: $spName"
            Write-Verbose "Certificate name: $spName-pfx"
            Remove-MRAzBdapAutomationAccountApplicationByName -SPName $spName -VaultName $VaultName -Verbose -ErrorAction Stop
            Remove-AzKeyVaultCertificate -VaultName $VaultName -Name "$spName-pfx" -Force -Verbose -ErrorAction Stop
            Write-Verbose "Service Principal and corresponding certificate removed"
        }
    }
    catch {
        Write-Verbose "Service Principal $spName Not Found in Key Vault $VaultName"
        Write-Verbose "###########################################################"
    }
}
