<#
.SYNOPSIS
    Regression tests for schema-aware RDL structural validation.

.DESCRIPTION
    Runs Test-RdlSchemaCompatibility against the fixtures and asserts the expected
    PASS/FAIL outcome for each. Exit code 0 = all expectations met, 1 = at least one
    regression.

.EXAMPLE
    powershell -NoProfile -File Run-RdlSchemaTests.ps1
#>
[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'

. (Join-Path (Join-Path $PSScriptRoot '..') 'Validate-RdlSchema.ps1')

$fixtureDir = Join-Path $PSScriptRoot 'fixtures'
$cases = @(
    @{ File = '2010-parameters-layout-INVALID.rdl'; Expected = 'FAIL' }  # the exact reported bug
    @{ File = '2010-parameters-VALID.rdl';          Expected = 'PASS' }  # valid 2010 parameter example
    @{ File = '2010-reportsections-VALID.rdl';      Expected = 'PASS' }  # existing 2010 structures still pass
    @{ File = '2016-parameters-layout-VALID.rdl';   Expected = 'PASS' }  # schema-aware, not a blacklist
)

$failures = 0
foreach ($c in $cases) {
    $r = Test-RdlSchemaCompatibility -Path (Join-Path $fixtureDir $c.File)
    $ok = ($r.Result -eq $c.Expected)
    if (-not $ok) { $failures++ }
    Write-Output ("[{0}] {1,-38} expected={2,-4} actual={3,-4} | {4}" -f `
        ($(if ($ok) { 'OK  ' } else { 'FAIL' })), $c.File, $c.Expected, $r.Result, $r.Message)
}

Write-Output ''
if ($failures -eq 0) {
    Write-Output ("ALL TESTS PASSED ({0} cases)" -f $cases.Count)
    exit 0
}
else {
    Write-Output ("TESTS FAILED: {0} of {1} case(s) regressed" -f $failures, $cases.Count)
    exit 1
}
