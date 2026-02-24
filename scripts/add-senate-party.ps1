$ErrorActionPreference = "Stop"

function Read-RequiredText {
  param([string]$Prompt)
  while ($true) {
    $value = Read-Host $Prompt
    if (-not [string]::IsNullOrWhiteSpace($value)) { return $value.Trim() }
    Write-Host "This field is required." -ForegroundColor Yellow
  }
}

function Read-RequiredInt {
  param([string]$Prompt)
  while ($true) {
    $value = Read-Host $Prompt
    $parsed = 0
    if ([int]::TryParse($value, [ref]$parsed)) { return $parsed }
    Write-Host "Please enter a valid integer." -ForegroundColor Yellow
  }
}

$repoRoot = Split-Path -Parent $PSScriptRoot
$dataPath = Join-Path $repoRoot "src/data/senate-parties.json"
$parties = @((Get-Content $dataPath -Raw | ConvertFrom-Json))

$name = Read-RequiredText "Party name"
$seats = Read-RequiredInt "Seat count"
$color = Read-RequiredText "Color hex (e.g. #d8b26a)"

$parties += [PSCustomObject]@{ name = $name; seats = $seats; color = $color }
$parties | ConvertTo-Json -Depth 6 | Set-Content $dataPath -Encoding utf8
Write-Host "Senate party added." -ForegroundColor Green
