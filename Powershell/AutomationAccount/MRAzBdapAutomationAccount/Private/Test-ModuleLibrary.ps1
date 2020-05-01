function Test-ModuleLibrary {
    [CmdletBinding()]
    [OutputType([Bool])]
    param (
        [Parameter(
            Mandatory = $true
        )]
        $ModuleName,

        [Parameter(
            Mandatory = $true,
            ParameterSetName = 'Version'
        )]
        $Version,

        [Parameter(
            Mandatory = $true,
            ParameterSetName = 'Repository'
        )]
        $Repository,

        [Parameter(
            Mandatory = $true,
            ParameterSetName = 'Repository'
        )]
        [PSCredential]$Credential,

        [Parameter(
            Mandatory = $true
        )]
        $Environment
    )

    begin {
    }

    process {
        $StorageAccountName = $Script:Config.StorageAccountName[$Environment]
        $ContainerName = $Script:CONFIG.AutomationModuleContainer
        $StorageAccount = Get-AzStorageAccount | Where-Object {$_.StorageAccountName -eq $StorageAccountName}
        if ($StorageAccount) {
            $null = Set-AzCurrentStorageAccount -Name $StorageAccountName -ResourceGroupName $StorageAccount.ResourceGroupName
        }
        else {
            Throw "Storage Account $StorageAccountName not found."
        }

        if ($PSCmdlet.ParameterSetName -eq 'Repository') {
            if ($Credential) {
                $Version = (Find-Module -Name $ModuleName -Repository $Repository -Credential $Credential).Version.ToString()
            }
            else {
                $Version = (Find-Module -Name $ModuleName -Repository $Repository).Version.ToString()
            }
        }

        [array] $Blobs = Get-AzStorageBlob -Container $ContainerName | Where-Object {$_.Name -like "$ModuleName/$Version/*"}

        if ($Blobs.Count -gt 0) {
            $true #packages available
        }
        else {
            $false #packages not available, must be downloaded
        }
    }

    end {
    }
}