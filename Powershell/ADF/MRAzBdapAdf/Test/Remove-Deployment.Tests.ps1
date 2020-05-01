1# Load module and dependencies
. "$PSScriptRoot\Shared.ps1"

InModuleScope -ModuleName MRAzBdapAdf -ScriptBlock {
    # Load testing values from config
    $config = Get-Content -Raw (Join-Path $PSScriptRoot "resources/config.adf.removal.json") | ConvertFrom-Json
    $TestDateTime = $(Get-Date -Format FileDateTime)
    $ResourceGroupName = 'mr-bdap-tt-we-ADFREMOVAL{0}' -f $TestDateTime
    $config

    $MrLocation = Get-MRAzBdapSharedLocation -Location $config.Location

    # STORAGE ACCOUNT INFO
    $StorageNameInput = @{
        Company     = $config.Company
        Application = $config.Application
        Environment = $config.Environment
        MrLocation  = $MrLocation
        Descriptor  = $config.Description
    }
    $StorageAccountName = Get-MRAzBdapStorageName @StorageNameInput

    # Name
    # ADF INFO
    if (-not ([string]::IsNullOrEmpty($Config.ComponentName))) {
        $AdfComponentName = $Config.ComponentName
        $kvltComponentName = $Config.ComponentName
    }
    else {
        $adfNameInput = @{
            Company     = $Config.Company
            Application = $Config.Application
            Environment = $Config.Environment
            MrLocation  = $MrLocation
            Description = $Config.Description
        }
        $adfComponentName = Get-MrAzBdapAdfName @adfNameInput # Actually uses this function
        $kvltComponentName = $adfComponentName
    }

    Describe "Remove-MRAzBdapAdfDeployment integration tests" -Tags Build {

        BeforeAll {
            Write-Verbose "BeforeAll: Create Environment..."
            Get-AzResourceGroup $ResourceGroupName -ErrorAction SilentlyContinue | Remove-AzResourceGroup -Force
            $null = New-AzResourceGroup -Name $ResourceGroupName -Location $config.Location
            Write-Verbose "BeforeAll: Start Test"
        }

        AfterAll {
            Write-Verbose "AfterAll: Remove ResourceGroup..."
            Get-AzResourceGroup $ResourceGroupName -ErrorAction SilentlyContinue | Remove-AzResourceGroup -Force
            Write-Verbose "AfterAll: Finish Test"
        }

        Context "Removal testing" {

            Mock New-MRAzBdapResourceGroupComponent { return  @{ResourceGroupName = $ResourceGroupName } } -ModuleName 'MRAzBdapAdf'
            Mock Get-MRAzBdapResourceGroupName { return  $ResourceGroupName } -ModuleName 'MRAzBdapAdf'
            Mock New-MRAzBdapRBACRoleAssignment { return "RBAC was set" } -ModuleName 'MRAzBdapAdf'
            Mock Set-MrAzBdapStorageRbac { return "RBAC was set" } -ModuleName 'MRAzBdapStorage'

            It "Deployment should not throw any exception" {
                { Set-MRAzBdapAdfUp -Config $config } | Should -Not -Throw
                Write-Verbose ("Deployed adf '{0}'" -f $kvlt.KeyVaultName)
            }

            It ("Azure Datafactory '$AdfComponentName' should be deployed") {
                $resultingAdf = Get-AzDataFactoryV2 -Name $AdfComponentName  -ResourceGroupName $resourceGroupName -ErrorAction SilentlyContinue
                $resultingAdf.DataFactoryId | Should -Not -BeNullOrEmpty
            }

            It ("Storage Account '$StorageAccountName' should be deployed") {
                $resultingStorageAccount = Get-AzStorageAccount -Name $StorageAccountName  -ResourceGroupName $resourceGroupName -ErrorAction SilentlyContinue
                $resultingStorageAccount.Id | Should -Not -BeNullOrEmpty
            }

            It ("Key Vault '$KvltComponentName' should be deployed") {
                $resultingKeyVault = Get-AzKeyVault -VaultName $KvltComponentName  -ResourceGroupName $resourceGroupName -ErrorAction SilentlyContinue
                $resultingKeyVault.ResourceId | Should -Not -BeNullOrEmpty
            }

            Write-Verbose "Trigger removal"
            Remove-MrAzBdapAdfDeployment -config $config -Verbose

            It "Azure DataFactory '$AdfComponentName' should be deleted from resource group '$ResourceGroupName'" {
                $resultingAdf = Get-AzDataFactoryV2 -Name $AdfComponentName  -ResourceGroupName $resourceGroupName -ErrorAction SilentlyContinue
                $resultingAdf.DataFactoryId | Should -BeNullOrEmpty
            }

            It "Storage Account '$StorageAccountName' should be deleted from resource group '$ResourceGroupName'" {
                $resultingStorageAccount = Get-AzStorageAccount -Name $StorageAccountName  -ResourceGroupName $resourceGroupName -ErrorAction SilentlyContinue
                $resultingStorageAccount.Id | Should -BeNullOrEmpty
            }

            It "KeyVault '$KvltComponentName' should be deleted from resource group '$ResourceGroupName'" {
                $resultingKeyVault = Get-AzKeyVault -VaultName $KvltComponentName  -ResourceGroupName $resourceGroupName -ErrorAction SilentlyContinue
                $resultingKeyVault.ResourceId | Should -BeNullOrEmpty
            }
        }
    }
}