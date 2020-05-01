function Get-StorageAccountNameForEnvironment {

    param(
          [Parameter(Mandatory = $true)]
          [string] $environment
    )

 $storageAccountName = $Script:Config.StorageAccountName[$Environment]
 return $storageAccountName
}