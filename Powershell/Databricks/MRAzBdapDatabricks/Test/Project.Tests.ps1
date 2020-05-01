# Load module and dependencies
. "$PSScriptRoot\Shared.ps1"
$FunctionHelpTestExceptions = Get-Content -Path "$ModuleBase\Test\Help.Exceptions.txt"

Describe "PSScriptAnalyzer rule-sets" -Tag ScriptAnalyzer {

    $Rules = Get-ScriptAnalyzerRule
    $scripts = Get-ChildItem $ModuleBase -Include *.ps1, *.psm1, *.psd1 -Recurse | Where-Object fullname -notmatch 'classes'

    foreach ( $Script in $scripts ) {
        Context "Script '$($script.FullName)'" {

            foreach ( $rule in $rules ) {
                # Skip all rules that are on the exclusions list
                if ($FunctionHelpTestExceptions -contains $rule.RuleName) { continue }
                It "Rule [$rule]" {

                    (Invoke-ScriptAnalyzer -Path $script.FullName -IncludeRule $rule.RuleName ).Count | Should Be 0
                }
            }
        }
    }
}


Describe "General project validation: $moduleName" -Tag Build {
    BeforeAll {
        Get-Module $ModuleName | Remove-Module
    }
    It "Module '$moduleName' can import cleanly" {
        { Import-Module $ModuleBase\$ModuleName.psd1 -force } | Should Not Throw
    }
}


Describe "Exported functions evaluation" -Tag Build {

    $manifest = Import-PowerShellDataFile $moduleManifestPath
    $commandPrefix = $manifest.DefaultCommandPrefix

    BeforeAll {
        Get-Module $ModuleName | Remove-Module
        Import-Module $ModuleBase\$ModuleName.psd1 -force
    }

    # Build the expected functions from the public folder
    $plainPublicFunctions = (Get-ChildItem -Path "$ModuleBase\Public" -Filter '*.ps1').BaseName
    $expectedFunctions = @()
    foreach ($func in $plainPublicFunctions) {
        $functionParts = $func.Split('-')
        $expectedFunction = "{0}-{1}{2}" -f $functionParts[0], $commandPrefix , $functionParts[1]
        $expectedFunctions += $expectedFunction
    }

    # Get the actually exported functions by the module
    $actualFunctions = (Get-Module -Name $ModuleName).ExportedFunctions

    # Run the tests
    foreach ($expectedFunction in $expectedFunctions) {
        It "Correct export of $expectedFunction" {
            $actualFunctions.ContainsKey($expectedFunction) | Should Be $true
        }
    }
}

Describe "Evaluate publish module" -Tag Build {

    $date = Get-Date -Format FileDateTimeUniversal
    $repositoryName = "testRepo-$date"
    $repositoryPath = "$TestDrive\$repositoryName"
    $moduleManifestPath = "$moduleBase\$moduleName.psd1"

    Context "Local repository" {

        Mock Split-Path { return $ModuleBase } -ParameterFilter { $Path -eq "$PSScriptRoot" }

        BeforeAll {
            Write-Verbose "BeforeAll: Setup test environment"
            $repoExisting = Test-Path "$repositoryPath/$repositoryName"
            if (-not $repoExisting) {
                Write-Verbose "Adding local repo '$repositoryName' "
                New-Item -path "$repositoryPath/$repositoryName" -type Directory
            }
            else {
                Write-Verbose "Local repo '$repositoryPath/$repositoryName' already existing"
            }

            Write-Verbose "Register local repository '$repositoryName'"
            $regRepos = (Get-PSRepository).Name
            if ($regRepos -notcontains $repositoryName) {
                Register-PSRepository -Name $repositoryName -SourceLocation $repositoryPath -ScriptSourceLocation $repositoryPath -InstallationPolicy "Trusted" -Verbose
            }
            Write-Verbose ("Available PSRepositories: {0}" -f ((Get-PSRepository).Name -join ', '))

            Write-Verbose "Replace with temporal manifest"
            Rename-Item -Path $moduleManifestPath -NewName ("{0}_t.psd1" -f $ModuleName)
            Copy-Item -Path ("$ModuleBase\{0}_t.psd1" -f $ModuleName) -Destination $moduleManifestPath

            Write-Verbose "Set current required modules as ExternalModuleDependencies"
            $manifest = Import-PowerShellDataFile $moduleManifestPath
            $currentRequiredModuleNames = $manifest.RequiredModules.ModuleName
            $currentExternalModuleDependencies = $manifest.PrivateData.PSData.ExternalModuleDependencies
            $newExternalModuleDependencies = ([array] $currentRequiredModuleNames + $currentExternalModuleDependencies) | Select-Object -Unique
            if ($newExternalModuleDependencies) {
                Update-ModuleManifest -Path $moduleManifestPath -ExternalModuleDependencies $newExternalModuleDependencies
            }
        }

        AfterAll {
            Write-Verbose "AfterAll: Tear down test environment"
            Write-Verbose "Remove local test repository"
            Remove-Item -Path "$repositoryPath/$repositoryName" -Force -Recurse

            Write-Verbose "Unregister repositories"
            $regRepos = (Get-PSRepository).Name
            if ($regRepos -contains $repositoryName) {
                Write-Verbose "Unregister PSRepository '$repositoryName'"
                Unregister-PSRepository -Name $repositoryName
            }

            Write-Verbose "Fall back to original manifest"
            if (Test-Path ("$ModuleBase\{0}_t.psd1" -f $ModuleName)) {
                # Only remove if temp creation worked
                Remove-Item -Path $moduleManifestPath -Force
                Rename-Item -Path ("$ModuleBase\{0}_t.psd1" -f $ModuleName) -NewName "$ModuleName.psd1"
            }
        }

        It "Publish successful to local repo" {
            . "$ModuleBase\Pipeline\lib\Invoke-Build.ps1"
            { Invoke-Build -feedName $repositoryName -feedurl $repositoryPath -systemAccessToken 'abc' -queueById 'test@munichre.com' -verbose } | Should -Not -Throw

            $module = Find-Module $ModuleName -Repository $repositoryName
            $module | Should -Not -BeNullOrEmpty
        }
    }
}