function Get-ArmTemplate {
    <#
    .SYNOPSIS
    Returns the link to the modules ARM template

    .DESCRIPTION
    Returns the link to the modules ARM template
    Can be configured in Modulemanifest (MRAzBdapDatabricks.psd1)  Attribute FileList = @('./static/azuredeploy.json')

    .EXAMPLE
    Get-MRAzBdapDatabricksArmTemplate

    *.\bdap-az-automation-databricks\MRAzBdapDatabricks\static\azuredeploy.json

    #>

    [CmdletBinding(
        SupportsShouldProcess = $True,
        PositionalBinding = $True
    )]

    [OutputType('System.String')]
    param(
        [parameter(
            Mandatory = $true,
            Position = 0,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = "Enter path to a template folder or a template file"
        )]
        [alias("Loc")]
        [String]$Path,

        [Parameter(
            Mandatory = $true,
            Position = 1,
            HelpMessage = 'Select source as a local path or an Azure storage account'
        )]
        [ValidateSet("Local", "StorageAccount")]
        [string]$Source
    )

    begin {
        $ModuleBase = Split-Path $PSScriptRoot -Parent
        Write-Verbose "Module path is $ModuleBase"
    }

    process {
        switch ($Source) {
            'Local' {
                if (Test-Path "$ModuleBase\$Path" -PathType Container -ErrorAction SilentlyContinue) {
                    Write-Verbose "Input Path is a directory"

                    [string[]](Get-ChildItem -Path "$ModuleBase\$Path" -Recurse).FullName | Where-Object { ($_ -like "*.json") -or ($_ -like "*.jsonc") }
                }
                elseif (Test-Path "$ModuleBase$Path" -PathType Leaf -ErrorAction SilentlyContinue) {
                    Write-Verbose "Input Path is a file"

                    if ( ($Path -like "*.json") -or ($Path -like "*.jsonc") ) {
                        [string](Get-Item "$ModuleBase\$Path").FullName
                    }
                    else {
                        Throw "Invalid file. Target file must be an ARM template with .json or .jsonc extension"
                    }
                }
                Else {
                    Throw "Invalid Source value. It must be a local folder or file"
                }
                break
            }
            'StorageAccount' {

                if ($Path -like "*%5C*") {
                    $Path = $Path.Replace("%5C", "\")
                    Write-Verbose "Uri was decoded: $Path"
                }

                if (!($Path -like "*.blob.core.windows.net/*")) {
                    Throw "Uri pattern not recognized."
                }

                $StorageAccountName = ($Path.Substring(8)).Split('.')[0]
                Write-Verbose "Storage Account name: $StorageAccountName"

                Write-Verbose "Checking if the storage account exists"
                $StorageAccount = Get-AzResource -Name $StorageAccountName -ResourceType Microsoft.Storage/storageAccounts
                if (!$StorageAccount) {
                    Throw "[$(Get-Date)]$StorageAccountName does not exist. Exiting..."
                }
                $ResourceGroupName = $StorageAccount.ResourceGroupName
                Write-Verbose "Storage Account $StorageAccountName in Resource Group $ResourceGroupName is available"

                $ContainerName = $Path.Split("/")[3]
                Write-Verbose "Container name: $ContainerName"

                Set-AzCurrentStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccountName | Out-Null
                Write-Verbose "$StorageAccountName set as current Storage Account"

                $ExpiryTime = (Get-Date).AddMinutes(60)

                if (($Path -like "*.json") -or ($Path -like "*.jsonc")) {
                    $BlobName = $Path.Substring($Path.IndexOf("templates") + 10)
                    Write-Verbose "Blob file: $BlobName"

                    Write-Verbose "Genarating SAS token for blob $BlobName"
                    if ($PSCmdlet.ShouldProcess("Blob: $BlobName", "New-AzureStorageBlobSASToken in $StorageAccountName")) {
                        New-AzureStorageBlobSASToken -Blob $BlobName -Container $ContainerName -Permission r -ExpiryTime $ExpiryTime -FullUri
                    }
                }
                else {
                    if ($PSCmdlet.ShouldProcess("Container: $ContainerName", "New-AzureStorageContainerSASToken in $StorageAccountName")) {
                        $SasToken = New-AzureStorageContainerSASToken -Name $ContainerName -Permission r -ExpiryTime $ExpiryTime

                        [string[]](Get-AzureStorageBlob -Container $ContainerName).ICloudBlob.Uri.Absoluteuri | ForEach-Object { $_ + $SasToken }
                    }
                }

            }
            default {
                Throw "Unexpected vale for 'Source' parameter."
            }
        }
    }

    end {
    }
}