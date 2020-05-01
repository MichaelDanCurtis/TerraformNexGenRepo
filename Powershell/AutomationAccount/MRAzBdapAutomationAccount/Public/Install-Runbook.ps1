
function Install-Runbook {
    <#
    .SYNOPSIS
    Iterates through a given path
    - searching for a folder called Runbook
    - itereates through each file in given runbook folder
    - checks if its a runbook (by name - excludes test)
    - uploades runbook given the file name (without type)
        - publish
        - sets logging and tracing on

    .DESCRIPTION
    Iterates through a given path
    - searching for a folder called Runbook
    - itereates through each file in given runbook folder
    - checks if its a runbook (by name - excludes test)
    - uploades runbook given the file name (without type)
        - publish
        - sets logging and tracing on

    .PARAMETER Path
    Path that should be searched for Runbooks folder

    .PARAMETER AutomationAccountName
    Name of AutomationAccount to upload

    .PARAMETER ResourceGroupName
    Name of ResourceGroup of Automation Account

    .PARAMETER Confirm
    Will promt user to confirm the action to create invasible commands

    .PARAMETER WhatIf
    Dry run of the script

    .EXAMPLE
    Install-MRAzBdapAutomationAccountRunbook -Path $Path -AutomationAccount $AutomationAccountName -ResourceGroupName $ResourceGroupName -Verbose

    Uploads the runbooks found in Path to given AutomationAccount
    #>

    [CmdletBinding(SupportsShouldProcess = $True)]
    param (
        [Parameter(Mandatory = $true)]
        [string] $Path,

        [Parameter(Mandatory = $true)]
        [string] $AutomationAccountName,

        [Parameter(Mandatory = $true)]
        [string] $ResourceGroupName
    )

    Write-Verbose ('Searching runbooks in path "{0}"' -f $Path)
    if ((Split-Path $Path -Leaf) -eq 'Runbook') {
        $RunbookFolder = $Path
    }
    else {
        $RunbookFolder = (Get-ChildItem $Path -Filter Runbook -Directory -Recurse).FullName
    }
    Write-Verbose "$RunbookFolder"

    foreach ($Folder in $RunbookFolder) {
        $runbooks = Get-ChildItem $Folder -Filter "*.ps1" -File -Recurse

        foreach ($runbook in $runbooks) {
            Write-Verbose ("Name {0} Path {1}" -f $runbook.Name, $runbook.FullName)

            if ($runbook.Name -like "*.Tests.ps1") {
                Write-Verbose "Found test, continue"
                continue
            }

            $Runbook = @{
                AutomationAccountName = $AutomationAccountName
                Name                  = [io.path]::GetFileNameWithoutExtension($runbook.FullName)
                Path                  = $runbook.FullName
                ResourceGroupName     = $ResourceGroupName
                Type                  = 'PowerShell'
                LogProgress           = $true
                LogVerbose            = $true
            }
            if ($PSCmdlet.ShouldProcess(('Runbook "{0}" to automation account "{1}"' -f $runbook.Name, $AutomationAccountName), "Import")) {
                Import-AzAutomationRunbook @Runbook -Publish -Force
            }
        }
    }
}
