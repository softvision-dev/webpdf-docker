# Maintainer Builds (Docker Hub)

This document describes how automated builds and tagging work for `10.0/` using Docker Hub Automated Builds.

## Quick Reference
- Release: tag `10.0.x` → build `10.0.x`, then `10.0`/`latest` if `LATEST_VERSION_10` matches.
- RC: tag `10.0.x-rcN` → build RC image, no changes to `10.0`/`latest`.
- Debian rebuild: re-push old tag to rebuild only that patch.

## Build Rules
Use tag-based rules (no branch rules needed):

- Source: Tag, regex `^10\.0\.\d+$` → Docker tag `{sourceref}`
- Source: Tag, regex `^10\.0\.\d+-rc\d+$` → Docker tag `{sourceref}`

This builds the specific patch tag (e.g. `10.0.4`). Other tags are handled by hooks.

## Hooks
The Docker Hub build context is `10.0/`, and the repo includes Docker Hub hooks:

- `10.0/hooks/build`: sets `WEBPDF_VERSION` to the Git tag (`SOURCE_BRANCH`) when not provided, stripping any `-rcN` suffix.
- `10.0/hooks/post_push`: pushes `10.0` and `latest` only when the build tag equals `LATEST_VERSION_10`.

## Required Docker Hub Environment Variables
Set these in the Docker Hub build configuration:

- `LATEST_VERSION_10`: current patch release (e.g. `10.0.4`).
- `BASE_IMAGE_10`: Debian base image tag for all `10.x` builds (optional; default is `debian:trixie-slim`).

`LATEST_VERSION_10` must be a final release tag (no `-rc` suffix).

## Rebuilding for Debian Updates
Docker Hub does not rebuild automatically on Debian base updates. To refresh a patch image without changing webPDF:

- Re-push the same Git tag (force) to trigger a rebuild:
  - `git tag -f 10.0.3 <commit>`
  - `git push -f origin 10.0.3`

This rebuilds `10.0.3` only. `latest` and `10.0` are updated only if `LATEST_VERSION_10` matches.

## Local Validation
Check that `LATEST_VERSION_10` matches the newest Git tag before publishing:

```bash
LATEST_VERSION_10=10.0.4 ./scripts/validate-latest-version.sh
```

```powershell
$env:LATEST_VERSION_10="10.0.4"
.\scripts\validate-latest-version.ps1
```

## Release Checklist (e.g. 10.0.4 -> 10.0.5)
- Update any changes needed for the new patch (Dockerfile/build args, hooks, docs).
- Build/test locally with `WEBPDF_VERSION=10.0.5` and confirm expected behavior.
- Create and push the Git tag: `git tag 10.0.5` then `git push origin 10.0.5`.
- Update Docker Hub build env var `LATEST_VERSION_10=10.0.5`.
- Trigger the Docker Hub build for tag `10.0.5` if it does not start automatically.
- Validate that `softvisiondev/webpdf:10.0.5`, `:10.0`, and `:latest` point to the new image.

## Rebuild Checklist (Debian base updates for older tags, e.g. 10.0.3)
- Keep `LATEST_VERSION_10` unchanged (still the newest patch).
- Force-repush the existing tag to trigger a rebuild:
  - `git tag -f 10.0.3 <commit>`
  - `git push -f origin 10.0.3`
- Confirm that only `softvisiondev/webpdf:10.0.3` is updated (no changes to `:10.0` or `:latest`).

## RC Testing Flow (e.g. 10.0.5-rc1)
- Create RC tag: `git tag 10.0.5-rc1` then `git push origin 10.0.5-rc1`.
- Docker Hub builds `10.0.5-rc1` using `WEBPDF_VERSION=10.0.5` (suffix stripped by hook).
- Test the RC image without touching `:10.0` or `:latest`.
- When ready, create the final tag `10.0.5`, update `LATEST_VERSION_10`, and follow the release checklist.
