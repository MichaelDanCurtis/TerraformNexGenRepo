#REQUIRES -Version 5.0
#REQUIRES #-Modules
#REQUIRES #-RunAsAdministrator
function Get-Name {
    <#
        .SYNOPSIS
        Get the name by naming convention <Company>-<Application>-<Environment>

        .DESCRIPTION
        Naming patterns <Company>-<Application>-<Environment>

        Examples:
        - mr-bdap-dev
        - mr-bdap-sbx

        .EXAMPLE
        Get-MRAzBdapAdfName -Company 'MR' -Application 'BDAP'  -Environment 'SBX'

        Generates naming conveniton:'mr-bdap-tt'

        .PARAMETER Company
        Name of Company - e.g. MR

        .PARAMETER Application
        Name of Application - e.g. BDAP

        .PARAMETER Environment
        Name of Environment - e.g. SBX
        [ValidateSet("prd", "int", "dev", "sbx", "tt")]

        .PARAMETER Delimiter
        Delimiter if needed

        .PARAMETER Description
        Description part of entire name

        .PARAMETER MrLocation
       Location of resource

        .PARAMETER  CHARACTER_NAME_LIMIT
        Max lenght of name
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "")]

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
        [ValidateSet("prd", "int", "dev", "sbx", "tt", "prp", "inp", "dep", "sbp")]
        [Alias("Env")]
        [string] $Environment,

        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 3,
            ParameterSetName = 'Default',
            HelpMessage = "Name of Application - e.g. BDAP"
        )]
        [Alias("MrL")]
        [string] $MrLocation,

        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 5,
            ParameterSetName = 'Default',
            HelpMessage = "Name of Application - e.g. BDAP"
        )]
        [Alias("Des")]
        [string] $Description,

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

        [int]
        $CHARACTER_NAME_LIMIT = 24
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

        if ([string]::IsNullOrEmpty($Description)) {
            throw 'Invalid Parameter Exception: Please specify Descirption'
        }

        $ComponentName = ("{1}{0}{2}{0}{3}{0}{4}{0}{5}" -f $Delimiter, $Company.ToLower(), $Application.ToLower(), $Environment.ToLower(), $MrLocation.ToLower(), $Description.ToLower())

        $ComponentName = Remove-Delimiter $ComponentName $Delimiter
        Test-CharacterLength $ComponentName $CHARACTER_NAME_LIMIT

        Write-Verbose  "[$(Get-Date)] Created ComponentName $ComponentName"
        Write-Output $ComponentName
    }
}

function Remove-Delimiter {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "")]
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
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "")]
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
