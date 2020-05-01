

function Find-ModuleVersion {

    param(
        [Parameter(Mandatory = $false)]
        [string] $Version = 'latest',

        [Parameter(Mandatory = $false)]
        [PSCredential] $Credential,

        [Parameter(Mandatory = $true)]
        [string] $ModuleName,

        [Parameter(Mandatory = $true)]
        [string] $Repository
    )

    Write-Verbose "Find Module Version inside"
    if ($Version -eq 'latest') {
        if ($Credential) {
            $Version = (Find-Module -Name $ModuleName -Repository $Repository -Credential $Credential).Version.ToString()
        }
        else {
            $Version = (Find-Module -Name $ModuleName -Repository $Repository).Version.ToString()
        }
        Write-Verbose "Latest version of module $ModuleName is $Version"
    }
    else {
        Write-Verbose "Selected module: $ModuleName $Version"
    }
    return $Version
}
