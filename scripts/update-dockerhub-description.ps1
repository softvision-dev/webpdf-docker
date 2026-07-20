#!/usr/bin/env pwsh
##############################################################################
# Update the Docker Hub repository description from README.md.
#
# Docker Hub no longer builds this image (Automated Builds are deprecated), so
# the repository description is no longer synced automatically. Run this after
# changing README.md, or wire it into CI.
#
# Required environment variables:
#   DOCKERHUB_USERNAME  Docker Hub user with write access to the repository
#   DOCKERHUB_TOKEN     Docker Hub personal access token (preferred) or password
# Optional environment variables:
#   DOCKERHUB_REPO      target repository, default: softvisiondev/webpdf
#   README_PATH         path to the README, default: README.md
##############################################################################

param(
  [string]$Repo       = $(if ($env:DOCKERHUB_REPO) { $env:DOCKERHUB_REPO } else { "softvisiondev/webpdf" }),
  [string]$ReadmePath = $(if ($env:README_PATH)    { $env:README_PATH }    else { "README.md" })
)

$ErrorActionPreference = "Stop"

if (-not $env:DOCKERHUB_USERNAME) { Write-Error "set DOCKERHUB_USERNAME"; exit 2 }
if (-not $env:DOCKERHUB_TOKEN)    { Write-Error "set DOCKERHUB_TOKEN (personal access token or password)"; exit 2 }
if (-not (Test-Path $ReadmePath)) { Write-Error "README not found at '$ReadmePath'."; exit 2 }

Write-Host "Logging in to Docker Hub as '$($env:DOCKERHUB_USERNAME)'..."
$loginBody = @{ username = $env:DOCKERHUB_USERNAME; password = $env:DOCKERHUB_TOKEN } | ConvertTo-Json
$login = Invoke-RestMethod -Method Post -Uri "https://hub.docker.com/v2/users/login/" `
  -ContentType "application/json" -Body $loginBody
$token = $login.token
if (-not $token) { Write-Error "Login failed (no token returned)."; exit 1 }

Write-Host "Updating full_description of '$Repo' from '$ReadmePath'..."
$readme = Get-Content -Raw -Path $ReadmePath
$body = @{ full_description = $readme } | ConvertTo-Json
Invoke-RestMethod -Method Patch -Uri "https://hub.docker.com/v2/repositories/$Repo/" `
  -Headers @{ Authorization = "JWT $token" } `
  -ContentType "application/json" -Body $body | Out-Null

Write-Host "OK: Docker Hub description updated."
