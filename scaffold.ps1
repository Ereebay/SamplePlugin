# Scaffolds a new AssettoServer plugin from this template.
#
# Usage:  .\scaffold.ps1 -Name MyThing
#         (PascalCase; a trailing "Plugin" suffix is optional and normalized)
#
# What it does:
#   * renames SamplePlugin.csproj, the Sample*.cs classes and the lang/lua files
#   * rewrites namespaces, class names, lang-key prefixes, routes and docs
#   * deletes itself — the result is your plugin, not a template
#
# Afterwards:  git add -A; git commit -m "scaffold <name>"; set your remote.

param(
    [Parameter(Mandatory = $true)]
    [ValidatePattern('^[A-Z][A-Za-z0-9]+$')]
    [string]$Name
)

$ErrorActionPreference = 'Stop'
$root = $PSScriptRoot
Set-Location $root

$base = $Name -creplace 'Plugin$'
if ([string]::IsNullOrWhiteSpace($base) -or $base.Length -lt 2) {
    throw "Name '$Name' is too generic - use e.g. 'TougeTraining', not just 'Plugin'."
}
$plugin   = "${base}Plugin"
$pluginLc = $plugin.ToLowerInvariant()
$baseLc   = $base.ToLowerInvariant()

# --- 1) rename files --------------------------------------------------------
$renames = [ordered]@{
    'SamplePlugin.csproj'             = "$plugin.csproj"
    'Sample.cs'                       = "$base.cs"
    'SampleModule.cs'                 = "$($base)Module.cs"
    'SampleConfiguration.cs'          = "$($base)Configuration.cs"
    'SampleConfigurationValidator.cs' = "$($base)ConfigurationValidator.cs"
    'SampleCommandModule.cs'          = "$($base)CommandModule.cs"
    'SampleController.cs'             = "$($base)Controller.cs"
    'lang\SamplePlugin.en-US.yml'     = "lang\$plugin.en-US.yml"
    'lang\SamplePlugin.zh-CN.yml'     = "lang\$plugin.zh-CN.yml"
    'lua\sample.lua'                  = "lua\$baseLc.lua"
}
foreach ($k in $renames.Keys) {
    if (Test-Path -LiteralPath $k) {
        Move-Item -LiteralPath $k -Destination $renames[$k]
    } else {
        Write-Warning "expected '$k' not found - skipped"
    }
}

# --- 2) rewrite contents ----------------------------------------------------
# Longest tokens first so 'SamplePlugin' is never mangled by the 'Sample' rule.
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$exts = '.cs', '.csproj', '.yml', '.lua', '.md'
$files = Get-ChildItem -LiteralPath $root -Recurse -File |
    Where-Object {
        $_.FullName -notmatch '\\.git(\\|$)' -and
        $_.Name -ne 'scaffold.ps1' -and
        $exts -contains $_.Extension
    }

foreach ($f in $files) {
    $c = [System.IO.File]::ReadAllText($f.FullName)
    $n = $c
    $n = $n -creplace 'SamplePlugin', $plugin
    $n = $n -creplace 'sampleplugin', $pluginLc
    $n = $n -creplace 'plugin\.sample\.', "plugin.$baseLc."
    $n = $n -creplace 'sample\.lua', "$baseLc.lua"
    $n = $n -creplace 'Sample', $base
    if ($n -ne $c) {
        [System.IO.File]::WriteAllText($f.FullName, $n, $utf8NoBom)
        Write-Host "rewrote  $($f.FullName.Substring($root.Length + 1))"
    }
}

# --- 3) done ----------------------------------------------------------------
Remove-Item -LiteralPath "$root\scaffold.ps1"

Write-Host ""
Write-Host "Scaffolded '$plugin'. Next:"
Write-Host "  git add -A; git commit -m 'scaffold $plugin'"
Write-Host "  git remote set-url origin <your-new-repo-url>"
Write-Host "  dotnet build -c Release    (from inside the host checkout)"
