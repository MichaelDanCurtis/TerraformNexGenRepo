<#
    .SYNOPSIS
    Installs modules in an Azure Automation account.

    .DESCRIPTION
    Automatically installs modules from the module-array in the specified Automation Account.
    The modules in the array must must exist in a storage account with a valid uri (incl. key)

    .PARAMETER AutomationAccountName
    Automation account name

    .PARAMETER ResourceGroupName
    Resource Group Name

    .PARAMETER UploadedModule
    Uploaded module hashmap of Name and AbsoluteUri to acces the uploaded modules from a storage account

    .PARAMETER Confirm
    Will promt user to confirm the action to create invasible commands

    .PARAMETER WhatIf
    Dry run of the script

    .EXAMPLE
    Install-ModuleOnAutoAccount -AutomationAccountName $AccountName -ResourceGroupName $ResourceGroupName -UploadedModule @{ Name = "TestMod"; AbsoluteUri = $modUriInStorage }

    Installs the latest upload Version of TestMod module in the target Automation Account.
    #>
function Install-ModuleOnAutoAccount {

    [CmdletBinding(SupportsShouldProcess = $True)]
    param (
        [Parameter(Mandatory = $True)]
        [Alias("Name")]
        [string]$AutomationAccountName,

        [Parameter(Mandatory = $True)]
        [string]$ResourceGroupName,

        [Parameter(Mandatory = $True)]
        [array] $UploadedModule
    )


    foreach ($Module in $UploadedModule) {
        $uri = $Module.AbsoluteUri
        $ModuleName = $Module.Name

        Write-Verbose "Installing module $($ModuleName) $Version..."
        if ($PSCmdlet.ShouldProcess("Module '$ModuleName'", 'Install')) {
            $null = New-AzAutomationModule -Name $ModuleName -ContentLinkUri $Uri -ResourceGroupName $ResourceGroupName -AutomationAccountName $AutomationAccountName
            Wait-ModuleImport -AutomationAccountName $AutomationAccountName -ResourceGroupName $ResourceGroupName -ModuleName $ModuleName
        }
    }
}

function  Wait-ModuleImport {
    [CmdletBinding()]
    param (
        $AutomationAccountName,
        $ResourceGroupName,
        $ModuleName
    )

    process {
        $maxAttempts = 60
        $count = $maxAttempts
        $AutomationModule = Get-AzAutomationModule -Name $ModuleName -AutomationAccountName $AutomationAccountName -ResourceGroupName $ResourceGroupName
        while ($count -gt 0 -and $AutomationModule.ProvisioningState -ne 'Succeeded' -and $AutomationModule.ProvisioningState -ne 'Failed') {
            Write-Verbose ("Failed to import. Trying again in 60 seconds. [{0}|{1}]" -f ($maxAttempts - $count), $maxAttempts)
            Start-Sleep -Seconds 60
            $AutomationModule = Get-AzAutomationModule -Name $ModuleName -AutomationAccountName $AutomationAccountName -ResourceGroupName $ResourceGroupName
            $count--
        }

        if ($AutomationModule.ProvisioningState -ne 'Succeeded') {
            Throw "Module import for $ModuleName has timed out."
        }

        if ($AutomationModule.ProvisioningState -eq 'Failed') {
            Write-Error ('Import for module "{0}" has failed after "{1}" minutes.' -f $ModuleName, ($maxAttempts - $count))
        }
        else {
            Write-Verbose ('Import for module "{0}" was completed after "{1}" minutes.' -f $ModuleName, ($maxAttempts - $count))
        }
    }
}