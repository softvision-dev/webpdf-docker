#!/bin/bash
set -euo pipefail

README_PATH="${1:-README.md}"

if [ ! -f "${README_PATH}" ]; then
  echo "README not found at '${README_PATH}'." >&2
  exit 2
fi

if ! command -v git >/dev/null 2>&1; then
  echo "git is required to read tag information." >&2
  exit 2
fi

tags=$(git tag --list | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' || true)
if [ -z "${tags}" ]; then
  echo "No version tags found." >&2
  exit 1
fi

declare -A grouped
for tag in ${tags}; do
  base="${tag%%-rc*}"
  major_minor="${base%.*}"
  grouped["${major_minor}"]+="${tag} "
done

sorted_keys=$(printf "%s\n" "${!grouped[@]}" | sort -V -r)
# The highest line (first in descending order) owns the moving `latest` tag.
latest_key=$(printf "%s\n" "${sorted_keys}" | head -n 1)
lines=()
while read -r key; do
  [ -z "${key}" ] && continue
  IFS=' ' read -r -a tag_list <<< "${grouped[$key]}"
  sorted_tags=$(printf "%s\n" "${tag_list[@]}" | sort -V)
  tags_inline=$(printf '`%s`, ' ${sorted_tags} | sed 's/, $//')
  # Every line advertises its immutable `X.Y.x` and moving `X.Y` tags;
  # the highest line additionally advertises `latest`.
  if [ "${key}" = "${latest_key}" ]; then
    label="\`${key}.x\`, \`${key}\`, \`latest\`"
  else
    label="\`${key}.x\`, \`${key}\`"
  fi
  dockerfile_url="https://github.com/softvision-dev/webpdf-docker/blob/master/${key}/Dockerfile"
  lines+=("*  [${label} (${key}/Dockerfile)](${dockerfile_url}) - Tags: ${tags_inline}")
done <<< "${sorted_keys}"

start_marker="<!-- TAGS:START -->"
end_marker="<!-- TAGS:END -->"

if ! grep -q "${start_marker}" "${README_PATH}" || ! grep -q "${end_marker}" "${README_PATH}"; then
  echo "Tag markers not found in README. Expected <!-- TAGS:START --> and <!-- TAGS:END -->." >&2
  exit 1
fi

tmp_file="$(mktemp)"
awk -v start="${start_marker}" -v end="${end_marker}" -v repl="$(printf "%s\n" "${lines[@]}")" '
  BEGIN { inblock=0 }
  $0 ~ start { print; print repl; inblock=1; next }
  $0 ~ end { inblock=0; print; next }
  inblock==0 { print }
' "${README_PATH}" > "${tmp_file}"

mv "${tmp_file}" "${README_PATH}"
