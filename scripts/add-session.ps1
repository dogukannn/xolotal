$ErrorActionPreference = "Stop"

function Read-RequiredText {
  param([string]$Prompt)

  while ($true) {
    $value = Read-Host $Prompt
    if (-not [string]::IsNullOrWhiteSpace($value)) {
      return $value.Trim()
    }
    Write-Host "This field is required." -ForegroundColor Yellow
  }
}

function Read-RequiredInt {
  param([string]$Prompt)

  while ($true) {
    $value = Read-Host $Prompt
    $parsed = 0
    if ([int]::TryParse($value, [ref]$parsed)) {
      return $parsed
    }
    Write-Host "Please enter a valid integer." -ForegroundColor Yellow
  }
}

$repoRoot = Split-Path -Parent $PSScriptRoot
$dataPath = Join-Path $repoRoot "src/data/sessions.json"

if (!(Test-Path $dataPath)) {
  throw "sessions.json not found at $dataPath"
}

$content = Get-Content $dataPath -Raw
if ([string]::IsNullOrWhiteSpace($content)) {
  $sessions = @()
} else {
  $sessions = $content | ConvertFrom-Json
  if ($sessions -isnot [System.Collections.IEnumerable]) {
    $sessions = @($sessions)
  }
}

Write-Host "Add a new session entry" -ForegroundColor Cyan
Write-Host "------------------------"

$title = Read-RequiredText "Session title"
$date = Read-RequiredText "Session date (YYYY-MM-DD)"
$threatPoints = Read-RequiredInt "Threat points"
$momentum = Read-RequiredInt "Momentum"
$determinationPoints = Read-RequiredInt "Determination points"

$spotlights = @()
Write-Host "Enter spotlight items one-by-one. Leave empty and press Enter to finish." -ForegroundColor Cyan
while ($true) {
  $spotlight = Read-Host "Spotlight"
  if ([string]::IsNullOrWhiteSpace($spotlight)) {
    break
  }
  $spotlights += $spotlight.Trim()
}

$notes = Read-Host "Notes (optional)"

$nextIndex = ($sessions | Measure-Object).Count + 1
$id = "session-{0:d3}" -f $nextIndex

$newSession = [PSCustomObject]@{
  id = $id
  title = $title
  date = $date
  threatPoints = $threatPoints
  momentum = $momentum
  determinationPoints = $determinationPoints
  spotlights = @($spotlights)
  notes = if ([string]::IsNullOrWhiteSpace($notes)) { "" } else { $notes.Trim() }
}

$updated = @($sessions) + $newSession
$updated | ConvertTo-Json -Depth 6 | Set-Content $dataPath -Encoding utf8

Write-Host "Added $id to $dataPath" -ForegroundColor Green
