# Load module and dependencies
. "$PSScriptRoot\Shared.ps1"
InModuleScope -ModuleName MRAzBdapAutomationAccount -ScriptBlock {
    # Load testing values from config
    $config = Get-Content -Raw (Join-Path $PSScriptRoot "Resources/config.test.remove.automationaccount.json") | ConvertFrom-Json
    $TestDateTime = $(Get-Date -Format FileDateTime)
    $ResourceGroupName = 'mr-bdap-tt-we-AutoAccRemoval{0}' -f $TestDateTime
    $Location = "westeurope"
    $spName = "Ser-Az-mrbdapttwe-AutoAccRemoval{0}" -f $TestDateTime
    $config

    $InputObjectComponent = @{
        Company     = $Config.Company
        Application = $Config.Application
        Environment = $Config.Environment
        Descriptor  = $Config.Descriptor
    }

    $ComponentName = Get-MRAzBdapAutomationAccountName @InputObjectComponent -Verbose
    Describe "Remove-MRAzBdapAutomationAccountDeployment integration tests" -Tags Build {

        BeforeAll {
            Write-Verbose "BeforeAll: Create Environment..."
            Get-AzResourceGroup $ResourceGroupName -ErrorAction SilentlyContinue | Remove-AzResourceGroup -Force
            $null = New-AzResourceGroup -Name $ResourceGroupName -Location $Location
            Write-Verbose "BeforeAll: Start Test"
        }

        AfterAll {
            Write-Verbose "AfterAll: Remove ResourceGroup..."
            Get-AzResourceGroup $ResourceGroupName -ErrorAction SilentlyContinue | Remove-AzResourceGroup -Force
            Write-Verbose "AfterAll: Finish Test"
        }

        Context "Removal testing" {

            Mock New-MRAzBdapResourceGroupComponent { return  @{ResourceGroupName = $ResourceGroupName } } -ModuleName 'MRAzBdapAutomationAccount'
            Mock Get-MRAzBdapServicePrincipalName { return  $spName } -ModuleName 'MRAzBdapAutomationAccount'
            It "Automation Account should not throw any exception" {
                { Set-MRAzBdapAutomationAccountUp -Config $config } | Should -Not -Throw
                Write-Verbose ("Deployed Automation Account ")
            }

            It ("Automation Account should be deployed") {
                $component = Get-AzAutomationAccount -Name $ComponentName  -ResourceGroupName $resourceGroupName
                $component | Should -Not -BeNullOrEmpty
            }

            It "Automation Account should be deleted" {
                Remove-MrAzBdapAutomationAccountDeployment -config $config -Verbose
                $component = Get-AzAutomationAccount -Name $ComponentName  -ResourceGroupName $resourceGroupName -ErrorAction SilentlyContinue
                $component | Should -BeNullOrEmpty
            }

            It "Service Principals and corresponding certificates should be removed" {
                $MrLocation = Get-MRAzBdapSharedLocation -Location "westeurope"
                $VaultName = Get-MrAzBdapKvltName -Company $Config.Company -Application $Config.Application -Environment $Config.Environment -MrLocation $MrLocation
                Get-AzKeyVaultCertificate -VaultName $VaultName -Name "$spName-pfx" | Should -BeNullOrEmpty
                Get-AzKeyVaultSecret -VaultName $VaultName -Name "$spName-Password" | Should -BeNullOrEmpty
                Get-AzADServicePrincipal -ServicePrincipalName $spName | Should -BeNullOrEmpty
            }
        }
    }
}