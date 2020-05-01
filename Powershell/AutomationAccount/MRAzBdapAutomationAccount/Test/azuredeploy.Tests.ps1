param (
    $Path = (Join-Path $PSScriptRoot '../Static')
)

$TemplatePath = Get-ChildItem -Path "$Path" -include "*azuredeploy.json" -Recurse

foreach ($Template in $TemplatePath) {

    $Path = $Template.FullName

    Describe "$Path should be valid" -Tag Unit {

        $null = Test-Path $Path -ErrorAction Stop

        try {
            $text = Get-Content $Path -Raw -ErrorAction Stop
        }
        catch {
            Write-Warning "$($_.Exception) found"
            Write-Verbose "$($_.ScriptStackTrace)"
            break
        }

        try {
            $json = ConvertFrom-Json $text -ErrorAction Stop
        }
        catch {
            $JsonException = $_
        }


        it "should throw no expection" {
            $JsonException | Should -BeNullOrEmpty
        }

        it "should have content" {
            $json | Should -Not -BeNullOrEmpty
        }


        $TestCases = @(
            @{
                Expected = "parameters"
            },
            @{
                Expected = "variables"
            },
            @{
                Expected = "resources"
            },
            @{
                Expected = "outputs"
            }
        )

        it "should have <Expected>" -TestCases $TestCases {
            param(
                $Expected
            )

            $json.$Expected | Should -Not -BeNullOrEmpty
        }

        context "parameters tests" {
            $parameters = $json.parameters | Get-Member -MemberType NoteProperty
            foreach ($parameter in $parameters) {
                $ParameterName = $($parameter.Name)
                it "$ParameterName should have metadata" {
                    $json.parameters.$ParameterName.metadata | Should -Not -BeNullOrEmpty
                }
            }
        }

        context "resources tests" {
            foreach ($resource in $json.resources) {
                $type = $resource.type
                it "$type should have comment" {
                    $resource.comments  | Should -Not -BeNullOrEmpty
                }
            }
        }

        context "resources structure test" {
            foreach ($resource in $json.resources) {
                it "$($resource.Type) should follow comment > type > apiVersion > name > properties" {
                    "$resource" | Should -BeLike "*comments*type*apiVersion*name*properties*"
                }
            }
        }

    }
}