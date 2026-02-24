$ErrorActionPreference = "Stop"

function Read-RequiredText {
  param([string]$Prompt)
  while ($true) {
    $value = Read-Host $Prompt
    if (-not [string]::IsNullOrWhiteSpace($value)) { return $value.Trim() }
    Write-Host "This field is required." -ForegroundColor Yellow
  }
}

$repoRoot = Split-Path -Parent $PSScriptRoot
$dataPath = Join-Path $repoRoot "src/data/settlements.json"
$entries = @((Get-Content $dataPath -Raw | ConvertFrom-Json))

$label = Read-RequiredText "Settlement label"
$value = Read-RequiredText "Settlement value"
$entries += [PSCustomObject]@{ label = $label; value = $value }
$entries | ConvertTo-Json -Depth 6 | Set-Content $dataPath -Encoding utf8
Write-Host "Settlement added." -ForegroundColor Green
