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
$dataPath = Join-Path $repoRoot "src/data/ruler.json"
if (!(Test-Path $dataPath)) { throw "ruler.json not found at $dataPath" }

$name = Read-RequiredText "Ruler name"
$title = Read-RequiredText "Ruler title"
$portraitUrl = Read-RequiredText "Portrait URL"
$portraitAlt = Read-RequiredText "Portrait alt text"

$ruler = [PSCustomObject]@{
  name = $name
  title = $title
  portraitUrl = $portraitUrl
  portraitAlt = $portraitAlt
}

$ruler | ConvertTo-Json -Depth 4 | Set-Content $dataPath -Encoding utf8
Write-Host "Ruler updated." -ForegroundColor Green
