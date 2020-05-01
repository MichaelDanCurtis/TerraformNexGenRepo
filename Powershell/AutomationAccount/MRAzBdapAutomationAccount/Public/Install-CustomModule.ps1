<#
    .SYNOPSIS
    Uploads the requested module from a Powershell Repository to Munich Re storage account and installs them on a given automation account

    .DESCRIPTION

    Uploads given modules by `-ModuleNames`, this is an array of module names that can be installed on a given Automation Account.
    Modules can be from a private nuget feed or from PSGallery.
    Modules will be also be uploaded to the given StorageAccount.
    Using a convention of  `$($ModuleName + '\' + $Version + '\' + $Package.BaseName + '.zip')` where ModuleName is the parent Module and the `Package.BaseName` the dependent modules. E.g. DSVM consist of different internal Modules that need to be present on the automation account too.

    // TODO: Currently it will only upload to an automation worker - not a hybrid worker!

    .PARAMETER ModuleConfig
    Object with module specifics.
    E.g. @{ "RequiredModules": [{"Name":"AzureAD","Version":"2.0.2.16","Repository":"PSGallery"}]}

    .PARAMETER ModuleConfigPath
    Path to a json file with module specifics

    .PARAMETER AutomationAccountName
    Name of the automation account to upload the modules to

    .PARAMETER ResourceGroupName
    Name of the resource group of the automation account

    .PARAMETER StorageAccountName
    Name of the storage account to upload modules to (optional). If not set, uses default (e.g. 'mrbdapsbxweauto')

    .PARAMETER Environment
    Required Environment param if not storage account name is provided to find default storage account

    .PARAMETER Confirm
    Will promt user to confirm the action to create invasible commands

    .PARAMETER WhatIf
    Dry run of the script

    .EXAMPLE
    Install-MRAzBdapAutomationAccountCustomModule -AutomationAccountName $accountName -ResourceGroupName $rgName -StorageAccountName $storageName -ModuleConfig @{ "RequiredModules": [{"Name":"AzureAD","Version":"2.0.2.16","Repository":"PSGallery"}]}  -Verbose

    Upload and install module 'AzureAD' in version 2.0.2.16 on storage account $accountName

    .EXAMPLE
    Install-MRAzBdapAutomationAccountCustomModule -AutomationAccountName $accountName -ResourceGroupName $rgName -StorageAccountName $storageName -ModuleConfig @{ "RequiredModules": [{"Name":"AzureAD","Repository":"PSGallery"}]}  -Verbose

    Upload and install module 'AzureAD' in the latest version on storage account $accountName

    .EXAMPLE
    Install-MRAzBdapAutomationAccountCustomModule -AutomationAccountName $accountName -ResourceGroupName $rgName -StorageAccountName $storageName -ModuleConfigPath 'C:/config.modules.json' -Verbose

    Upload and install the modules specified in the given config path on the storage account $accoutName
    #>

function Install-CustomModule {

    [CmdletBinding(SupportsShouldProcess = $True)]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingConvertToSecureStringWithPlainText", "", Justification = "Requried for pipeline logic")]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "ConfStorageAccount")]
        [Parameter(Mandatory = $true, ParameterSetName = "ConfNoStorageAccount")]
        [PSCustomObject] $ModuleConfig,

        [Parameter(Mandatory = $true, ParameterSetName = "NoConfStorageAccount")]
        [Parameter(Mandatory = $true, ParameterSetName = "NoConfNoStorageAccount")]
        [String] $ModuleConfigPath,

        [Parameter(Mandatory = $true, ParameterSetName = "ConfStorageAccount")]
        [Parameter(Mandatory = $true, ParameterSetName = "NoConfStorageAccount")]
        [string] $StorageAccountName,

        [Parameter(Mandatory = $true, ParameterSetName = "ConfNoStorageAccount")]
        [Parameter(Mandatory = $true, ParameterSetName = "NoConfNoStorageAccount")]
        [ValidateSet("prd", "int", "dev", "sbx", "tt", "prp", "inp", "dep", "sbp")]
        [Alias("Env")]
        [string] $Environment,

        [Parameter(Mandatory)]
        [string] $AutomationAccountName,

        [Parameter(Mandatory)]
        [string] $ResourceGroupName
    )

    # Load Config
    if (-not [String]::IsNullOrEmpty(($ModuleConfigPath))) {
        Write-Verbose "Load config from path $ModuleConfigPath"
        $ModuleConfig = (Get-Content -Raw $ModuleConfigPath) | ConvertFrom-Json
    }
    Write-Output "Config loaded"
    Write-Output "Parameters"
    Write-Output "=========="
    $ModuleConfig.RequiredModules
    Write-Output "=========="

    Write-Verbose "Load pipeline credentials"
    # Handle credentials (required for custom nuget feed)
    $isBuildPipeline = -not [string]::IsNullOrEmpty($env:BUILD_DEFINITIONNAME)
    $SECRET_NAME_CONST = 'BDAP_PAT_CREDMAN_NAME'

    if (-not $isBuildPipeline) {
        $cManSecretName = $SECRET_NAME_CONST
        $credential = Get-StoredCredential -Target $cManSecretName
    }
    elseif (-not [string]::IsNullOrEmpty($env:SYSTEM_ACCESSTOKEN)) {
        try {

            Write-Verbose ("Running in pipeline")
            $password = ConvertTo-SecureString $env:SYSTEM_ACCESSTOKEN -AsPlainText -Force
            $queueById = "Pipeline"
            $credential = New-Object System.Management.Automation.PSCredential ($queueById, $password)

        }
        catch {
            $_.Exception | Format-List * -Force | Out-String | Write-Verbose
            Write-Verbose $_
        }
    }
    else {
        throw "EC_PB_PAT: The systemaccesstoken must be provided if module is executed in pipline"
    }
    Write-Verbose "Pipeline credentials loaded"


    # Initiate logic
    if ($PSCmdlet.ShouldProcess("Custom modules on automation account '$AutomationAccountName'", "Install")) {
        foreach ($Module in $ModuleConfig.RequiredModules) {

            Write-Verbose ('Handling Storage account installation of module "{0}"' -f $Module.Name)
            $libraryInputObject = @{
                ModuleName = $Module.Name
            }
            if ($module.Repository -and -not ('PSGallery'.ToLower() -eq $module.Repository.ToLower())) {
                Write-Verbose ('Using credentials for repository "{0}"' -f $module.Repository)
                $libraryInputObject += @{ Credential = $credential }
            }
            if (-not [String]::IsNullOrEmpty($Module.Version)) {
                Write-Verbose ('Passing custom version "{0}"' -f $module.Version)
                $libraryInputObject += @{ Version = $Module.Version }
            }
            if ([String]::IsNullOrEmpty($module.Repository)) {
                Write-Verbose ('Passing default repo "{0}"' -f 'PSGallery')
                $libraryInputObject += @{ Repository = 'PSGallery' }
            }
            else {
                Write-Verbose ('Passing custom repo "{0}"' -f $Module.Repository)
                $libraryInputObject += @{ Repository = $Module.Repository }
            }
            if (-not [String]::IsNullOrEmpty($StorageAccountName)) {
                Write-Verbose ('Passing custom storage account "{0}"' -f $StorageAccountName)
                $libraryInputObject += @{ StorageAccountName = $StorageAccountName }
            }
            else {
                Write-Verbose ('Using environment "{0}" to get default storage account' -f $Environment)
                $libraryInputObject += @{ Environment = $Environment }
            }

            $Library = Update-MRAzBdapAutomationAccountModuleLibrary @libraryInputObject

            foreach ($Module in $Library) {
                $AutomationModule = @{
                    Name                  = [io.path]::GetFileNameWithoutExtension($Module.Name)
                    ContentLinkUri        = ([System.Uri] $Module.AbsoluteUri)
                    ResourceGroupName     = $ResourceGroupName
                    AutomationAccountName = $AutomationAccountName
                }
                Write-Verbose ('Handling Automation account installation of module "{0}"' -f $AutomationModule.Name)

                try {
                    Import-AzAutomationModule @AutomationModule -Verbose
                }
                catch {
                    $_.Exception | Format-List -Force | Out-String | Write-Verbose
                    Write-Error "Failed to import module $($Module.Name) to $AutomationAccountName"
                }
            }
        }
    }

    # Log errors
    $Global:Error | Format-List * -Force | Out-String | Write-Verbose
}