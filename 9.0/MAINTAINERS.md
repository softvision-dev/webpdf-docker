# Maintainer Builds (Docker Hub) - 9.0

This document describes how automated builds and tagging work for `9.0/`.

## Quick Reference
- Release: tag `9.0.x` → build `9.0.x`, then `9.0` if `LATEST_VERSION_9` matches.
- RC: tag `9.0.x-rcN` → build RC image, no changes to `9.0`.
- Debian rebuild: re-push old tag to rebuild only that patch.

## Build Rules
Use tag-based rules (no branch rules needed):

- Source: Tag, regex `^9\.0\.\d+$` → Docker tag `{sourceref}`
- Source: Tag, regex `^9\.0\.\d+-rc\d+$` → Docker tag `{sourceref}`

## Hooks
The Docker Hub build context is `9.0/`, and the repo includes Docker Hub hooks:

- `9.0/hooks/build`: sets `WEBPDF_VERSION` to the Git tag (`SOURCE_BRANCH`) when not provided, stripping any `-rcN` suffix.
- `9.0/hooks/post_push`: pushes `9.0` when the build tag equals `LATEST_VERSION_9`. Optionally pushes an extra alias if `LATEST_ALIAS_9` is set.

## Required Docker Hub Environment Variables
Set these in the Docker Hub build configuration:

- `LATEST_VERSION_9`: current patch release (e.g. `9.0.7`).
- `BASE_IMAGE_9`: Debian base image tag for all `9.x` builds (optional; default is `debian:bullseye`).
- `LATEST_ALIAS_9`: optional additional tag alias (e.g. `latest-9`). Leave empty to disable.

`LATEST_VERSION_9` must be a final release tag (no `-rc` suffix).

Avoid setting `LATEST_ALIAS_9=latest` unless you intend to override the global `latest` tag.

## Rebuild Checklist (Debian base updates for older tags, e.g. 9.0.3)
- Keep `LATEST_VERSION_9` unchanged (still the newest patch).
- Force-repush the existing tag to trigger a rebuild:
  - `git tag -f 9.0.3 <commit>`
  - `git push -f origin 9.0.3`
- Confirm that only `softvisiondev/webpdf:9.0.3` (and `:9.0` if applicable) is updated.

## RC Testing Flow (e.g. 9.0.5-rc1)
- Create RC tag: `git tag 9.0.5-rc1` then `git push origin 9.0.5-rc1`.
- Docker Hub builds `9.0.5-rc1` using `WEBPDF_VERSION=9.0.5` (suffix stripped by hook).
- Test the RC image without touching `:9.0`.
- When ready, create the final tag `9.0.5`, update `LATEST_VERSION_9`, and release.
