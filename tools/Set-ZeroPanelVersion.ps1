param(
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidatePattern('^\d+\.\d+\.\d+(?:-[0-9A-Za-z.-]+)?$')]
    [string]$Version
)

$ErrorActionPreference = "Stop"

$rootPath = Split-Path -Parent $PSScriptRoot
$luaPath = Join-Path $rootPath "Zero_Panel.lua"
$addonPath = Join-Path $rootPath "Zero_Panel.addon"

$versionMatch = [regex]::Match($Version, '^(?<major>\d+)\.(?<minor>\d+)\.(?<patch>\d+)(?:-(?<prerelease>[0-9A-Za-z.-]+))?$')
if (-not $versionMatch.Success) {
    throw "Version must use semantic versioning: major.minor.patch or major.minor.patch-prerelease"
}

$major = [int]$versionMatch.Groups["major"].Value
$minor = [int]$versionMatch.Groups["minor"].Value
$patch = [int]$versionMatch.Groups["patch"].Value
$prerelease = $versionMatch.Groups["prerelease"].Value

if ($minor -gt 999 -or $patch -gt 999) {
    throw "Minor and patch must stay between 0 and 999 because AddOnVersion is encoded as major * 1000000 + minor * 1000 + patch."
}

$addOnVersion = ($major * 1000000) + ($minor * 1000) + $patch
$addOnVersionString = "{0:D7}" -f $addOnVersion
$prereleaseLiteral = if ([string]::IsNullOrWhiteSpace($prerelease)) { "nil" } else { '"' + $prerelease.Replace('"', '\"') + '"' }

$luaContent = Get-Content -Raw -Path $luaPath
$luaContent = [regex]::Replace($luaContent, 'major = \d+,', "major = $major,", 1)
$luaContent = [regex]::Replace($luaContent, 'minor = \d+,', "minor = $minor,", 1)
$luaContent = [regex]::Replace($luaContent, 'patch = \d+,', "patch = $patch,", 1)
$luaContent = [regex]::Replace($luaContent, 'prerelease = (?:nil|"[^"]*"),', "prerelease = $prereleaseLiteral,", 1)
Set-Content -Path $luaPath -Value $luaContent

$addonContent = Get-Content -Raw -Path $addonPath
$addonContent = [regex]::Replace($addonContent, '(?m)^## Version: .+$', "## Version: $Version", 1)
$addonContent = [regex]::Replace($addonContent, '(?m)^## AddOnVersion: .+$', "## AddOnVersion: $addOnVersionString", 1)
Set-Content -Path $addonPath -Value $addonContent

Write-Host "Updated Zero Panel to version $Version (AddOnVersion $addOnVersionString)."
