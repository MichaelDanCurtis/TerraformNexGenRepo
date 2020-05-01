
function Set-AzHostedIR {
    <#
        .SYNOPSIS
        Set Azure Hosted Integration Runtimes for a specific Data Factory

        .DESCRIPTION
        Naming patterns <DataFactoryName>-ir-<Incremental Number>

        Examples:
      - mr-bdap-prd-we-e001-ir-01
      - mr-bdap-prd-we-e001-ir-02

        .EXAMPLE
        Get-MRAzBdapAdfName -Company 'MR' -Application 'BDAP'  -Environment 'SBX'

        Generates naming conveniton:'mr-bdap-tt'

        .PARAMETER ResourceGroupName
        Name of Resource Group - e.g. MR-BDAP-PRP-WE-ADF-e0000

        .PARAMETER DataFactoryName
        Name of Data Factory - e.g. mr-bdap-prp-we-i0000

        .PARAMETER Location
        Name of Location - e.g. west europe

        .PARAMETER NumberOfAzIRs
        Number of Azure Integration Runtimes - e.g. 3

    #>

    [CmdletBinding(SupportsShouldProcess = $True)]
    param(
        [Parameter(
            Mandatory = $true,
            HelpMessage = "Resource Group containing the Data Factory"
        )]
        [string]  $ResourceGroupName,

        [Parameter(
            Mandatory = $true,
            HelpMessage = "Name of Azure Data Factory"
        )]
        [string] $DatafactoryName,

        [Parameter(
            Mandatory = $true,
            HelpMessage = "Location of Azure Integration Runtime"
        )]
        [string] $Location,

        [Parameter(
            Mandatory = $true,
            HelpMessage = "Number of Azure Integration Runtimes"
        )]
        [string] $NumberOfAzIRs
    )
    process {

        if ($PSCmdlet.ShouldProcess($ResourceGroupName, $DatafactoryName)) {
            for ($i = 1; $i -le $NumberOfAzIRs; $i++) {

                $IRName = $DatafactoryName + '-ir-' + $i

                $null = Set-AzDataFactoryV2IntegrationRuntime -ResourceGroupName $ResourceGroupName -DataFactoryName $DatafactoryName -Name $IRName  -Type "Managed" -Location $Location -Force

            }
        }
    }
}