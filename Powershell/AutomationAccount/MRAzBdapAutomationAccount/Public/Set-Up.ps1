<#
.SYNOPSIS
Create an AutomationAccount with MunichRE specific post-deployment conditions

.DESCRIPTION
Create an AutomationAccount with MunichRE specific post-deployment conditions

.PARAMETER Config
Component configuration

.PARAMETER ConfigPath
Path to a component configuration

.PARAMETER WhatIf
Dry run of script, returns theoretical values

.PARAMETER Confirm
Before impacting system ask to confirm

.EXAMPLE
Set-MRAzBdapAutomationAccountUp -Config $config

Deploy an AutomationAccount with a given configuration
#>

function Set-Up {

    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = 'Config')]
        [PSCustomObject] $Config,

        [Parameter(Mandatory = $true, ParameterSetName = 'ConfigPath')]
        [String] $configPath
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

    Write-Output "Config loaded"
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

    # Add optional paramterers to Config if missing
    if (!(Get-Member -InputObject $Config -Name Descriptor -MemberType Properties)) {
        Add-Member -InputObject $Config -Name Descriptor -Value $null -MemberType NoteProperty
    }

    if (!(Get-Member -InputObject $Config -Name ComponentName -MemberType Properties)) {
        Add-Member -InputObject $Config -Name ComponentName -Value $null -MemberType NoteProperty
    }

    # START PRE-DEPLOYMENT #
    #======================#
    Write-Verbose "# START PRE-DEPLOYMENT #"
    Write-Verbose "########################"

    if ([string]::IsNullOrEmpty($Config.ComponentName)) {
        # Get ComponentName
        $InputObjectComponent = @{
            Company     = $Config.Company
            Application = $Config.Application
            Environment = $Config.Environment
            Descriptor  = $Config.Descriptor
        }
        $ComponentName = Get-MRAzBdapAutomationAccountName @InputObjectComponent
    }
    else {
        $ComponentName = $config.ComponentName
    }
    Write-Verbose "ComponentName $ComponentName"

    $InputObjectResourceGroup = @{
        Company     = $config.Company
        Application = $config.Application
        Environment = $config.Environment
        Component   = 'Auto'
        MrLocation  = 'WE'
        Location    = 'WestEurope'
    }
    $resourceGroup = New-MRAzBdapResourceGroupComponent @InputObjectResourceGroup -Verbose

    $InputObjectAutomationAccount = @{
        ComponentName           = $ComponentName
        ResourceGroupName       = $resourceGroup.ResourceGroupName
        LogAnalyticsWorkspace   = $config.LogAnalyticsWorkspace
        DeploymentModuleVersion = $DeploymentModuleVersion
        ReleaseIdentifier       = $ReleaseIdentifier
    }

    # START DEPLOYMENT #
    #==================#
    Write-Verbose "# START DEPLOYMENT #"
    Write-Verbose "####################"

    $AutomationAccount = New-MRAzBdapAutomationAccountComponent @InputObjectAutomationAccount -Verbose -ErrorAction Stop
    $AutomationAccount
    Write-Verbose "Deployment completed"

    # 1 HANDLE RUNAS CONNECTION #
    #===========================#
    Write-Verbose "# 1 HANDLE RUNAS CONNECTION #"
    Write-Verbose "#############################"

    $ConnectionParam = @{
        Environment           = $config.Environment
        AutomationAccountName = $AutomationAccount.Parameters['componentName'].Value
        ResourceGroupName     = $AutomationAccount.ResourceGroupName
        Company               = $config.Company
        Application           = $config.Application
    }

    Write-Verbose "Creating RunAs Connection"
    if ($PSCmdlet.ShouldProcess("Automation Account $ComponentName", "Create connection")) {
        New-MRAzBdapAutomationAccountConnection @ConnectionParam -ErrorAction Stop -Verbose
    }
    Write-Verbose "RunAs Connection created"

    # 2 HANDLE MODULES #
    #==================#
    Write-Verbose "# 2 HANDLE MODULES #"
    Write-Verbose "####################"

    foreach ($requiredModule in $config.RequiredModules) {
        if ($PSCmdlet.ShouldProcess(('Module "{0}" from repository "{1}" with version "{2}"' -f $requiredModule.Name, $requiredModule.Repository, $requiredModule.Version), 'Install')) {

            Write-Verbose ('Upload Module "{0}" from repository "{1}" with version "{2}"' -f $requiredModule.Name, $requiredModule.Repository, $requiredModule.Version)
            $UploadInputObject = @{
                Environment = $config.Environment
                ModuleName  = $requiredModule.Name
            }
            if (-not [String]::IsNullOrEmpty($requiredModule.Version)) {
                $UploadInputObject += @{ Version = $requiredModule.Version }
            }
            if (-not [String]::IsNullOrEmpty($requiredModule.Repository)) {
                $UploadInputObject += @{ Repository = $requiredModule.Repository }
            }

            $moduleData = Update-MRAzBdapAutomationAccountModuleLibrary @UploadInputObject -Verbose

            Write-Verbose "Initiate AutomationAccount Upload"
            $InstallInputObject = @{
                AutomationAccountName = $ComponentName
                ResourceGroupName     = $AutomationAccount.ResourceGroupName
                UploadedModule        = $moduleData
            }
            $null = Install-ModuleOnAutoAccount @InstallInputObject
        }
    }
    Write-Verbose "All modules installed"
}