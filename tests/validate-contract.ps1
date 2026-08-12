$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$repositoryRoot = Split-Path -Parent $PSScriptRoot
$schemaPath = Join-Path $repositoryRoot "schema.json"
$examplePath = Join-Path $repositoryRoot "example_profile.json"

$schema = Get-Content -Raw -LiteralPath $schemaPath | ConvertFrom-Json
$exampleJson = Get-Content -Raw -LiteralPath $examplePath
$example = $exampleJson | ConvertFrom-Json

$comparisonSchema = $schema.properties.stages.items.properties.exit_triggers.items.properties.comparison
$expectedComparisons = @(">", "<", ">=", "<=")
$actualComparisons = @($comparisonSchema.enum)

if (Compare-Object -ReferenceObject $expectedComparisons -DifferenceObject $actualComparisons) {
    throw "The comparison enum must accept exactly '>', '<', '>=', and '<=' without aliases."
}

if ($comparisonSchema.default -ne ">=") {
    throw "An omitted comparison must retain the existing '>=' compatibility behavior."
}

$triggerRequiredFields = @($schema.properties.stages.items.properties.exit_triggers.items.required)
if ($triggerRequiredFields -contains "comparison") {
    throw "The comparison field must remain optional."
}

function Test-ComparisonValidity {
    param(
        [AllowNull()]
        [object]$Comparison
    )

    return $null -eq $Comparison -or $actualComparisons -contains $Comparison
}

foreach ($comparison in $expectedComparisons) {
    if (-not (Test-ComparisonValidity -Comparison $comparison)) {
        throw "Supported comparison '$comparison' was rejected."
    }
}

if (-not (Test-ComparisonValidity -Comparison $null)) {
    throw "An omitted comparison was rejected."
}

foreach ($unsupportedComparison in @("==", "!=", "=>", "=<", "greater")) {
    if (Test-ComparisonValidity -Comparison $unsupportedComparison) {
        throw "Unsupported comparison '$unsupportedComparison' was accepted."
    }
}

$numericTriggerTypes = @("weight", "time", "pressure", "flow", "piston_position", "power")

foreach ($triggerType in $numericTriggerTypes) {
    foreach ($comparison in $expectedComparisons) {
        $trigger = [ordered]@{
            type = $triggerType
            value = 1
            relative = $false
            comparison = $comparison
            unrelated = "preserve-me"
        }
        $beforeValidation = $trigger | ConvertTo-Json -Compress

        if (-not (Test-ComparisonValidity -Comparison $trigger.comparison)) {
            throw "The '$triggerType' trigger rejected supported comparison '$comparison'."
        }

        $afterValidation = $trigger | ConvertTo-Json -Compress
        if ($afterValidation -cne $beforeValidation) {
            throw "Validating '$triggerType' with '$comparison' rewrote profile data."
        }
    }
}

$exampleBeforeValidation = $example | ConvertTo-Json -Depth 100 -Compress
foreach ($trigger in @($example.stages | ForEach-Object { $_.exit_triggers })) {
    if (-not (Test-ComparisonValidity -Comparison $trigger.comparison)) {
        throw "The repository example contains unsupported comparison '$($trigger.comparison)'."
    }
}
$exampleAfterValidation = $example | ConvertTo-Json -Depth 100 -Compress

if ($exampleAfterValidation -cne $exampleBeforeValidation) {
    throw "Contract validation rewrote the example profile."
}

Write-Output "Comparator contract validation passed."
