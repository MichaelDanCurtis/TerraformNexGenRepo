

function Test-Library {
    [CmdletBinding()]
    param (
        $StorageAccountName,
        $ContainerName,
        $Environment,
        $Repository
    )

    begin {
    }

    process {
        [array] $Blobs = Get-AzStorageBlob -Container $ContainerName | Where-Object { $_.Name -like "$Script:ParentModule/$Script:Version/*" }
        if ($Blobs.Count -eq 0) {

            Write-Verbose "No package found in the Storage Account library for module $Script:ParentModule version $Script:Version. Updating library..."

            $ParamObject = @{
                Environment = $Environment
                ModuleName  = $Script:ParentModule
                Version     = $Script:Version
                Repository  = $Repository
            }

            if ($PSBoundParameters.Keys -contains 'Credential') {
                Update-MRAzBdapAutomationAccountModuleLibrary @ParamObject
            }
            else {
                $ParamObject += @{
                    Credential = $Credential
                }
                Update-MRAzBdapAutomationAccountModuleLibrary @ParamObject
            }

            [array] $Blobs = Get-AzStorageBlob -Container $ContainerName | Where-Object { $_.Name -like "$Script:ParentModule/$Script:Version/*" }

            if ($Blobs.Count -eq 0) {
                Throw "Library could not be updated."
            }
            else {
                Write-Verbose "Library updated."
            }
        }
        else {
            Write-Verbose "$($Blobs.Count) packages found Storage Account $StorageAccountName"
        }

        return $Blobs
    }

    end {
    }
}