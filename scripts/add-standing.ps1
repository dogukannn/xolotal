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
$dataPath = Join-Path $repoRoot "src/data/power-standings.json"
$data = Get-Content $dataPath -Raw | ConvertFrom-Json
$standings = @($data.standings)

$name = Read-RequiredText "Person name"
$title = Read-RequiredText "Person title"
$standings += [PSCustomObject]@{ name = $name; title = $title }

$updated = [PSCustomObject]@{
  standings = $standings
  rivals = $data.rivals
  uniform = $data.uniform
}

$updated | ConvertTo-Json -Depth 8 | Set-Content $dataPath -Encoding utf8
Write-Host "Standing added." -ForegroundColor Green
