# Build & Release Process

This document explains how the public `softvisiondev/webpdf` images are produced.
It replaces the former Docker Hub *Automated Builds* setup (deprecated by Docker;
full retirement announced for April 1, 2027).

## Where images are built

Images are **built and published by softvision's own CI**, not by Docker Hub.
Docker Hub is used purely as a registry to distribute the finished images.
As a consequence, this repository no longer contains Docker Hub build `hooks`
or Automated-Build tag/regex rules.

## Package source: local vs. official

The [`Dockerfile`](../10.0/Dockerfile) installs the webPDF Debian package in one of
two ways, controlled by the `LOCAL_PACKAGE` build argument:

- `LOCAL_PACKAGE=true` — installs the local `packages/webpdf.deb`. Used for internal
  test images built directly from a fresh package artifact.
- `LOCAL_PACKAGE=false` (default) — installs the **official released package** from
  the public package repository at `https://packages.softvision.de/`, optionally pinned
  to a specific version via `WEBPDF_VERSION` (e.g. `10.0.5`).

The **public images on Docker Hub are built with `LOCAL_PACKAGE=false`** against a
pinned, officially released webPDF version. Because that released package is immutable,
the build is reproducible and can be re-run at any time.

## Base-image refresh

To pick up Debian base-image and OS security updates, the public build is re-run
periodically (on a schedule) with `--pull`, rebuilding the same pinned webPDF version
on top of a current base image. This replaces the old "trigger a rebuild" URL mechanism.

## Tagging

- `X.Y.Z` — immutable patch tag for a specific released version.
- `X.Y` — moves to the newest `X.Y.Z` of that line.
- `latest` — moves to the newest release of the current latest line.

Release-candidate builds (`X.Y.Z-rcN`) are for testing only and never move
`X.Y` or `latest`.

## Docker Hub repository description

Docker Hub used to sync the repository description automatically while it built
the images. Since it no longer builds anything, the description
(`README.md`) must be pushed explicitly. Run one of the helper scripts after
changing `README.md`, or wire it into CI:

```shell
# Bash (requires curl + jq)
DOCKERHUB_USERNAME=<user> DOCKERHUB_TOKEN=<access-token> \
  scripts/update-dockerhub-description.sh

# PowerShell
$env:DOCKERHUB_USERNAME="<user>"; $env:DOCKERHUB_TOKEN="<access-token>"
scripts/update-dockerhub-description.ps1
```

Use a Docker Hub **personal access token** (not the account password), and
provide credentials via environment variables only — never commit them.

## Building locally

```shell
# From an official released package (as the public images are built)
cd 10.0
docker build --pull \
  --build-arg LOCAL_PACKAGE=false \
  --build-arg WEBPDF_VERSION=10.0.5 \
  -t webpdf:pub-test .

# From a local package file (place webpdf.deb into ./packages/ first)
cd 10.0
docker build --build-arg LOCAL_PACKAGE=true -t webpdf:local .
```

See the root [`README.md`](../README.md) for the full list of build arguments
(`BASE_IMAGE`, `WEBPDF_VERSION`, `LOCAL_PACKAGE`, `USER_UID`/`USER_GID`) and for the
test scripts under each version folder.
