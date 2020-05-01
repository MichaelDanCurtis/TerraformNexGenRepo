function Get-ArmTemplate {
    <#
    .SYNOPSIS
    Returns the link to the modules ARM template

    .DESCRIPTION
    Returns the link to the modules ARM template
    Can be configured in Modulemanifest (MRAzBdapApp.psd1)  Attribute FileList = @('./static/azuredeploy.json')

    .PARAMETER NetworkRuleSet
    Switch to return the NetworkRuleSet template uri rather than the default EventHut template.

    .EXAMPLE
    Get-MRAzBdapAppArmTemplate

    *.\bdap-az-automation-cosmos\MRAzBdapApp\static\azuredeploy.json

    #>
    [CmdletBinding()]
    param ()

    begin {
    }

    process {
        $moduleFileList = $Local:MyInvocation.MyCommand.Module.FileList

        $moduleFileList[0]
    }

    end {
    }
}