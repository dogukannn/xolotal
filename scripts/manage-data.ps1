$ErrorActionPreference = "Stop"

function Read-RequiredText {
  param([string]$Prompt)
  while ($true) {
    $value = Read-Host $Prompt
    if (-not [string]::IsNullOrWhiteSpace($value)) { return $value.Trim() }
    Write-Host "This field is required." -ForegroundColor Yellow
  }
}

function Read-OptionalText {
  param([string]$Prompt)
  $value = Read-Host $Prompt
  if ([string]::IsNullOrWhiteSpace($value)) { return "" }
  return $value.Trim()
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

function Read-PositiveInt {
  param([string]$Prompt)
  while ($true) {
    $value = Read-Host $Prompt
    $parsed = 0
    if ([int]::TryParse($value, [ref]$parsed) -and $parsed -gt 0) { return $parsed }
    Write-Host "Please enter a positive number." -ForegroundColor Yellow
  }
}

function Load-JsonArray {
  param([string]$Path)
  if (!(Test-Path $Path)) { throw "JSON file not found at $Path" }

  $content = Get-Content $Path -Raw
  if ([string]::IsNullOrWhiteSpace($content)) { return @() }

  $parsed = ConvertFrom-Json $content
  if ($parsed -is [System.Collections.IEnumerable] -and $parsed -isnot [string]) {
    return @($parsed)
  }

  return @($parsed)
}

function Save-Json {
  param(
    [string]$Path,
    [Parameter(Mandatory = $true)]$Value,
    [int]$Depth = 8
  )

  $Value | ConvertTo-Json -Depth $Depth | Set-Content $Path -Encoding utf8
}

$repoRoot = Split-Path -Parent $PSScriptRoot
function Add-Saying {
  $dataPath = Join-Path $repoRoot "src/data/sayings.json"
  $items = Load-JsonArray -Path $dataPath
  $items += Read-RequiredText "New saying"
  Save-Json -Path $dataPath -Value $items -Depth 4
  Write-Host "Saying added." -ForegroundColor Green
}

function Add-VoteAction {
  $dataPath = Join-Path $repoRoot "src/data/vote-actions.json"
  $items = Load-JsonArray -Path $dataPath
  $items += Read-RequiredText "New vote action"
  Save-Json -Path $dataPath -Value $items -Depth 4
  Write-Host "Vote action added." -ForegroundColor Green
}

function Add-BriefingNote {
  $dataPath = Join-Path $repoRoot "src/data/house-minor-briefings.json"
  $items = Load-JsonArray -Path $dataPath

  $items += [PSCustomObject]@{
    date = Read-RequiredText "Briefing date (YYYY-MM-DD)"
    note = Read-RequiredText "Briefing note"
  }

  Save-Json -Path $dataPath -Value $items -Depth 6
  Write-Host "Briefing note added." -ForegroundColor Green
}

function Add-Settlement {
  $dataPath = Join-Path $repoRoot "src/data/settlements.json"
  $items = Load-JsonArray -Path $dataPath

  $items += [PSCustomObject]@{
    label = Read-RequiredText "Settlement label"
    value = Read-RequiredText "Settlement value"
  }

  Save-Json -Path $dataPath -Value $items -Depth 6
  Write-Host "Settlement added." -ForegroundColor Green
}

function Add-SenateParty {
  $dataPath = Join-Path $repoRoot "src/data/senate-parties.json"
  $items = Load-JsonArray -Path $dataPath

  $items += [PSCustomObject]@{
    name = Read-RequiredText "Party name"
    seats = Read-RequiredInt "Seat count"
    color = Read-RequiredText "Color hex (e.g. #d8b26a)"
  }

  Save-Json -Path $dataPath -Value $items -Depth 6
  Write-Host "Senate party added." -ForegroundColor Green
}

function Add-Standing {
  $dataPath = Join-Path $repoRoot "src/data/power-standings.json"
  if (!(Test-Path $dataPath)) { throw "power-standings.json not found at $dataPath" }

  $data = Get-Content $dataPath -Raw | ConvertFrom-Json
  $standings = @($data.standings)
  $standings += [PSCustomObject]@{
    name = Read-RequiredText "Person name"
    title = Read-RequiredText "Person title"
  }

  $updated = [PSCustomObject]@{
    standings = $standings
    rivals = $data.rivals
    uniform = $data.uniform
  }

  Save-Json -Path $dataPath -Value $updated -Depth 8
  Write-Host "Standing added." -ForegroundColor Green
}

function Add-Session {
  $dataPath = Join-Path $repoRoot "src/data/sessions.json"
  $sessions = Load-JsonArray -Path $dataPath

  Write-Host "Add a new session entry" -ForegroundColor Cyan
  Write-Host "------------------------"

  $spotlights = @()
  Write-Host "Enter spotlight items one-by-one. Leave empty and press Enter to finish." -ForegroundColor Cyan

  $title = Read-RequiredText "Session title"
  $date = Read-RequiredText "Session date (YYYY-MM-DD)"
  $threatPoints = Read-RequiredInt "Threat points"
  $momentum = Read-RequiredInt "Momentum"
  $determinationPoints = Read-RequiredInt "Determination points"

  while ($true) {
    $spotlight = Read-Host "Spotlight"
    if ([string]::IsNullOrWhiteSpace($spotlight)) { break }
    $spotlights += $spotlight.Trim()
  }

  $nextIndex = ($sessions | Measure-Object).Count + 1
  $newSession = [PSCustomObject]@{
    id = ("session-{0:d3}" -f $nextIndex)
    title = $title
    date = $date
    threatPoints = $threatPoints
    momentum = $momentum
    determinationPoints = $determinationPoints
    spotlights = @($spotlights)
    notes = Read-OptionalText "Notes (optional)"
  }

  $updated = @($sessions) + $newSession
  Save-Json -Path $dataPath -Value $updated -Depth 6
  Write-Host "Session added." -ForegroundColor Green
}

function Update-Ruler {
  $dataPath = Join-Path $repoRoot "src/data/ruler.json"
  if (!(Test-Path $dataPath)) { throw "ruler.json not found at $dataPath" }

  $portraitUrl = Read-RequiredText "Portrait URL (must start with /images/)"
  if (-not $portraitUrl.StartsWith('/images/')) {
    throw "Ruler portrait must use a public image path under /images/..."
  }

  $publicRelative = $portraitUrl.TrimStart('/')
  $imagePath = Join-Path $repoRoot "public/$publicRelative"
  if (!(Test-Path $imagePath)) {
    throw "Image not found at $imagePath. Add it under public/images first."
  }

  $ruler = [PSCustomObject]@{
    name = Read-RequiredText "Ruler name"
    title = Read-RequiredText "Ruler title"
    portraitUrl = $portraitUrl
    portraitAlt = Read-RequiredText "Portrait alt text"
    width = Read-PositiveInt "Rendered image width"
    height = Read-PositiveInt "Rendered image height"
  }

  Save-Json -Path $dataPath -Value $ruler -Depth 4
  Write-Host "Ruler updated." -ForegroundColor Green
}

function Add-NotableCharacter {
  $dataPath = Join-Path $repoRoot "src/data/notable-characters.json"
  $entries = Load-JsonArray -Path $dataPath

  $portraitUrl = Read-RequiredText "Portrait URL (must start with /images/)"
  if (-not $portraitUrl.StartsWith('/images/')) {
    throw "Portrait URL must use a public image path under /images/..."
  }

  $publicRelative = $portraitUrl.TrimStart('/')
  $imagePath = Join-Path $repoRoot "public/$publicRelative"
  if (!(Test-Path $imagePath)) {
    throw "Image not found at $imagePath. Add it under public/images first."
  }

  $entries += [PSCustomObject]@{
    name = Read-RequiredText "Character name"
    title = Read-RequiredText "Character title"
    portraitUrl = $portraitUrl
    portraitAlt = Read-RequiredText "Portrait alt text"
    notes = Read-OptionalText "Notes (optional)"
    width = Read-PositiveInt "Rendered image width"
    height = Read-PositiveInt "Rendered image height"
  }

  Save-Json -Path $dataPath -Value $entries -Depth 8
  Write-Host "Notable character added." -ForegroundColor Green
}

$menu = @(
  [PSCustomObject]@{ key = "1"; label = "Add saying"; action = { Add-Saying } },
  [PSCustomObject]@{ key = "2"; label = "Add vote action"; action = { Add-VoteAction } },
  [PSCustomObject]@{ key = "3"; label = "Add House Minor briefing note"; action = { Add-BriefingNote } },
  [PSCustomObject]@{ key = "4"; label = "Add settlement"; action = { Add-Settlement } },
  [PSCustomObject]@{ key = "5"; label = "Add senate party"; action = { Add-SenateParty } },
  [PSCustomObject]@{ key = "6"; label = "Add power standing"; action = { Add-Standing } },
  [PSCustomObject]@{ key = "7"; label = "Add session"; action = { Add-Session } },
  [PSCustomObject]@{ key = "8"; label = "Update ruler"; action = { Update-Ruler } },
  [PSCustomObject]@{ key = "9"; label = "Add notable character"; action = { Add-NotableCharacter } }
)

Write-Host "What would you like to update?" -ForegroundColor Cyan
$menu | ForEach-Object { Write-Host ("[{0}] {1}" -f $_.key, $_.label) }

$selection = Read-RequiredText "Choose an option"
$selectedItem = $menu | Where-Object { $_.key -eq $selection } | Select-Object -First 1

if ($null -eq $selectedItem) {
  throw "Invalid selection '$selection'."
}

& $selectedItem.action
