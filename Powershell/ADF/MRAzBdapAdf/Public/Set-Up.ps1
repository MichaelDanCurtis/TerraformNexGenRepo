<#
.SYNOPSIS
Create an ADF with MunichRE specific post-deployment conditions

.DESCRIPTION
Create an ADF with MunichRE specific post-deployment conditions

.PARAMETER Config
Component configuration

.PARAMETER ConfigPath
Path to a component configuration

.PARAMETER UseAzureRegion
Boolean parameter to be set if AzureRegion should be set (e.g. $AzureRegion = 'europewest' for $config.Location -eq 'westeurope'))

.PARAMETER WhatIf
Dry run of script, returns theoretical values

.PARAMETER Confirm
Before impacting system ask to confirm

.EXAMPLE
Set-MRAzBdapAdfUp -Config $config

Deploy an ADF with a given configuration or path to a configuration
#>
function Set-Up {

    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = 'Config')]
        [PSCustomObject] $Config,
        [Parameter(Mandatory = $true, ParameterSetName = 'ConfigPath')]
        [String] $configPath,
        [Parameter(Mandatory = $false)]
        [bool] $UseAzureRegion = $false
    )

    $VerbosePreference = "Continue"

    if (-not ([String]::IsNullOrEmpty($configPath))) {
        if (-not (Test-Path -Path $configPath)) {
            throw "ConfigPath '$configPath' doesn't exist."
        }
        else {
            $Config = (Get-Content -Raw $configPath) | ConvertFrom-Json
        }
    }

    Write-Output "[$(Get-Date)] Config loaded"

    Write-Output "Parameters"
    Write-Output "=========="
    $Config
    Write-Output "=========="

    # Gather Release.Name & currentModule.Version and set in ARM template
    if ($env:RELEASE_RELEASENAME) { $ReleaseIdentifier = $env:RELEASE_RELEASENAME }
    else { $ReleaseIdentifier = "UnknownReleaseIdentifier" }
    Write-Verbose "Determined release name: $ReleaseIdentifier"

    $currentModuleName = (Split-Path (Split-Path $PSScriptRoot -Parent) -Leaf)
    $DeploymentModuleVersion = (Get-Module $currentModuleName).Version
    Write-Verbose "Determined module version: $DeploymentModuleVersion"

    $MrLocation = Get-MrAzBdapSharedLocation -Location $config.Location -Verbose

    $InputObjectResourceGroup = @{
        Company     = $config.Company
        Application = $config.Application
        Environment = $config.Environment
        Component   = $config.Component
        Descriptor  = $config.Description
        MrLocation  = $MrLocation
        Location    = $config.Location
    }
    $ResourceGroup = New-MRAzBdapResourceGroupComponent @InputObjectResourceGroup -Verbose



    $ComponentName = Get-MrAzBdapAdfName -Company $config.Company -Application $config.Application -Environment $config.Environment -MrLocation $MrLocation  -Description $config.Description

    if ($UseAzureRegion) {
        if ($config.Location -eq 'westeurope') { $AzureRegion = 'europewest' }
        if ($config.Location -eq 'eastus2') { $AzureRegion = 'useast2' }
        $PublicIpAddressesKvlt = (Get-MrAzBdapSharedIpAddress -MRLocation $MrLocation -Domain MR -Azure $AzureRegion).Ip
    }
    else {
        $PublicIpAddressesKvlt = (Get-MrAzBdapSharedIpAddress -MRLocation $MrLocation -Domain MR).Ip
    }
    Write-Verbose -Message ("[$(Get-Date)] got {0} ip addresses" -f $PublicIpAddressesKvlt.Count)

    $ContributorADGroup = "$($config.ContributorGroupName)" -f $($config.Environment).toLower(), $MrLocation.toLower()
    Write-Verbose -Message ("[$(Get-Date)] ContributorADGroup {0}" -f $ContributorADGroup)
    $ReaderADGroup = "$($config.ReaderGroupName)" -f $($config.Environment).toLower(), $MrLocation.toLower()
    Write-Verbose -Message ("[$(Get-Date)] ReaderADGroup {0}" -f $ReaderADGroup)

    Write-Verbose "##################################"
    Write-Verbose "## TRIGGER KEY VAULT DEPLOYMENT ##"
    Write-Verbose "##################################"

    $KvltInputObject = @{
        ComponentName             = $ComponentName
        Location                  = $config.Location
        ResourceGroupName         = $ResourceGroup.ResourceGroupName
        IpAddressRange            = $PublicIpAddressesKvlt
        ContributorADGroup        = $ContributorADGroup
        ReaderADGroup             = $ReaderADGroup
        LogAnalyticsWorkspaceName = $config.LogAnalyticsWorkspaceName
        UseDefaultAccessPolicies  = $true
        AuthorizedNetworks        = $config.AuthorizedNetworks
    }
    if ($PSCmdlet.ShouldProcess(('Key vault "{0}" into resource group "{1}"' -f $ComponentName, $ResourceGroup.ResourceGroupName), "Deploy")) {
        $Kvlt = New-MRAzBdapKvltComponent @KvltInputObject -Verbose -ErrorAction Stop
        $Kvlt
    }


    Write-Verbose "########################################"
    Write-Verbose "## TRIGGER STORAGE ACCOUNT DEPLOYMENT ##"
    Write-Verbose "########################################"

    $StorageNameInput = @{
        Company     = $config.Company
        Application = $config.Application
        Environment = $config.Environment
        MrLocation  = $MrLocation
        Descriptor  = $config.Description
    }
    $StorageAccountName = Get-MRAzBdapStorageName @StorageNameInput

    $StorageAccountInputObject = @{
        ComponentName        = $StorageAccountName
        ResourceGroupName    = $ResourceGroup.ResourceGroupName
        Location             = $config.Location
        WorkspaceName        = $config.LogAnalyticsWorkspaceName
        Environment          = $config.Environment
        ReaderGroupName      = $ReaderADGroup
        ContributorGroupName = $ContributorADGroup
    }
    if ($PSCmdlet.ShouldProcess(('Storage Account "{0}" into resource group "{1}"' -f $StorageAccountName, $ResourceGroup.ResourceGroupName), "Deploy")) {
        $SAcc = New-MRAzBdapStorageComponent @StorageAccountInputObject -ErrorAction Stop
        $SAcc
    }

    Write-Verbose "#####################################"
    Write-Verbose "## TRIGGER DATA FACTORY DEPLOYMENT ##"
    Write-Verbose "#####################################"

    $ComponentInputObject = @{
        Company                 = $config.Company
        Environment             = $config.Environment
        Application             = $config.Application
        Description             = $config.Description
        MrLocation              = $MrLocation
        ResourceGroupName       = $ResourceGroup.ResourceGroupName
        Location                = $config.Location
        LogAnalyticsWorkspace   = $config.LogAnalyticsWorkspaceName
        NumberOfAzIRs           = $config.NumberOfAzIRs
        DeploymentModuleVersion = $DeploymentModuleVersion
        ReleaseIdentifier       = $ReleaseIdentifier
    }
    if ($config.ComponentName) {
        $ComponentInputObject += @{ ComponentName = $Config.ComponentName }
    }

    if ($PSCmdlet.ShouldProcess(('Azure Data Factory with description "{0}" into resource group "{1}"' -f $config.Description, $ResourceGroup.ResourceGroupName), "Deploy")) {
        $DataFactory = New-MrAzBdapAdfComponent @ComponentInputObject -Verbose -ErrorAction Stop
        $DataFactory
    }
    Write-Verbose "[$(Get-Date)] Finished New-Component"

    Write-Verbose "##########################################"
    Write-Verbose "## TRIGGER DATA FACTORY POST DEPLOYMENT ##"
    Write-Verbose "##########################################"

    if ([string]::IsNullOrEmpty($Config.ComponentName)) {
        $ComponentName = Get-MrAzBdapAdfName -Company $config.Company -Application $config.Application -Environment $config.Environment -MrLocation $MrLocation  -Description $config.Description
    }

    $DataFactoryRBACInputObject = @{
        Contributor           = $ContributorADGroup
        Reader                = $ReaderADGroup
        ComponentName         = $ComponentName
        ResourceGroupName     = $ResourceGroup.ResourceGroupName
        KeyVaultComponentName = $Kvlt.keyVaultName
        Environment           = $config.Environment
    }
    if ($PSCmdlet.ShouldProcess(('RBAC on component "{0}""' -f $ComponentName), "Set")) {
        $RBAC = Set-MRAzBdapAdfRBAC @DataFactoryRBACInputObject
    }

    Write-Verbose "Set RBAC: $RBAC"
}
