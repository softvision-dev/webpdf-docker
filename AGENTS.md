# Agent Instructions

## Project Overview
- This repo builds the official `softvisiondev/webpdf` Docker image (versions `7.0` to `11.0`).
- Published images live at `https://hub.docker.com/r/softvisiondev/webpdf`.
- Versioned folders (`7.0` … `11.0`) each contain a `Dockerfile`, Compose file(s), and — for the
  current line — Kubernetes manifests.
- Root `README.md` is the public Docker Hub description; version-specific docs live in
  `<version>/README-<version>.md`.
- `11.0` is the upcoming release and is still in development.

## How images are built (important)
- Images are **built and published by softvision's internal CI**; Docker Hub is a **registry only**
  and no longer builds anything. See [`docs/build-process.md`](docs/build-process.md).
- Do **not** re-introduce Docker Hub Automated Builds artifacts: no `hooks/` folders, no
  `LATEST_VERSION_*` gating, no Docker Hub tag/regex rules. That mechanism is deprecated
  (retires 2027-04-01) and was removed from this repo.
- The `Dockerfile` supports two package sources via `LOCAL_PACKAGE`:
  `true` = local `packages/webpdf.deb`; `false` = official package from `packages.softvision.de`
  (optionally pinned with `WEBPDF_VERSION`). Public images use `false` with a pinned release.

## Common Tasks
- Build image (a version): `cd <version>; docker build -t webpdf:local .`
- Build with local package: place `<version>/packages/webpdf.deb`, add `--build-arg LOCAL_PACKAGE=true`.
- Build like the public image: `--build-arg LOCAL_PACKAGE=false --build-arg WEBPDF_VERSION=<release>`.
- Run tests (Windows): `cd <version>; .\test-docker.ps1`
- Run tests (WSL/Linux/macOS): `cd <version>; ./test-docker.sh`
- Default service port: `8080` (web portal at `http://localhost:8080/webPDF/`).

## Version 11 notes
- `11.0/.env` uses `LOCAL_PACKAGE=true` until `11.0.0` is published to the official package repo.
- `11.0/docker-compose.yml` enables new v11 features via environment variables:
  `WEBPDF_MCP_ENABLED`, `WEBPDF_METRICS_ENABLED`, `WEBPDF_TOKEN_PAT_PERMANENT_TOKENS_ALLOWED`.

## Conventions
- Keep this repo **public-safe**: do not add internal hostnames, CI configuration IDs,
  server addresses, or credentials to any tracked file.
- The supported-tags table in `README.md` is maintained by `scripts/update-supported-tags.{sh,ps1}`.
- The Docker Hub repository description is pushed from `README.md` via
  `scripts/update-dockerhub-description.{sh,ps1}` (credentials via env vars only).
