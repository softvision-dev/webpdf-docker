$ErrorActionPreference = "Stop"

param(
  [string]$ReadmePath = "README.md"
)

if (-not (Test-Path $ReadmePath)) {
  Write-Error "README not found at '$ReadmePath'."
  exit 2
}

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
  Write-Error "git is required to read tag information."
  exit 2
}

$tagPattern = '^\d+\.\d+\.\d+$'
$rawTags = git tag --list | Where-Object { $_ -match $tagPattern }
if (-not $rawTags) {
  Write-Error "No version tags found."
  exit 1
}

function Parse-Tag {
  param([string]$Tag)
  if ($Tag -notmatch '^(?<major>\d+)\.(?<minor>\d+)\.(?<patch>\d+)(-rc(?<rc>\d+))?$') {
    return $null
  }
  $rcValue = if ($Matches.rc) { [int]$Matches.rc } else { 9999 }
  return [pscustomobject]@{
    Major = [int]$Matches.major
    Minor = [int]$Matches.minor
    Patch = [int]$Matches.patch
    RcSort = $rcValue
    Tag = $Tag
  }
}

$grouped = @{}
foreach ($tag in $rawTags) {
  $info = Parse-Tag -Tag $tag
  if (-not $info) { continue }
  $key = "$($info.Major).$($info.Minor)"
  if (-not $grouped.ContainsKey($key)) {
    $grouped[$key] = @()
  }
  $grouped[$key] += $info
}

$groupKeys = $grouped.Keys | Sort-Object { [version]"$_.0" } -Descending
# The highest line (first in descending order) owns the moving `latest` tag.
$latestKey = $groupKeys | Select-Object -First 1
$lines = @()
foreach ($key in $groupKeys) {
  $tags = $grouped[$key] | Sort-Object Major, Minor, Patch, RcSort | ForEach-Object { $_.Tag }
  $tagsString = ($tags | ForEach-Object { "``$_``" }) -join ", "
  # Every line advertises its immutable `X.Y.x` and moving `X.Y` tags;
  # the highest line additionally advertises `latest`.
  $label = "``$key.x``, ``$key``"
  if ($key -eq $latestKey) { $label += ", ``latest``" }
  $dockerfileUrl = "https://github.com/softvision-dev/webpdf-docker/blob/master/$key/Dockerfile"
  $lines += "*  [$label ($key/Dockerfile)]($dockerfileUrl) - Tags: $tagsString"
}

$content = Get-Content -Raw -Path $ReadmePath
$pattern = '(?s)<!-- TAGS:START -->(.*?)<!-- TAGS:END -->'
if ($content -notmatch $pattern) {
  Write-Error "Tag markers not found in README. Expected <!-- TAGS:START --> and <!-- TAGS:END -->."
  exit 1
}

$replacement = "<!-- TAGS:START -->`n$($lines -join "`n")`n<!-- TAGS:END -->"
$updated = [regex]::Replace($content, $pattern, $replacement)
Set-Content -Path $ReadmePath -Value $updated -NoNewline
