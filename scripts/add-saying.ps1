$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$dataPath = Join-Path $repoRoot "src/data/sayings.json"

if (!(Test-Path $dataPath)) { throw "sayings.json not found at $dataPath" }

$content = Get-Content $dataPath -Raw
$sayings = if ([string]::IsNullOrWhiteSpace($content)) { @() } else { @($content | ConvertFrom-Json) }

while ($true) {
  $value = Read-Host "New saying"
  if (-not [string]::IsNullOrWhiteSpace($value)) {
    $sayings += $value.Trim()
    break
  }
  Write-Host "Please enter a saying." -ForegroundColor Yellow
}

$sayings | ConvertTo-Json -Depth 4 | Set-Content $dataPath -Encoding utf8
Write-Host "Saying added to $dataPath" -ForegroundColor Green
