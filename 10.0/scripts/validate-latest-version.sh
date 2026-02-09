#!/bin/bash
set -euo pipefail

LATEST_VERSION_ARG="${LATEST_VERSION_10:-${LATEST_VERSION:-}}"

if [ -z "${LATEST_VERSION_ARG}" ]; then
  echo "LATEST_VERSION_10 is not set."
  exit 2
fi

if [[ "${LATEST_VERSION_ARG}" == *-rc* ]]; then
  echo "LATEST_VERSION_10 should be a final release tag (no -rc suffix)."
  exit 2
fi

if ! command -v git >/dev/null 2>&1; then
  echo "git is required to validate tags."
  exit 2
fi

TAGS=$(git tag --list '10.0.*' | grep -E '^10\.0\.[0-9]+$' || true)
if [ -z "${TAGS}" ]; then
  echo "No 10.0.x tags found."
  exit 2
fi

if ! echo "${TAGS}" | grep -Fxq "${LATEST_VERSION_ARG}"; then
  echo "LATEST_VERSION_10 '${LATEST_VERSION_ARG}' does not exist as a tag."
  exit 1
fi

LATEST_TAG=$(echo "${TAGS}" | sort -V | tail -n 1)
if [ "${LATEST_TAG}" != "${LATEST_VERSION_ARG}" ]; then
  echo "LATEST_VERSION_10 '${LATEST_VERSION_ARG}' is not the newest tag. Newest is '${LATEST_TAG}'."
  exit 1
fi

echo "LATEST_VERSION_10 '${LATEST_VERSION_ARG}' matches the newest 10.0.x tag."
