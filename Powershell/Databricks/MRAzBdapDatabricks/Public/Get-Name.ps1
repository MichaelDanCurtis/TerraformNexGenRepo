#REQUIRES -Version 5.0
#REQUIRES #-Modules
#REQUIRES #-RunAsAdministrator
function Get-Name {
    <#
        .SYNOPSIS
        Get the name by naming convention <Company>-<Application>-<Environment>-<MRLocation>-<Description and/or Incremental Number>

        .DESCRIPTION
        Naming patterns lowercase <Company>-<Application>-<Environment>-<MRLocation>-<Description and/or Incremental Number>

        Examples:
        - mr-bdap-prd-we-databricks

        .EXAMPLE
        Get-MRAzBdapDatabricksName -Company 'MR' -Application 'BDAP' -Environment 'SBX' -MrLocation 'We' -Description 'usecase1'

        Generates naming conveniton:'mr-bdap-prd-we-databricks'

        .PARAMETER Company
        Name of Company - e.g. MR

        .PARAMETER Application
        Name of Application - e.g. BDAP

        .PARAMETER Environment
        Name of Environment - e.g. SBX
        [ValidateSet("prd", "int", "dev", "sbx", "tt")]

        .PARAMETER MrLocation
        Name of MrLocation - e.g. we (Get-MrAzBdapSharedLocation -Loation $Location)

        .PARAMETER Descriptor
        Descriptor if needed, incremental value or description

        .PARAMETER Delimiter
        Delimiter if needed

        .PARAMETER CHARACTER_NAME_LIMIT
        Maximum character limit of component = 16
    #>

    [CmdletBinding(
        PositionalBinding = $True,
        DefaultParameterSetName = "Default"
    )]
    [OutputType([String])]
    param(
        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 0,
            ParameterSetName = 'Default',
            HelpMessage = "Name of Company - e.g. MR"
        )]
        [Alias("Co")]
        [string]  $Company,

        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 1,
            ParameterSetName = 'Default',
            HelpMessage = "Name of Application - e.g. BDAP"
        )]
        [Alias("App")]
        [string] $Application,

        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 2,
            ParameterSetName = 'Default',
            HelpMessage = "Environment - e.g. SBX"
        )]
        [ValidateSet("prd", "dev", "sbx")]
        [Alias("Env")]
        [string] $Environment,

        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            ParameterSetName = 'Default',
            HelpMessage = "Name of MrLocation - e.g. we, EUS2"
        )]
        #[ValidateLength(2, 4)]
        [string] $MrLocation,

        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            ParameterSetName = 'Default',
            HelpMessage = "Descriptor if needed, incremental value or description"
        )]
        [string]
        $Descriptor,

        [Parameter(
            Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            ParameterSetName = 'Default',
            HelpMessage = "Delimiter if needed"
        )]
        [string]
        [ValidatePattern("(\-|\s)")] # matches dash or space
        [ValidateLength(1, 1)]
        $Delimiter = "-",

        #TODO: need to check it again using ARM template . previously it was found to be accepting more den 30 with ARM but not with azure template

        [int]
        $CHARACTER_NAME_LIMIT = 30
    )

    process {

        if ([string]::IsNullOrEmpty($Company)) {
            throw 'Invalid Parameter Exception: Please specify Company'
        }

        if ([string]::IsNullOrEmpty($Application)) {
            throw 'Invalid Parameter Exception: Please specify Application'
        }

        if ([string]::IsNullOrEmpty($Environment)) {
            throw 'Invalid Parameter Exception: Please specify Environment'
        }

        if ([string]::IsNullOrEmpty($MrLocation)) {
            throw 'Invalid Parameter Exception: Please specify MrLocation'
        }

        if ([string]::IsNullOrEmpty($Descriptor)) {
            throw 'Invalid Parameter Exception: Please specify Descriptor'
        }

        $ComponentName = ("{1}{0}{2}{0}{3}{0}{4}{0}{5}" -f $Delimiter, $Company.ToLower(), $Application.ToLower(), $Environment.ToLower(), $MrLocation.ToLower(), $Descriptor.ToLower())

        $ComponentName = Remove-Delimiter $ComponentName $Delimiter
        Test-CharacterLength $ComponentName $CHARACTER_NAME_LIMIT

        Write-Verbose  "[$(Get-Date)] Created ComponentName $ComponentName"
        Write-Output $ComponentName
    }
}

function Remove-Delimiter {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "", Justification = "Does not change state")]
    [CmdletBinding()]
    param (
        $ComponentName,
        $Delimiter
    )

    begin {
    }

    process {

        if ($ComponentName[$ComponentName.Length - 1] -eq $Delimiter) {
            Write-Verbose "[$(Get-Date)] Remove trailing Delimiter"
            $ComponentName = $ComponentName.Substring(0, $ComponentName.Length - 1)
        }

        $ComponentName
    }

    end {
    }
}

function Test-CharacterLength {
    [CmdletBinding()]
    param (
        $ComponentName,
        $CharacterLengthLimit
    )

    begin {
    }

    process {
        if ($CharacterLengthLimit) {
            if ($ComponentName.Length -gt $CharacterLengthLimit) {
                throw "To many characters $ComponentName, Limit is $CharacterLengthLimit"
            }
        }
    }

    end {
    }
}
