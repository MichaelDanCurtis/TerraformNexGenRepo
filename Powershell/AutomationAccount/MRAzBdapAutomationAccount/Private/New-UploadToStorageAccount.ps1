
<#
    .SYNOPSIS
    Uploads given file to set Storage Account with given name an creates a SAS token

    .DESCRIPTION
    Uploads given file $Path onto set Storage Account (SetStorageAccount -StorageAccoutnName $SAName) by default into the Container $ContainerName ( $Script:CONFIG.AutomationModuleContainer).
    Create an accesible URI by concating AbsolutUri + SAS token for 30mins.

    .PARAMETER Path
    Path to file to upload

    .PARAMETER Name
    Name of the Blob that should be created on the storage account (can be a path).

    .PARAMETER ContainerName
    Name of the container to upload to, by default $Script:CONFIG.AutomationModuleContainer

    .EXAMPLE
     $Uri = New-UploadToStorageAccount -Path $Package.FullName -Name $Name

    #>
function New-UploadToStorageAccount {

    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        [parameter(Mandatory)]
        [string] $Path,

        [parameter(Mandatory)]
        [string]$Name,

        [parameter(Mandatory = $false)]
        [string] $ContainerName = $Script:CONFIG.AutomationModuleContainer
    )

    try {
        if (($name -like "*.zip") -and ($path -notlike "*.zip")) {
            Write-Verbose "Adding .zip to path"
            $path = "$Path.zip"
        }

        Write-Verbose "Uploading File '$Path' with Name '$Name' to Container '$ContainerName'"
        if ($PSCmdlet.ShouldProcess("File '$Path' to container '$ContainerName'", "Upload")) {
            $CloudBlob = Set-AzStorageBlobContent -File $Path -Container $ContainerName -Blob $Name -BlobType Block -Force
            $AbsoluteUri = $CloudBlob.ICloudBlob.StorageUri.PrimaryUri.AbsoluteUri
            Write-Verbose "Upload complete to Uri '$AbsoluteUri'"
        }

        Write-Verbose "Generating SAS token"
        $StartTime = Get-Date
        $EndTime = $startTime.AddHours(0.5)
        if ($PSCmdlet.ShouldProcess(('SAS token for container "{0}"' -f $ContainerName), 'Generate')) {
            $SasLink = New-AzStorageBlobSASToken -Blob $Name -Container $ContainerName -Permission r -StartTime $StartTime -ExpiryTime $EndTime
        }
        Write-Verbose "SAS token generated"
    }
    catch {
        $_.Exception | Format-List -Force | Out-String | Write-Verbose
        Write-Error "Failed to upload file $Path to $ContainerName"
    }

    return ("{0}{1}" -f $AbsoluteUri, $SasLink)
}
