param(
  [string]$TargetDir,
  [string]$RepoList
)

$ScriptDir = if ($PSScriptRoot) { $PSScriptRoot } elseif ($PSCommandPath) { Split-Path -LiteralPath $PSCommandPath -Parent } else { Get-Location }

if (-not $TargetDir) { $TargetDir = Join-Path $ScriptDir 'sapui5-repos' }
if (-not $RepoList)  { $RepoList  = Join-Path $ScriptDir 'sapui5-repos.txt' }

if (-not (Test-Path -LiteralPath $RepoList)) {
  Write-Error "List file not found: $RepoList"
  exit 1
}

New-Item -ItemType Directory -Force -Path $TargetDir | Out-Null
Set-Location -LiteralPath $TargetDir

Get-Content -LiteralPath $RepoList | ForEach-Object {
  $repo = $_.Trim()
  if ([string]::IsNullOrWhiteSpace($repo)) { return }
  if ($repo.StartsWith('#')) { return }
  $last = ($repo.TrimEnd('/') -split '/')[-1]
  $name = [IO.Path]::GetFileNameWithoutExtension($last)
  if (Test-Path -LiteralPath (Join-Path $TargetDir $name)) {
    Write-Host "Skip $name (exists)"
    return
  }
  git clone $repo
}
