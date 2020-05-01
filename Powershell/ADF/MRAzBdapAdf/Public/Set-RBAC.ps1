<#
.SYNOPSIS
Set the RBAC on given resource

.DESCRIPTION
Set role based access control on given resource

.PARAMETER ComponentName
Resource name to assign RBAC

.PARAMETER KeyVaultComponentName
KeyVault ComponentName to assign RBAC

.PARAMETER ResourceGroupName
ResourceGroupName to assign RBAC

.PARAMETER Environment
Environment to construct the role definition name

.PARAMETER Contributor
AAD object which will be granted with Contributor role on the resource. Use name or id of the AD object

.PARAMETER Reader
AAD object which will be granted with Reader role on the resource. Use name or id of the AD object

.PARAMETER WhatIf
Dry run

.PARAMETER Confirm
Asks user to confirm

.EXAMPLE
Set-MRAzBdapSearchRBAC -ComponentName $ComponentName -Contributor $Contributor -Reader $Reader
Sets rbac on resources

#>

function Set-RBAC {
    [CmdletBinding(
        SupportsShouldProcess = $True
    )]

    param (
        # ComponentName to assign RBAC
        [Parameter(
            Mandatory,
            HelpMessage = "ComponentName to assign RBAC"
        )]
        [string] $ComponentName,

        # KeyVault ComponentName to assign RBAC
        [Parameter(
            Mandatory,
            HelpMessage = "KeyVault ComponentName to assign RBAC"
        )]
        [string] $KeyVaultComponentName,

        # ResourceGroupName to assign RBAC
        [Parameter(
            Mandatory,
            HelpMessage = " ResourceGroupName to assign RBAC"
        )]
        [string] $ResourceGroupName,

        [Parameter(
            Mandatory = $true,
            HelpMessage = "Name of Environment - e.g. SBX"
        )]
        [ValidateSet("prd", "int", "dev", "sbx", "tt")]
        [Alias("Env")]
        [string] $Environment,

        # Contributor AD object to assign contributor RBAC
        [Parameter(
            Mandatory = $true,
            HelpMessage = "AAD object which will be granted with Contributor role on the resource. Use name or id of the AD object"
        )]
        [string] $Contributor,

        # Reader AD object to assign reader RBAC
        [Parameter(
            Mandatory = $true,
            HelpMessage = "AAD object which will be granted with Reader role on the resource. Use name or id of the AD object"
        )]
        [string] $Reader
    )

    begin {
        $ResourceType = "Microsoft.DataFactory/factories"
        $KeyVaultResourceType = "Microsoft.KeyVault/vaults"

        # on RG: BDAP-<Env>-ADF-RG-Contributor
        $ResourceGroupContributorRoleDefinitionName = "BDAP-$Environment-ADF-RG-Contributor"
        # on ADF Object: BDAP-<Env>-ADF-Contributor
        $ADFContributorRoleDefinitionName = "BDAP-$Environment-ADF-Contributor"
        # on Key Vault object: BDAP-<Env>-Contributor
        $KeyVaultContributorRoleDefinitionName = "BDAP-$Environment-Contributor"
        $ReaderRoleDefinitionName = "Reader"

        $InputObject = @(
            # Contributor custom role
            @{
                AdObject           = $Contributor
                RoleDefinitionName = $ADFContributorRoleDefinitionName
                ResourceName       = $ComponentName
                ResourceType       = $ResourceType
            },
            # Reader
            @{
                AdObject           = $Reader
                RoleDefinitionName = $ReaderRoleDefinitionName
                ResourceName       = $ComponentName
                ResourceType       = $ResourceType
            },
            # Key Vault custom role
            @{
                AdObject           = $Contributor
                RoleDefinitionName = $KeyVaultContributorRoleDefinitionName
                ResourceName       = $KeyVaultComponentName
                ResourceType       = $KeyVaultResourceType
            }
        )
    }

    process {

        # resource group custom role
        $InputObject += @{
            AdObject           = $Contributor
            RoleDefinitionName = $ResourceGroupContributorRoleDefinitionName
            Scope              = (Get-AzResourceGroup -ResourceGroupName $ResourceGroupName -ErrorAction Stop).ResourceId
        }

        foreach ($Object in $InputObject) {
            if ($PSCmdlet.ShouldProcess("$($Object.ResourceType) Component $($Object.ResourceName)", "Assign $($Object.RoleDefinitionName) role to $($Object.AdObject)")) {

                $null = New-MRAzBdapRBACRoleAssignment @Object

                Write-Verbose "[$(Get-Date)] $($Object.RoleDefinitionName) role was assigned to $($Object.AdObject) on $($Object.ResourceName)"
            }
        }
    }

    end {
    }
}

