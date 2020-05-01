#REQUIRES -Version 5.0
#REQUIRES #-Modules
#REQUIRES #-RunAsAdministrator
function New-Component {
    <#
        .SYNOPSIS
        Creates the azure automation account

        .DESCRIPTION
        Creates the azure automation account

        .PARAMETER ComponentName
        Component Name - e.g. <Company>-<Application>-<Environment>

        .PARAMETER ResourceGroupName
        Resource Group Name - e.g. <Company>-<Application>-<Environment>-<Location>-<Component>[-<Description or Incremental Number>]

        .PARAMETER LogAnalyticsWorkspace
        Log analytics workspace name to link to

        .PARAMETER Confirm
        Will promt user to confirm the action to create invasible commands

        .PARAMETER WhatIf
        Dry run of the script

        .PARAMETER DeploymentModuleVersion
        Deployed artifact version

        .PARAMETER ReleaseIdentifier
        Identifier of the used deployment pipeline

        .EXAMPLE
        New-MRAzBdapAutomationAccountComponent -ResourceGroupName 'MR-BDAP-WE-TT-AUTO' -ComponentName 'mr-bdap-tt' -LogAnalyticsWorkspace $la

        Creates an Azure Automation Account named after the parameter ComponentName. Az module an RunAsConnection will be added automatically.

        .NOTES
        There is only one Azure Automation Account for every <Environment> which is always deployed to "West Europe"
        There is also only one Service Account used for every <Environment> - e.g. Ser-CEP-bd<Environment>auto

        #>
    [CmdletBinding(
        SupportsShouldProcess = $True,
        DefaultParameterSetName = "Default"
    )]

    [OutputType('Microsoft.Azure.Commands.ResourceManager.Cmdlets.SdkModels.PSResourceGroupDeployment')]

    param(

        [Parameter(Mandatory = $True)]
        [string]$ComponentName,

        [Parameter(Mandatory = $True)]
        [string]$ResourceGroupName,

        [Parameter(Mandatory = $True)]
        [string]$LogAnalyticsWorkspace,

        [Parameter(Mandatory = $false)]
        [string] $DeploymentModuleVersion = "UnknownDeploymentVersion",

        [Parameter(Mandatory = $false)]
        [string] $ReleaseIdentifier = "UnknownReleaseIdentifier"
    )

    begin {

        $ModuleBase = Split-Path $PSScriptRoot -Parent
        Write-Verbose "Module path is $ModuleBase"
        $TemplateUri = Get-MRAzBdapAutomationAccountArmTemplate
        if (!$TemplateUri) {
            Throw "Missing template file. Deployment has stopped"
        }
        Register-AzResourceProvider -ProviderNamespace 'Microsoft.Automation' | Out-Null
    }

    process {

        Get-AzResourceGroup $ResourceGroupName -ErrorAction Stop | Out-Null
        Write-Verbose "Resource Group selected for deployment: $ResourceGroupName"

        $dailyScheduleStartTime = ([datetime]::Today).AddHours(44).toUniversalTime()
        Write-Verbose "Format scheduled start time - Daily scheduling job: Every day at 7 PM: $dailyScheduleStartTime"

        $workspaceResource = Get-AzResource -Name $LogAnalyticsWorkspace -ResourceType "Microsoft.OperationalInsights/workspaces"

        $Param = @{
            ComponentName          = $ComponentName
            dailyScheduleStartTime = $dailyScheduleStartTime
            workspaceId            = $workspaceResource.Id
        }

        $InputObject = @{
            ResourceGroupName       = $ResourceGroupName
            ComponentName           = $ComponentName
            TemplateUri             = $TemplateUri
            TemplateParameterObject = $Param
            DeploymentModuleVersion = $DeploymentModuleVersion
            ReleaseIdentifier       = $ReleaseIdentifier
        }
        # Deploy Azure Automation resource
        if ($PSCmdlet.ShouldProcess("Resource Group $ResourceGroupName", "Deploy Automation Account $ComponentName")) {
            $AutomationAccount = New-AzResourceGroupDeployment @InputObject -Verbose
        }
        Write-Verbose "Automation Account $ComponentName has been deployed in $ResourceGroupName"

        return $AutomationAccount
    }

    end { }
}