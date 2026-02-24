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
$dataPath = Join-Path $repoRoot "src/data/house-minor-briefings.json"
if (!(Test-Path $dataPath)) { throw "house-minor-briefings.json not found at $dataPath" }

$entries = @((Get-Content $dataPath -Raw | ConvertFrom-Json))
$date = Read-RequiredText "Briefing date (YYYY-MM-DD)"
$note = Read-RequiredText "Briefing note"

$entries += [PSCustomObject]@{ date = $date; note = $note }
$entries | ConvertTo-Json -Depth 6 | Set-Content $dataPath -Encoding utf8
Write-Host "Briefing note added." -ForegroundColor Green
