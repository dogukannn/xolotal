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
$dataPath = Join-Path $repoRoot "src/data/notable-characters.json"
if (!(Test-Path $dataPath)) { throw "notable-characters.json not found at $dataPath" }

$entries = @((Get-Content $dataPath -Raw | ConvertFrom-Json))
$name = Read-RequiredText "Character name"
$title = Read-RequiredText "Character title"
$portraitUrl = Read-RequiredText "Portrait URL"
$portraitAlt = Read-RequiredText "Portrait alt text"
$notes = Read-Host "Notes (optional)"

$entries += [PSCustomObject]@{
  name = $name
  title = $title
  portraitUrl = $portraitUrl
  portraitAlt = $portraitAlt
  notes = if ([string]::IsNullOrWhiteSpace($notes)) { "" } else { $notes.Trim() }
}

$entries | ConvertTo-Json -Depth 6 | Set-Content $dataPath -Encoding utf8
Write-Host "Notable character added." -ForegroundColor Green
