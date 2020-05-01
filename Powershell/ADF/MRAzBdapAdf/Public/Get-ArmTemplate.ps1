function Get-ArmTemplate {
    <#
    .SYNOPSIS
    Returns the link to the modules ARM template

    .DESCRIPTION
    Returns the link to the modules ARM template
    Can be configured in Modulemanifest (MRAzBdapAdf.psd1)  Attribute FileList = @('./static/azuredeploy.json')

    .EXAMPLE
    Get-MRAzBdapAdfArmTemplate

    *.\bdap-az-automation-cosmos\MRAzBdapAdf\static\azuredeploy.json

    #>
    [CmdletBinding()]
    param (

    )

    begin {
    }

    process {
        $moduleFileList = $Local:MyInvocation.MyCommand.Module.FileList
        $TemplateUri = $moduleFileList[0]
        $TemplateUri
    }

    end {
    }
}
