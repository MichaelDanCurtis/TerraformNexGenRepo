# Load module and dependencies
. "$PSScriptRoot\Shared.ps1"
. "$ModuleBase\Private\Get-StorageAccountNameForEnvironment.ps1"

$testConfPath = Join-Path $PSScriptRoot 'resources'
$sbxWeTestFiles = Get-ChildItem -Path "$testConfPath/*" -Include "*deployment.sbx.we*.json"
foreach ($testFile in $sbxWeTestFiles) {
    $testDate = (Get-Date -Format FileDateTimeUniversal).TrimEnd('Z')

    $filePath = $testFile.FullName
    Write-Verbose "Load configuration test file from $filePath ..."
    $testConfig = Get-Content $filePath -Raw | ConvertFrom-Json
    $testConfig
    $testConfig.Descriptor = ("{0}{1}" -f $testConfig.Descriptor, $testDate.Substring($testDate.Length - 4))

    $ResourceGroupInputObject = @{
        Company     = $testConfig.Company
        Application = $testConfig.Application
        Environment = $testConfig.Environment
        Component   = 'Auto'
        MrLocation  = 'WE'
    }
    $resourceGroupName = ('{0}-{1}' -f (Get-MRAzBdapResourceGroupName @ResourceGroupInputObject), $testConfig.Descriptor)
    Write-Verbose "ResourceGroupName: '$resourceGroupName'"

    if ([string]::IsNullOrEmpty($testConfig.ComponentName)) {
        $InputObjectComponent = @{
            Company     = $testConfig.Company
            Application = $testConfig.Application
            Environment = $testConfig.Environment
            Descriptor  = $testConfig.Descriptor
        }
        $ComponentName = Get-MRAzBdapAutomationAccountName @InputObjectComponent
    }
    else {
        $ComponentName = $testConfig.ComponentName
    }
    Write-Verbose "ComponentName: '$ComponentName'"

    $Location = 'WestEurope' # its always gonna be West Europe by design.
    $StorageAccountName = ('mrbdaptt{0}we{1}' -f $testConfig.Environment, $testConfig.Descriptor).ToLower()

    $env:testConfigPath = $filePath
    $env:testConfig = $testConfig
    $env:resourceGroupName = $resourceGroupName
    $env:ComponentName = $ComponentName
    $env:Location = $Location
    $env:StorageAccountName = $StorageAccountName

    InModuleScope MRAzBdapAutomationAccount {

        $testConfigPath = $env:testConfigPath
        $testConfig = Get-Content $testConfigPath -Raw | ConvertFrom-Json
        $resourceGroupName = $env:resourceGroupName
        $ComponentName = $env:ComponentName
        $Location = $env:Location
        $StorageAccountName = $env:StorageAccountName

        . "$PSScriptRoot\Helper\Test-Deployment.ps1"

        Describe ('{0} - Set-MRAzBdapautomationAccountUp integration tests SBX WE' -f (Split-Path $testConfigPath -Leaf)) -Tag 'Integration', 'SBX_WE' {

            BeforeAll {
                $VerbosePreference = "Continue"
                Write-Verbose "BeforeAll: Remove resource group '$resourceGroupName' containing AutomationAccount '$ComponentName'"
                Get-AzResourceGroup -Name $ResourceGroupName  -ErrorAction SilentlyContinue | Remove-AzResourceGroup -Force
                Write-Verbose "BeforeAll: Removed AutomationAccount resource "

                Write-Verbose "BeforeAll: Setup resource group '$resourceGroupName'"
                $null = New-AzResourceGroup -Name $ResourceGroupName -Location $Location
                Write-Verbose "BeforeAll: Setup storage account '$StorageAccountName'"
                $null = New-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccountName -Location $Location -SkuName Standard_LRS
                $VerbosePreference = "SilentlyContinue"
            }

            AfterAll {
                $VerbosePreference = "Continue"
                Write-Verbose "AfterAll: Remove resource group '$resourceGroupName' containing AutomationAccount '$ComponentName'"
                Get-AzResourceGroup -Name $ResourceGroupName  -ErrorAction SilentlyContinue | Remove-AzResourceGroup -Force -AsJob
                Write-Verbose "AfterAll: Removed AutomationAccount resource (as job)"
                $VerbosePreference = "SilentlyContinue"
            }

            Mock New-MRAzBdapResourceGroupComponent { return @{ 'ResourceGroupName' = $env:resourceGroupName } }
            Mock Get-StorageAccountNameForEnvironment { return $env:StorageAccountName }
            Mock Get-MRAzBdapAutomationAccountName { return $env:ComponentName }

            $env:RELEASE_RELEASENAME = "Set-Up Test Release"

            Test-Deployment -testConfig $testConfig -ComponentName $ComponentName -resourceGroupName $resourceGroupName -MrLocation 'WE'
        }
    }
}

$devWeTestFiles = Get-ChildItem -Path "$testConfPath/*" -Include "*deployment.dev.we*json"
foreach ($testFile in $devWeTestFiles) {
    $testDate = (Get-Date -Format FileDateTimeUniversal).TrimEnd('Z')

    $filePath = $testFile.FullName
    Write-Verbose "Load configuration test file from $filePath ..."
    $testConfig = Get-Content $filePath -Raw | ConvertFrom-Json
    $testConfig
    $testConfig.Descriptor = ("{0}{1}" -f $testConfig.Descriptor, $testDate.Substring($testDate.Length - 4))

    $ResourceGroupInputObject = @{
        Company     = $testConfig.Company
        Application = $testConfig.Application
        Environment = $testConfig.Environment
        Component   = 'Auto'
        MrLocation  = 'WE'
    }
    $resourceGroupName = ('{0}-{1}' -f (Get-MRAzBdapResourceGroupName @ResourceGroupInputObject), $testConfig.Descriptor)
    Write-Verbose "ResourceGroupName: '$resourceGroupName'"

    if ([string]::IsNullOrEmpty($testConfig.ComponentName)) {
        $InputObjectComponent = @{
            Company     = $testConfig.Company
            Application = $testConfig.Application
            Environment = $testConfig.Environment
            Descriptor  = $testConfig.Descriptor
        }
        $ComponentName = Get-MRAzBdapAutomationAccountName @InputObjectComponent
    }
    else {
        $ComponentName = $testConfig.ComponentName
    }
    Write-Verbose "ComponentName: '$ComponentName'"

    $Location = 'WestEurope'
    $StorageAccountName = ('mrbdaptt{0}we{1}' -f $testConfig.Environment, $testConfig.Descriptor).ToLower()

    $env:testConfigPath = $filePath
    $env:testConfig = $testConfig
    $env:resourceGroupName = $resourceGroupName
    $env:ComponentName = $ComponentName
    $env:Location = $Location
    $env:StorageAccountName = $StorageAccountName

    InModuleScope MRAzBdapAutomationAccount {

        $testConfigPath = $env:testConfigPath
        $testConfig = Get-Content $testConfigPath -Raw | ConvertFrom-Json
        $resourceGroupName = $env:resourceGroupName
        $ComponentName = $env:ComponentName
        $Location = $env:Location
        $StorageAccountName = $env:StorageAccountName

        . "$PSScriptRoot\Helper\Test-Deployment.ps1"

        Describe ('{0} - Set-MRAzBdapautomationAccountUp integration tests DEV WE' -f (Split-Path $testConfigPath -Leaf)) -Tag 'Integration', 'DEV_WE' {

            BeforeAll {
                $VerbosePreference = "Continue"
                Write-Verbose "BeforeAll: Remove resource group '$resourceGroupName' containing AutomationAccount '$ComponentName'"
                Get-AzResourceGroup -Name $ResourceGroupName  -ErrorAction SilentlyContinue | Remove-AzResourceGroup -Force
                Write-Verbose "BeforeAll: Removed AutomationAccount resource "

                Write-Verbose "BeforeAll: Setup resource group '$resourceGroupName'"
                $null = New-AzResourceGroup -Name $ResourceGroupName -Location $Location
                Write-Verbose "BeforeAll: Setup storage account '$StorageAccountName'"
                $null = New-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccountName -Location $Location -SkuName Standard_LRS
                $VerbosePreference = "SilentlyContinue"
            }

            AfterAll {
                $VerbosePreference = "Continue"
                Write-Verbose "AfterAll: Remove resource group '$resourceGroupName' containing AutomationAccount '$ComponentName'"
                Get-AzResourceGroup -Name $ResourceGroupName  -ErrorAction SilentlyContinue | Remove-AzResourceGroup -Force -AsJob
                Write-Verbose "AfterAll: Removed AutomationAccount resource (as job)"
                $VerbosePreference = "SilentlyContinue"
            }

            Mock New-MRAzBdapResourceGroupComponent { return @{ 'ResourceGroupName' = $env:resourceGroupName } }
            Mock Get-StorageAccountNameForEnvironment { return $env:StorageAccountName }
            Mock Get-MRAzBdapAutomationAccountName { return $env:ComponentName }

            $env:RELEASE_RELEASENAME = "Set-Up Test Release"

            Test-Deployment -testConfig $testConfig -ComponentName $ComponentName -resourceGroupName $resourceGroupName -MrLocation 'WE'
        }
    }
}
