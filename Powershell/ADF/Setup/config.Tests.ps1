param (
    $ConfigFile = 'config.local.test.json'
)


Describe "config $ConfigFile" {
    $config = (Get-Content  -Raw (Join-Path $PSScriptRoot $ConfigFile ) -ErrorAction Stop) | ConvertFrom-Json  -ErrorAction Stop
    context "setup" {
        $TestCases = @(
            @{ Expected = "Company"},
            @{ Expected = "Environment"},
            @{ Expected = "Application"},
            @{ Expected = "Component"},
            @{ Expected = "Description"},
            @{ Expected = "Location"},
            @{ Expected = "ContributorGroupName"},
            @{ Expected = "ReaderGroupName"},
            @{ Expected = "LogAnalyticsWorkspaceName"},
            @{ Expected = "NumberOfAzIRs"}
        )
        it "should have <Expected>" -TestCases $TestCases {
            param(
                $Expected
            )

            $config.$Expected | Should -Not -BeNullOrEmpty
        }
    }
}