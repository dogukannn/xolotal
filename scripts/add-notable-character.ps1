$ErrorActionPreference = "Stop"

function Read-RequiredText {
  param([string]$Prompt)
  while ($true) {
    $value = Read-Host $Prompt
    if (-not [string]::IsNullOrWhiteSpace($value)) { return $value.Trim() }
    Write-Host "This field is required." -ForegroundColor Yellow
  }
}

function Read-PositiveInt {
  param([string]$Prompt)
  while ($true) {
    $value = Read-Host $Prompt
    if ([int]::TryParse($value, [ref]$parsed) -and $parsed -gt 0) { return $parsed }
    Write-Host "Please enter a positive number." -ForegroundColor Yellow
  }
}

$repoRoot = Split-Path -Parent $PSScriptRoot
$dataPath = Join-Path $repoRoot "src/data/notable-characters.json"
if (!(Test-Path $dataPath)) { throw "notable-characters.json not found at $dataPath" }

$entries = @((Get-Content $dataPath -Raw | ConvertFrom-Json))
$name = Read-RequiredText "Character name"
$title = Read-RequiredText "Character title"
$portraitAlt = Read-RequiredText "Portrait alt text"
$notes = Read-Host "Notes (optional)"
$sourceUrl = Read-RequiredText "Source image URL"
$width = Read-PositiveInt "Target width"
$height = Read-PositiveInt "Target height"

$entries += [PSCustomObject]@{
  name = $name
  title = $title
  portraitUrl = $sourceUrl
  portraitAlt = $portraitAlt
  notes = if ([string]::IsNullOrWhiteSpace($notes)) { "" } else { $notes.Trim() }
  image = [PSCustomObject]@{
    sourceUrl = $sourceUrl
    width = $width
    height = $height
  }
}

$entries | ConvertTo-Json -Depth 8 | Set-Content $dataPath -Encoding utf8
Write-Host "Notable character added. Run npm run sync:portraits to generate local resized images." -ForegroundColor Green
