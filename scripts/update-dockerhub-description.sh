#!/bin/bash
set -euo pipefail

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
#
# Requires: curl, jq
##############################################################################

REPO="${DOCKERHUB_REPO:-softvisiondev/webpdf}"
README_PATH="${README_PATH:-README.md}"

: "${DOCKERHUB_USERNAME:?set DOCKERHUB_USERNAME}"
: "${DOCKERHUB_TOKEN:?set DOCKERHUB_TOKEN (personal access token or password)}"

command -v curl >/dev/null 2>&1 || { echo "curl is required." >&2; exit 2; }
command -v jq   >/dev/null 2>&1 || { echo "jq is required." >&2; exit 2; }
[ -f "${README_PATH}" ] || { echo "README not found at '${README_PATH}'." >&2; exit 2; }

echo "Logging in to Docker Hub as '${DOCKERHUB_USERNAME}'..."
login_payload=$(jq -n --arg u "${DOCKERHUB_USERNAME}" --arg p "${DOCKERHUB_TOKEN}" \
  '{username: $u, password: $p}')
token=$(curl -fsSL -H "Content-Type: application/json" -d "${login_payload}" \
  "https://hub.docker.com/v2/users/login/" | jq -r '.token')
if [ -z "${token}" ] || [ "${token}" = "null" ]; then
  echo "Login failed (no token returned)." >&2
  exit 1
fi

echo "Updating full_description of '${REPO}' from '${README_PATH}'..."
body=$(jq -Rs '{full_description: .}' "${README_PATH}")
resp_file="$(mktemp)"
trap 'rm -f "${resp_file}"' EXIT
http_code=$(curl -s -o "${resp_file}" -w "%{http_code}" -X PATCH \
  -H "Authorization: JWT ${token}" \
  -H "Content-Type: application/json" \
  -d "${body}" \
  "https://hub.docker.com/v2/repositories/${REPO}/")

if [ "${http_code}" = "200" ]; then
  echo "OK: Docker Hub description updated."
else
  echo "Failed to update description (HTTP ${http_code}):" >&2
  cat "${resp_file}" >&2
  echo >&2
  exit 1
fi
