<#
.SYNOPSIS
!This script is not officially supported by Microsoft.!
Installed requested PowerShell Module

.DESCRIPTION
!This script is not officially supported by Microsoft.!
Checks if the provided module is already on the computer
If not with the correct version or exsisting at all, the script tries to download and install the module.

There are two options.
1. runs `install-module` on the PSGallery
2. runs git actions
    a. clone on from the provided repository
    b. pull from the master

The module is then loaded with `import-module`

.PARAMETER RequiredModule
Module to be loaded

.PARAMETER Path
Path of the root folder, will download remote repositories there

.PARAMETER Scope
Scope of the installation, for PSGallery

.EXAMPLE
Install-Dependency -RequiredModule @{ ModuleSpecification = @{ ModuleName = "Pester"; RequiredVersion = "4.4.1" }; Repository = "PSGallery" } -Path "C:/dev" -Scope "User"

ModuleType Version    Name                                ExportedCommands
---------- -------    ----                                ----------------
Script     4.4.1      Pester                              {Add-AssertionOperator, AfterAll, AfterEach, AfterEachFeature...}

.EXAMPLE
Install-Dependency -RequiredModule @{ ModuleSpecification = @{ ModuleName = "MRAzBdapShared"; RequiredVersion = "0.0.0" }; Repository = "https://apps-munichre.visualstudio.com/DefaultCollection/Big%20Data%20and%20Analytics%20Platform/_git/bdap-az-automation-vnet"" } -Path "../" -Scope "User"

ModuleType Version    Name                                ExportedCommands
---------- -------    ----                                ----------------
Script     0.1.0      MRAzBdapShared                         {...}

Notice, RequiredVersion 0.0.0 will indicate latest, if remote git repository is provided, the version number is not considered
Notice the Path is relative to the execution of the script. It uses `(Get-Item $PSScriptRoot).parent.parent.FullName`

.NOTES
This command will only clone the master branch.
If you want to reuse the cloned repo you have to reset the fetch. (Git version 1.8.2.)
Run:
    `git config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"`
    `git fetch origin`
Now it will in sync with the origin

.LINK
https://apps-munichre.visualstudio.com/Big%20Data%20and%20Analytics%20Platform/_wiki/wikis/Big-Data-and-Analytics-Platform.wiki?wikiVersion=GBwikiMaster&pagePath=%2FDevelopment%20Guidelines%2FPowerShell%2FPowerShell%20Dependencies
#>

# Author: <mark.warneke@micorsoft.com>
# This script is not officially supported by Microsoft.

function Add-ExistingModule {
    <#
    .SYNOPSIS
    Imports existing module

    .DESCRIPTION
    Lists all modules and import if the module is exsisting and has specified version

    .PARAMETER ModuleSpecification
    Module specification object to be imported

    .EXAMPLE
    Add-ExsistingModule -ModuleSpecification @{ ModuleName = "Pester"; RequiredVersion = "3.4.0 " }

    ModuleType Version    Name                                ExportedCommands
    ---------- -------    ----                                ----------------
    Script     3.4.0      Pester                              {Describe, Context, It, Should...}
    #>

    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $true
        )]
        [Microsoft.PowerShell.Commands.ModuleSpecification[]] $ModuleSpecification
    )

    process {

        $Name = $ModuleSpecification.Name
        $RequiredVersion = $ModuleSpecification.RequiredVersion

        if ($RequiredVersion -eq "0.0.0") {
            Write-Warning "Specified version of module $Name is 0.0.0. Artifacts are avoided. Code is checked out."
            return
        }

        Write-Verbose "Query Module $Name Version $RequiredVersion"
        $IsKnownModule = Get-Module -Name $Name -ListAvailable

        if ($IsKnownModule) {
            if ( $IsKnownModule.Version -contains $RequiredVersion) {

                Write-Verbose "Module $Name Version $RequiredVersion found, import"
                try {

                    $Module = @{
                        Name            = $Name
                        RequiredVersion = $RequiredVersion
                    }
                    Import-Module @Module -Force -PassThru -ErrorAction Stop
                    Write-Output "Import-Module $Name"
                }
                catch {
                    $Exception = $_
                    Write-Error "Exception found `n $($Exception.Exception)"
                }

            }
            else {
                $versions = $IsKnownModule.Version
                Write-Warning ('Module {0} found, but Version missmatch expected {1}, but got {2}' -f $Name, $RequiredVersion, "$versions")

                Import-Module -Name $Name -Force -PassThru -ErrorAction Stop
                Write-Output "Import-Module $Name with known version"
            }

        }
        else {
            Write-Warning "Module $ModuleName not found"
        }
    }
}


function Install-GalleryModule {
    <#
    .SYNOPSIS
    Installed provided PSGallery module

    .DESCRIPTION
    Sets the correct polciy
    Runs install-module
    resets to the original policy

    .PARAMETER ModuleSpecification
    Module specification of to be installed module

    .PARAMETER Repository
    Repository is PSGallery

    .PARAMETER Scope
    Scope to be installed, default is CurrentUser

    .EXAMPLE
    Install-GalleryModule -ModuleSpecification @{ ModuleName = "Pester"; RequiredVersion = "4.4.1" } -Repository "PSGallery"
    #>


    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $true
        )]
        [Microsoft.PowerShell.Commands.ModuleSpecification[]] $ModuleSpecification,

        [string] $Repository = "PSGallery",

        [ValidateSet("CurrentUser", "AllUsers")]
        [string]  $Scope = "CurrentUser"
    )
    process {

        Write-Verbose "$Repository"

        try {

            $ExistingPolicy = (Get-PSRepository $Repository).InstallationPolicy
            $null = Set-PSRepository $Repository -InstallationPolicy Trusted -ErrorAction Stop

            Install-Module -Name $ModuleSpecification.Name -RequiredVersion $ModuleSpecification.RequiredVersion.ToString() -Scope $Scope -Repository $Repository -SkipPublisherCheck -Verbose -ErrorAction Stop

            Import-Module -FullyQualifiedName  $ModuleSpecification -PassThru -Force -ErrorAction Stop

        }
        catch {
            $Exception = $_
            Write-Error "$ModuleSpecification could not be installed `n $Exception"
        }
        finally {
            # Undo changes
            $null = Set-PSRepository $Repository -InstallationPolicy $ExistingPolicy
        }
    }
}


function Install-GitModule {
    <#
    .SYNOPSIS
    Clones or updates master branch of provided git repository then imports it

    .DESCRIPTION
    Tests provided Path if an existing repository witht the same name exists.
    If there is an existing it will attempt to run `git pull`
    If no directory is found the script attempt to run `git pull`

    If successful it will import the module

    .PARAMETER ModuleSpecification
    Module specification to be imported, must be child of the repository path.
    The Module name must match the manifest file.

    .PARAMETER Repository
    Repository name, can be any link to a git PowerShell repository
    The moduel should be in the root folder of the repository

    .PARAMETER Path
    Path to the new repository

    .PARAMETER Test
    Will not checkout to master

    .EXAMPLE
    Install-GitModule -ModuleSpecification @{ ModuleName = "MRAzBdapShared"; RequiredVersion = "0.0.0" } -Repository "https://apps-munichre.visualstudio.com/DefaultCollection/Big%20Data%20and%20Analytics%20Platform/_git/bdap-az-automation-shared" -Path "C:/dev/"

    will clone or or pull master branch then import the module
    #>

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(
            Mandatory = $true
        )]
        [Microsoft.PowerShell.Commands.ModuleSpecification[]] $ModuleSpecification,

        [Parameter(
            Mandatory = $true
        )]
        [string] $Repository,

        [Parameter(
            Mandatory = $true
        )]
        [string] $Path,
        [switch] $Test = $false
    )

    process {
        Write-Verbose "Repository $Repository"
        Write-Verbose "Local Path $Path"

        $RepositoryName = ($Repository -split '/')[-1]
        Write-Verbose "RepositoryName $RepositoryName"

        try {
            $RepositoryRootPath = Join-Path $Path $RepositoryName
            $ModuleRootPath = Join-Path $RepositoryRootPath $ModuleName
            $ModulePath = Join-Path $ModuleRootPath "$ModuleName.psd1"

            Write-Verbose "RepositoryRootPath $RepositoryRootPath"
            Write-Verbose "ModuleRootPath $ModuleRootPath"
            Write-Verbose "ModulePath $ModulePath"


            if (Test-Path $RepositoryRootPath ) {

                Write-Verbose "Repository $RepositoryName found"
                $null = Invoke-GitPull -Path $RepositoryRootPath -Test:$Test
            }
            else {
                # Clone into repositories parent folder to be on same level
                $null = Invoke-GitClone -Path $RepositoryRootPath -Repository $Repository
            }

            if (Test-Path $ModuleRootPath) {
                Write-Verbose "Module $ModuleName found"

                Import-Module $ModulePath -Force -PassThru -ErrorAction Stop

            }
            else {
                Write-Error "Module Path not found $ModulePath"
            }

        }
        catch {
            $Exception = $_
            Write-Error -Message $Exception.Exception.Message
        }
    }
}

function Invoke-GitPull {
    <#
    .SYNOPSIS
    Runs `git pull` on a the master branch of provided directory path

    .DESCRIPTION
    Changes the directory to the provided path
    Runs `git checkout master` and trys to run `git pull` afterwards
    Changes back to the original path

    Will fetch the latest changes to an existing repository.

    .PARAMETER Path
    Path to the directory

    .PARAMETER Branch
    Branch to be checked out to. By default master

    .PARAMETER TEST
    Will not checkout to master

    .EXAMPLE
    Invoke-GitPull -Path "C:/dev/gitRepo"

    #>

    [CmdletBinding(SupportsShouldProcess)]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingInvokeExpression", "", Justification = "Needed for using git command")]
    param (
        [Parameter(
            Mandatory = $true
        )]
        [string] $Path,

        [Parameter()]
        [string] $Branch = "master",
        [switch] $Test = $false
    )

    begin {
        $GitCheckoutCommand = "git checkout $branch"
        $GitPullCommand = "git pull"
    }

    process {

        try {
            Write-Verbose "Change to path $Path"
            Push-Location $Path
            Write-Verbose "Inside $(Get-Location)"

            if ($PSCmdlet.ShouldProcess($GitCheckoutCommand, $Path)) {
                if (-Not $Test) {
                    # git checkout master
                    Write-Verbose "$GitCheckoutCommand"
                    $checkoutReturn = Invoke-Expression "& $GitCheckoutCommand 2>&1"
                    Write-Verbose "$checkoutReturn"

                    if ($checkoutReturn) {
                        # Expceting: error: Your local changes to the following files would be overwritten by checkout:
                        if ($checkoutReturn[0] -match "error") {
                            throw Format-GitError -Message $checkoutReturn
                        }
                    }
                }

                # git pull
                Write-Verbose "$GitPullCommand"
                $pullReturn = Invoke-Expression "& $GitPullCommand 2>&1"
                Write-Verbose "$pullReturn"

                if ($pullReturn) {
                    # Expceting: error
                    if ($pullReturn[0] -match "error") {
                        throw Format-GitError -Message $pullReturn
                    }
                }

                $pullReturn
            }
            else {

                Write-Output $GitCheckoutCommand
                Write-Output $GitPullCommand
            }

        }
        catch {
            $Exception = $_
            Write-Error -Message $Exception.Exception.Message
            throw $Exception
        }
        finally {
            Pop-Location
        }
    }

}


function Invoke-GitClone {
    <#
    .SYNOPSIS
    Invokes `git clone {0} {1} --single-branch`.
    Will clone repository master into the specified path

    .DESCRIPTION
     Invokes `git clone {0} {1} --single-branch`.
    Will clone repository master into the specified path

    See Notes how to fetch all branches

    .PARAMETER Repository
    URL to the target repository

    .PARAMETER Path
    Path where the repository should be cloned locally

    .EXAMPLE
    Invoke-GitClone -Repository "https://github.com/Azure/azure-powershell.git" -Path "C:/temp/"

    .NOTES
    This command will only clone the master branch.
    If you want to reuse the cloned repo you have to reset the fetch. (Git version 1.8.2.)
    Run:
      `git config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"`
      `git fetch origin`
    Now it will in sync with the origin
    #>

    [CmdletBinding(SupportsShouldProcess)]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingInvokeExpression", "", Justification = "Needed for using git command")]
    param (
        [Parameter(
            Mandatory = $true
        )]
        [string]
        $Repository,

        [Parameter(
            Mandatory = $true
        )]
        [string]
        $Path
    )

    begin {
        if ( $Env:SYSTEM_ACCESSTOKEN) {
            [uri] $Uri = $Repository
            if ($Uri) {
                $AccessToken = $Env:SYSTEM_ACCESSTOKEN
                $Repository = 'https://{0}@{1}{2}' -f $AccessToken, $uri.Host, $uri.PathAndQuery
            }
            else {
                Write-Error "Repository can NOT be remapped to use access token"
            }
        }
        $InstallCommand = 'git clone "{0}" "{1}" --single-branch'
    }

    process {
        Write-Verbose "Clone $Repository into $Path"

        $Repository = Invoke-EscapeString $Repository
        $Path = Invoke-EscapeString $Path

        $Command = ($InstallCommand -f $Repository, $Path)

        if ($PSCmdlet.ShouldProcess($Command)) {
            try {
                Write-Verbose "$Command"
                $cloneReturn = Invoke-Expression $Command
                Write-Verbose "$cloneReturn"
                if ($cloneReturn) {
                    # expecting: fatal: repository 'https://apps-munichre.visualstudio.com/DefaultCollection/Big%20Data%20and%20Analytics%20Platform/_git/bdap-az-automation-notthereyet/' not found
                    if ($cloneReturn[1] -match "fatal") {
                        throw Format-GitError -Message  $cloneReturn
                    }
                }
            }
            catch {
                $Exception = $_
                throw $Exception
            }

            $installReturn
        }
        else {
            Write-Output $Command
        }
    }
}


function Install-Dependency {
    <#
    .SYNOPSIS
    Installed requested PowerShell Module

    .DESCRIPTION
    Checks if the provided module is already on the computer
    If not with the correct version or exsisting at all, the script tries to downlaod and install the module.

    There are two options.
    1. runs `install-module` on the PSGallery
    2. runs git actions
      a. clone on from the provided repository
      b. pull from the master

    The module is then loaded with `import-module`

    .PARAMETER RequiredModule
    Module to be loaded

    .PARAMETER Path
    Path of the root folder, will download remote repositories there

    .PARAMETER Scope
    Scope of the installation, for PSGallery

    .PARAMETER Test
    Will not checkout to master

    .EXAMPLE
    Install-Dependency -RequiredModule @{ ModuleSpecification = @{ ModuleName = "Pester"; RequiredVersion = "4.4.1" }; Repository = "PSGallery" } -Path "C:/dev" -Scope "User"

    ModuleType Version    Name                                ExportedCommands
    ---------- -------    ----                                ----------------
    Script     4.4.1      Pester                              {Add-AssertionOperator, AfterAll, AfterEach, AfterEachFeature...}

    .EXAMPLE
    Install-Dependency -RequiredModule @{ ModuleSpecification = @{ ModuleName = "MRAzBdapShared"; RequiredVersion = "0.0.0" }; Repository = "https://apps-munichre.visualstudio.com/DefaultCollection/Big%20Data%20and%20Analytics%20Platform/_git/bdap-az-automation-vnet"" } -Path "../" -Scope "User"

    ModuleType Version    Name                                ExportedCommands
    ---------- -------    ----                                ----------------
    Script     0.1.0      MRAzBdapShared                         {...}

    Notice, RequiredVersion 0.0.0 will indicate latest, if remote git repository is provided, the version number is not considered
    Notice the Path is relative to the execution of the script. It uses `(Get-Item $PSScriptRoot).parent.parent.FullName`

    .NOTES
    This command will only clone the master branch.
    If you want to reuse the cloned repo you have to reset the fetch. (Git version 1.8.2.)
    Run:
      `git config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"`
      `git fetch origin`
    Now it will in sync with the origin

    #>

    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $true
        )]
        $RequiredModule,

        [Parameter(
            Mandatory = $true
        )]
        [string] $Path,

        [Parameter(
            Mandatory = $true
        )]
        [string] $Scope,
        [switch] $Test = $false
    )

    begin {
        $URL_PATTERN = "https://www.*"
    }
    process {
        foreach ($Module in $RequiredModule) {
            [Microsoft.PowerShell.Commands.ModuleSpecification[]] $RequiredModuleSpecification = [Microsoft.PowerShell.Commands.ModuleSpecification] $Module.ModuleSpecification
            $ModuleName = $RequiredModuleSpecification.Name
            $Repository = $Module.Repository

            Write-Verbose "Install Dependency Module $ModuleName from Repository $Repository"

            $importedExisting = Add-ExistingModule $RequiredModuleSpecification
            $importedExisting

            if ($importedExisting) { continue }

            if (! ($Repository -like $URL_PATTERN)) {
                Write-Verbose "Install from gallery"
                Install-GalleryModule -ModuleSpecification $RequiredModuleSpecification -Scope $Scope -Repository $Repository

            }
            else {
                Write-Verbose "Assume git repository"
                Install-GitModule -ModuleSpecification $RequiredModuleSpecification -Repository $Repository -Path $Path  -Test:$Test
            }
        }
    }
}

function Format-GitError {
    <#
    .SYNOPSIS
    Format the error of git

    .DESCRIPTION
    Format the error by removing ":"
    Tries to replace tabs and new lines

    .PARAMETER Message
    Git error message to be formated

    .EXAMPLE
    Format-GitError -Message "(& git pull 2>&1)"

    Error from Git

    #>

    [CmdletBinding()]
    param (
        $Message
    )

    process {
        <#
            git checkout master
            # error: Your local changes to the following files would be overwritten by checkout:
            # 	MRAzBdapInstall/install.Tests.ps1	MRAzBdapInstall/install.ps1Please commit your changes or stash them before you switch branches.Aborting
        #>

        $combinedMessage = "$Message"
        $replacedMessage = $combinedMessage.Replace(":", "").Replace('\\t', " ").Replace('\\n', " ")

        return $replacedMessage
    }
}

function Invoke-EscapeString {
    <#
    .SYNOPSIS
    Escapes a given string by '$', ';', ''', '""'

    .DESCRIPTION
    Escapes a given string by '$', ';', ''', '""'

    .PARAMETER String
    String to be escape

    .EXAMPLE
    Invoke-EscapeString "Asd$fasd'asd"asdsa;"

    .NOTES
    General notes
    #>

    [CmdletBinding()]
    param (
        [string] $String
    )

    process {
        return $string.replace('$', '').replace(';', '').replace("'", '''').replace('"', '\`"')
    }
}