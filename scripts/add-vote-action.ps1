$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$dataPath = Join-Path $repoRoot "src/data/vote-actions.json"
$actions = @((Get-Content $dataPath -Raw | ConvertFrom-Json))

while ($true) {
  $value = Read-Host "New vote action"
  if (-not [string]::IsNullOrWhiteSpace($value)) {
    $actions += $value.Trim()
    break
  }
  Write-Host "Please enter an action." -ForegroundColor Yellow
}

$actions | ConvertTo-Json -Depth 4 | Set-Content $dataPath -Encoding utf8
Write-Host "Vote action added." -ForegroundColor Green
