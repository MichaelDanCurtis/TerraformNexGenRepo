
function Save-PSModule {
    [CmdletBinding()]
    param (
        [parameter(Mandatory)]
        [string]$ModuleName,

        [parameter(Mandatory)]
        [string]$Version,

        [parameter(Mandatory)]
        [string]$repository
    )

    begin {
    }

    process {
        $ModuleFolder = $Script:TempFolder + '\' + $ModuleName
        $null = New-Item -Path $ModuleFolder -ItemType Directory -Force -ErrorAction Stop
        Write-Verbose "Downloading module packages into $ModuleFolder"

        if ($Script:Credential) {
            Save-Module -Name $ModuleName -RequiredVersion $Version -Path $ModuleFolder -Repository $repository -Credential $Script:Credential
        }
        else {
            Save-Module -Name $ModuleName -RequiredVersion $Version -Path $ModuleFolder -Repository $Repository
        }
        Write-Verbose "Download completed"

        [array]$Modules = Get-ChildItem -Path $ModuleFolder
        Write-Verbose ('{0} module(s) locally available' -f $modules.Count)

        Foreach ($Module in $Modules) {
            Write-Verbose ('Compressing module "{0}"' -f $Module.Name)
            Compress-Archive -Path $Module.FullName -DestinationPath $($Module.FullName + '.zip')
        }
        Write-Verbose "Zip packages created for all modules."

        Write-Verbose "Investigate module folder"
        Get-ChildItem $ModuleFolder
        Write-Verbose "==="
        $Packages = Get-ChildItem -File -Path $ModuleFolder -Filter "*.zip"

        return $Packages
    }

    end {
    }
}