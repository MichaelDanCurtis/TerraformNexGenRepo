
<#
    .SYNOPSIS
    Copies files to Azure Storage Account

    .DESCRIPTION
     Sets the given Storage Account to be locally accessible (SetStorageAccount -StorageAccoutnName $SAName)
    Creates a default container if it not exsits based on ( $Script:CONFIG.AutomationModuleContainer).
    Uploads given file $Path  to the container
    Create an accesible URI by concating AbsolutUri + SAS token for 30mins.

    .PARAMETER Packages
    List of packages to upload

    .PARAMETER ModuleName
    MOdule name to upload

    .PARAMETER Version
    Module Version to upload

    .PARAMETER StorageAccountName
    Storage Account Name to search for to upload files

    .EXAMPLE
      [array] $Blobs = Copy-ModuleToAzure -Packages $Packages -ModuleName $ModuleName -Version $Version -StorageAccountName $StorageAccountName


    #>
function Copy-ModuleToAzure {

    [CmdletBinding()]
    param (
        [parameter(Mandatory)]
        [array]$Packages,

        [parameter(Mandatory)]
        [string]$ModuleName,

        [parameter(Mandatory)]
        [string]$Version,

        [parameter(Mandatory)]
        [string]$StorageAccountName
    )

    process {
        # Set local Storage Account
        $null = Set-StorageAccount -StorageAccountName $StorageAccountName

        # Create default container on set storage account
        $null = New-ContainerIfNotExisting

        $moduleData = @()
        Foreach ($Package in $Packages) {

            $Name = $($ModuleName + '\' + $Version + '\' + $Package.BaseName + '.zip')

            # Upload file to set storage account into default container
            $Uri = New-UploadToStorageAccount -Path $Package.FullName -Name $Name

            Write-Verbose ("Returning upload data [Name:'{0}'|AbsoluteUri:'{1}']" -f $Package.BaseName, $Uri)
            $moduleData += @{
                Name        = $Package.BaseName
                AbsoluteUri = $Uri
            }
        }
        Write-Verbose ("Upload complete")

        return $moduleData
    }
}