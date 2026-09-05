<#
.SYNOPSIS
    Schema-aware structural validation for SSRS RDL files.

.DESCRIPTION
    Detects an RDL's schema version from its ROOT NAMESPACE and validates that no
    element in the document requires a NEWER schema version than the one the document
    declares. This closes the gap where a 2016/01-only element (e.g. ReportParametersLayout)
    was introduced into a 2010/01 RDL and passed structural validation, only to be rejected
    by SSDT.

    The rule is generic and reusable: the mapping of element -> minimum schema version lives
    entirely in rdl-schema-compatibility.json. This script contains NO element-specific logic
    and NO blacklist — add gated elements to the registry, not to this file.

.NOTES
    Dot-source this script to reuse Test-RdlSchemaCompatibility, or invoke it directly with -Path.
    Exit codes (direct invocation): 0 = PASS, 1 = FAIL.
#>
[CmdletBinding()]
param(
    [string]$Path,
    [string]$RegistryPath,
    [switch]$Quiet
)

# Resolve the registry path in the body (top-level param defaults cannot reliably see
# $PSScriptRoot under `powershell -File` on Windows PowerShell 5.1).
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
if (-not $RegistryPath) { $RegistryPath = Join-Path $ScriptDir 'rdl-schema-compatibility.json' }

function Test-RdlSchemaCompatibility {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Path,
        [string]$RegistryPath = (Join-Path $PSScriptRoot 'rdl-schema-compatibility.json')
    )

    $result = [ordered]@{
        Path       = $Path
        Namespace  = $null
        Version    = $null
        Result     = 'FAIL'
        Violations = @()
        Message    = $null
    }

    if (-not (Test-Path -LiteralPath $Path)) {
        $result.Message = "File not found: $Path"
        return [pscustomobject]$result
    }
    if (-not (Test-Path -LiteralPath $RegistryPath)) {
        $result.Message = "Compatibility registry not found: $RegistryPath"
        return [pscustomobject]$result
    }

    $registry = Get-Content -LiteralPath $RegistryPath -Raw | ConvertFrom-Json
    $order = @($registry.versionOrder)

    # 1. Must be well-formed XML.
    $doc = New-Object System.Xml.XmlDocument
    try { $doc.Load($Path) } catch {
        $result.Message = "Invalid XML: $($_.Exception.Message)"
        return [pscustomobject]$result
    }

    # 2. Detect schema version from the root namespace.
    $ns = $doc.DocumentElement.NamespaceURI
    $result.Namespace = $ns
    $version = $registry.schemaVersions.$ns
    if (-not $version) {
        $result.Message = "Unrecognized RDL namespace; cannot determine schema version: $ns"
        return [pscustomobject]$result
    }
    $result.Version = $version
    $docIdx = $order.IndexOf($version)

    # 3. Walk every element in the DEFAULT RDL namespace (helper namespaces such as rd:/am:
    #    are ignored) and flag any whose minimum schema version is newer than the document's.
    $violations = [ordered]@{}
    $stack = New-Object System.Collections.Stack
    $stack.Push($doc.DocumentElement)
    while ($stack.Count -gt 0) {
        $node = $stack.Pop()
        if ($node.NamespaceURI -eq $ns) {
            $minVer = $registry.elementMinVersion.($node.LocalName)
            if ($minVer) {
                $minIdx = $order.IndexOf([string]$minVer)
                if ($minIdx -gt $docIdx -and -not $violations.Contains($node.LocalName)) {
                    $violations[$node.LocalName] = [string]$minVer
                }
            }
        }
        foreach ($child in $node.ChildNodes) {
            if ($child.NodeType -eq [System.Xml.XmlNodeType]::Element) { $stack.Push($child) }
        }
    }

    if ($violations.Count -gt 0) {
        $result.Violations = $violations.GetEnumerator() | ForEach-Object {
            [pscustomobject]@{ Element = $_.Key; RequiresVersion = $_.Value; DocumentVersion = $version }
        }
        $names = (@($violations.Keys) | Sort-Object) -join ', '
        $result.Result  = 'FAIL'
        $result.Message = "Schema-incompatible element(s) for RDL ${version}: $names"
    }
    else {
        $result.Result  = 'PASS'
        $result.Message = "All elements compatible with RDL $version."
    }
    return [pscustomobject]$result
}

# Direct invocation (skipped when the script is dot-sourced for reuse).
if ($MyInvocation.InvocationName -ne '.' -and $Path) {
    $r = Test-RdlSchemaCompatibility -Path $Path -RegistryPath $RegistryPath
    if (-not $Quiet) {
        Write-Output ("RESULT     : {0}" -f $r.Result)
        Write-Output ("NAMESPACE  : {0}" -f $r.Namespace)
        Write-Output ("VERSION    : {0}" -f $r.Version)
        Write-Output ("MESSAGE    : {0}" -f $r.Message)
        foreach ($v in $r.Violations) {
            Write-Output ("  VIOLATION: <{0}> requires RDL {1} but document declares RDL {2}" -f `
                $v.Element, $v.RequiresVersion, $v.DocumentVersion)
        }
    }
    if ($r.Result -eq 'PASS') { exit 0 } else { exit 1 }
}
