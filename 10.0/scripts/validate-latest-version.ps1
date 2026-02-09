$ErrorActionPreference = "Stop"

$latestVersion = $env:LATEST_VERSION_10
if (-not $latestVersion) {
  $latestVersion = $env:LATEST_VERSION
}

if (-not $latestVersion) {
  Write-Error "LATEST_VERSION_10 is not set."
  exit 2
}

if ($latestVersion -match "-rc") {
  Write-Error "LATEST_VERSION_10 should be a final release tag (no -rc suffix)."
  exit 2
}

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
  Write-Error "git is required to validate tags."
  exit 2
}

$tags = git tag --list "10.0.*" | Where-Object { $_ -match "^10\.0\.\d+$" }
if (-not $tags) {
  Write-Error "No 10.0.x tags found."
  exit 2
}

if (-not ($tags -contains $latestVersion)) {
  Write-Error "LATEST_VERSION_10 '$latestVersion' does not exist as a tag."
  exit 1
}

$latestTag = $tags | Sort-Object { [version]$_ } | Select-Object -Last 1
if ($latestTag -ne $latestVersion) {
  Write-Error "LATEST_VERSION_10 '$latestVersion' is not the newest tag. Newest is '$latestTag'."
  exit 1
}

Write-Host "LATEST_VERSION_10 '$latestVersion' matches the newest 10.0.x tag."
