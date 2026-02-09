# webPDF - the PDF powerhouse

## TL;DR
```console
$ docker run --name webpdf -p 8080:8080 softvisiondev/webpdf:latest
```

### Docker Compose
```console
$ curl -sSL https://raw.githubusercontent.com/softvision-dev/webpdf-docker/master/10.0/docker-compose.yml > docker-compose.yml
$ docker-compose up -d
```

### Kubernetes
```console
$ curl -sSL https://raw.githubusercontent.com/softvision-dev/webpdf-docker/master/10.0/kubernetes.yaml > kubernetes.yaml
$ kubectl apply -f kubernetes.yaml
```

### Red Hat OpenShift
```console
$ curl -sSL https://raw.githubusercontent.com/softvision-dev/webpdf-docker/master/10.0/kubernetes-openshift.yaml > kubernetes-openshift.yaml
$ oc apply -f kubernetes-openshift.yaml
```
For more information, please read the [Kubernetes deployment](#kubernetes-deployment) section below.

## Supported tags and respective `Dockerfile` links
*  [`10.0.x`, `10.0`, `latest` (10.0/Dockerfile)](https://github.com/softvision-dev/webpdf-docker/blob/master/10.0/Dockerfile)
*  [`9.0` (9.0/Dockerfile)](https://github.com/softvision-dev/webpdf-docker/blob/master/9.0/Dockerfile)
*  [`8.0` (8.0/Dockerfile)](https://github.com/softvision-dev/webpdf-docker/blob/master/8.0/Dockerfile)
*  [`7.0` (7.0/Dockerfile)](https://github.com/softvision-dev/webpdf-docker/blob/master/7.0/Dockerfile)

`latest` and `10.0` always point to the newest `10.0.x` release. Older patch releases are available as explicit tags (e.g. `10.0.3`, `10.0.2`).

## Quick reference
- **Where to get help**:
  [the Docker Community Forums](https://forums.docker.com/), [the Docker Community Slack](https://blog.docker.com/2016/11/introducing-docker-community-directory-docker-community-slack/), or [Stack Overflow](https://stackoverflow.com/search?tab=newest&q=docker)

- **Where to file issues**:
  [https://github.com/softvision-dev/webpdf-docker/issues](https://github.com/softvision-dev/webpdf-docker/issues)

- **Maintained by**:
  [the webPDF Docker Maintainers](https://github.com/softvision-dev/webpdf-docker)

- **Supported Docker versions**:
  [the latest release](https://github.com/docker/docker-ce/releases/latest)

## What is webPDF?
[webPDF](https://www.webpdf.de/) is the centralized multi-platform PDF server solution that provides
[SOAP and REST Web services](https://portal.webpdf.de/webPDF/help/doc/en/webservice_general.htm)
and a [Web portal](https://portal.webpdf.de/webPDF/). webPDF allows the creation and manipulation of PDF
 documents, including operations like digital signing, OCR and PDF/A conversion.

[![logo](https://raw.githubusercontent.com/softvision-dev/webpdf-docker/master/images/logo.png)](https://www.webpdf.de/)

[Overview of webPDF](https://www.webpdf.de)

## Get this image
The recommended way to get the webPDF Docker Image is to pull the prebuilt image from the [Docker Hub Registry](https://hub.docker.com/r/softvisiondev/webpdf).

```console
$ docker pull softvisiondev/webpdf:latest
```

To use a specific version, you can pull a versioned tag. You can view the
[list of available versions](https://hub.docker.com/r/softvisiondev/webpdf/tags)
in the Docker Hub Registry.

```console
$ docker pull softvisiondev/webpdf:[TAG]
```

# How to use this image

## Starting webPDF
Starting a webPDF instance is simple:

```shell
docker run --name webpdf -p 8080:8080 softvisiondev/webpdf:latest
```

... where `webpdf` is the name you want to assign to your container and `latest` is the tag specifying the webPDF version you want. See the list above for relevant tags.

## Exposing external port
```shell
docker run -p 8080:8080 softvisiondev/webpdf:latest
```

...where `-p` maps the container's port 8080 to the host's port 8080.

## Accessing webPDF
Based on the used `-p` parameter, you can access the webPDF portal by launching a web browser and go to
`http://localhost:8080/webPDF/`.

## Health check
The image includes a built-in health check that monitors the server's availability. The health check uses the `/webPDF/health` endpoint and runs automatically:

- **Interval**: Every 30 seconds
- **Timeout**: 10 seconds per check
- **Start period**: 90 seconds (grace period after container start)
- **Retries**: 3 failed checks before marking as unhealthy

### Check container health status
```shell
docker ps
```
The `STATUS` column shows the health status (e.g., `Up 2 minutes (healthy)`).

### Detailed health information
```shell
docker inspect --format='{{json .State.Health}}' webpdf
```

### Manual health check
```shell
curl http://localhost:8080/webPDF/health
```

The health check is automatically used by orchestration platforms like Docker Swarm, Kubernetes, and Portainer for service management and load balancing.

## Configure volumes
Start webPDF with an attached configuration volume to keep your settings after updates.

```shell
docker run -p 8080:8080 -v webpdf-config:/opt/webpdf/conf softvisiondev/webpdf:latest
```

...where `-v` creates and attaches the volume named `webpdf-config` to the `/opt/webpdf/conf` path, where webPDF stores its configurations.

You can also keep the logs and the keystore files if you mount volumes for the folders `/opt/webpdf/logs` and `/opt/webpdf/keystore`.

```shell
docker run -p 8080:8080 \
  -v webpdf-config:/opt/webpdf/conf \
  -v webpdf-logs:/opt/webpdf/logs \
  -v webpdf-keystore:/opt/webpdf/keystore \
  softvisiondev/webpdf:latest
```

## Fonts
The webPDF container includes an extensive collection of fonts from various sources:

- **MS Core Fonts**: Arial, Times New Roman, Courier New, etc.
- **MS Vista Fonts**: Calibri, Cambria, Candara, Consolas, etc.
- **Wine Fonts**: Tahoma, Wingdings
- **Liberation Fonts**: Liberation Sans, Serif, Mono
- **Noto Fonts**: Noto Sans, Noto Serif, Noto Color Emoji
- **Additional Fonts**: DejaVu, OpenSymbol, Fira Code

### Add custom fonts
To add additional fonts, especially customized fonts, mount a volume for `/home/webpdf/.fonts`. The webPDF server uses fonts from the user's home folder `webpdf`.

```shell
docker run -p 8080:8080 -v webpdf-fonts:/home/webpdf/.fonts softvisiondev/webpdf:latest
```

The font folders used are displayed when the server is started and can be viewed via the console or the log files.

### List installed fonts
```shell
docker exec webpdf fc-list
```

## Environment variables
When you start the `webpdf` image, you can adjust the configuration of the webPDF instance by passing one or more environment variables on the docker run command line.

### `JAVA_PARAMETERS`
Allows passing Java VM options to the webPDF server startup.

**Example**: Set memory limits
```console
$ docker run --name webpdf -e JAVA_PARAMETERS="-Xmx2048m -Xms1024m" softvisiondev/webpdf:latest
```

### `LANG`, `LANGUAGE`, `LC_ALL`
Linux environment variables for the language and encoding used in the image and for the webPDF server.

**Default**: `de_DE.UTF-8`

**Example**: Use English locale
```console
$ docker run --name webpdf -e LANG=en_US.UTF-8 -e LANGUAGE=en_US.UTF-8 -e LC_ALL=en_US.UTF-8 softvisiondev/webpdf:latest
```

### `TZ`
Linux environment variable for the timezone used in the image and for the webPDF server.

**Default**: `Europe/Berlin`

**Example**: Use New York timezone
```console
$ docker run --name webpdf -e TZ=America/New_York softvisiondev/webpdf:latest
```

## Shared memory
The webPDF server requires shared memory allocated to the container. You can configure the shared memory of the container with the `--shm-size` parameter or use [shm_size](https://docs.docker.com/reference/compose-file/build/#shm_size) in the `docker-compose.yml` file.

```console
$ docker run --name webpdf -p 8080:8080 --shm-size=2gb softvisiondev/webpdf:latest
```
A shared memory of at least 2 GB is recommended.

## Non-root container
The webPDF container runs under the non-privileged (non-root) user `webpdf` with UID `10000` and GID `10000`. Non-root container images add an extra layer of security and are generally recommended for production environments.

### Customize User and Group IDs
If you need to match the container's user with your host system's user for volume permissions, you can customize the UID and GID during the build process:

```shell
docker build --build-arg USER_UID=1000 --build-arg USER_GID=1000 -t webpdf:custom .
```

This is particularly useful when mounting host directories that require specific ownership:

```shell
# Build with custom UID/GID
docker build --build-arg USER_UID=$(id -u) --build-arg USER_GID=$(id -g) -t webpdf:custom .

# Run with host directory mount
docker run -p 8080:8080 -v ./config:/opt/webpdf/conf webpdf:custom
```

**Note**: The `USER_UID` and `USER_GID` build arguments can only be set during image build time, not at runtime.

## Complete example
Here's a complete example combining common options:

```shell
docker run -d \
  --name webpdf \
  -p 8080:8080 \
  --shm-size=2gb \
  -e JAVA_PARAMETERS="-Xmx2048m -Xms1024m" \
  -e TZ=Europe/Berlin \
  -v webpdf-config:/opt/webpdf/conf \
  -v webpdf-logs:/opt/webpdf/logs \
  -v webpdf-keystore:/opt/webpdf/keystore \
  -v webpdf-fonts:/home/webpdf/.fonts \
  softvisiondev/webpdf:latest
```

## Logging
The webPDF image sends the container logs to the `stdout`. To view the logs:

```console
$ docker logs webpdf
```

or using Docker Compose:

```console
$ docker-compose logs webpdf
```

You can configure the container's [logging driver](https://docs.docker.com/engine/admin/logging/overview/) using the `--log-driver` option if you wish to consume the container logs differently. In the default configuration docker uses the `json-file` driver.

## Kubernetes deployment
The repository includes comprehensive Kubernetes manifests for deploying webPDF:

- **`kubernetes.yaml`**: Standard Kubernetes deployment (Docker Desktop, Minikube, EKS, GKE, AKS)
- **`kubernetes-openshift.yaml`**: Red Hat OpenShift-compatible deployment with Security Context Constraints (SCCs)

### Configuration initialization
Both manifests use **application-level configuration initialization** - no init containers required! 
The webPDF startup script automatically initializes missing configuration files from built-in defaults. 
This approach:

- Works without root privileges (OpenShift compatible)
- Supports individual file mounts (e.g., custom `application.xml`)
- Idempotent and self-healing
- Follows industry best practices as applied in other containers

### Standard Kubernetes
Quick start:
```console
$ kubectl apply -f kubernetes.yaml
```

The container typically starts in 20-30 seconds. Access via:
- NodePort (default): `http://<node-ip>:30080/webPDF/`
- Or configure LoadBalancer/Ingress for production

**Custom font options:**
- HostPath: Mount local directory (default, adjust the path in manifest)
- EmptyDir: No custom fonts needed (container includes extensive font collection)
- PVC: For shared fonts across nodes (production)

### Red Hat OpenShift
The OpenShift manifest addresses platform-specific requirements:
- Compatible with `restricted` SCC (no root containers)
- Uses OpenShift Routes for external access with TLS
- emptyDir volumes instead of hostPath (hostPath forbidden)
- Dynamic UID/GID assignment from the project range

Quick start:
```console
$ oc apply -f kubernetes-openshift.yaml
$ oc get route webpdf  # Get the external URL
```

**Custom font options:**
- EmptyDir: No custom fonts (default, container includes extensive font collection)
- PVC: For persistent custom fonts

**Key differences:**
| Feature | Standard K8s | OpenShift |
|---------|--------------|-----------|
| Init method | Application-level | Application-level |
| External access | NodePort/LoadBalancer/Ingress | Route (with TLS) |
| Font storage | HostPath/EmptyDir/PVC | EmptyDir/PVC |
| Security | Flexible | Restricted SCC enforced |
| UID/GID | Fixed (10000:10000) | Dynamic (project range) |

For detailed OpenShift deployment instructions, see inline comments in [`kubernetes-openshift.yaml`](./kubernetes-openshift.yaml).

## Build arguments
If you build the webPDF container with the `Dockerfile`, you can customize the build process with the following [arguments](https://docs.docker.com/build/building/variables/#build-arguments).

### `BASE_IMAGE`
Overrides the Debian base image used for all build stages.

**Default**: `docker.io/library/debian:trixie-slim`

**Example**:
```shell
docker build --build-arg BASE_IMAGE=docker.io/library/debian:trixie-slim -t webpdf:base-pin .
```

### `LOCAL_PACKAGE`
If this option is set to `true`, the Linux package is not fetched from the official [package repository](https://packages.softvision.de/), but the local file `./packages/webpdf.deb` is used for the build process.

**Example**:
```shell
docker build --build-arg LOCAL_PACKAGE=true -t webpdf:local .
```

### `WEBPDF_VERSION`
Pins the webPDF Debian package version from the official repository. Leave empty to install the latest package from the repo.

**Default**: empty (latest from repo)

**Example**:
```shell
docker build --build-arg WEBPDF_VERSION=10.0.1-1 -t webpdf:10.0.1 .
```

### `USER_UID` and `USER_GID`
Set custom user and group IDs for the webpdf user (default: 10000).

**Example**:
```shell
docker build --build-arg USER_UID=1000 --build-arg USER_GID=1000 -t webpdf:custom .
```

## Testing
The repository includes test scripts to verify the Docker image functionality:

### Bash (Linux, macOS, WSL2, Git Bash)
```shell
cd 10.0
chmod +x test-docker.sh
./test-docker.sh
```

### PowerShell (Windows, Cross-Platform)
```powershell
cd 10.0
.\test-docker.ps1
```

The test scripts verify:
- Image build success
- Container startup
- Health check functionality
- Font installation
- webPDF endpoint availability
- User permissions

### Configure test scripts
Both test scripts use the `LOCAL_PACKAGE=true` build argument by default, which requires a local `webpdf.deb` file in the `./packages/` directory.

To test with the package from the official repository instead, edit the configuration at the top of the script:

**test-docker.sh:**
```bash
LOCAL_PACKAGE="false"  # Use official repository
```

**test-docker.ps1:**
```powershell
$LOCAL_PACKAGE = "false"  # Use official repository
```

# Technical details

## Base image
- **Debian Trixie Slim** (latest stable)
- Multi-stage build for optimized image size

## Architecture
The Dockerfile uses a 4-stage build process:
1. **Stage 1**: System fonts installation (MS Core Fonts, Noto, Liberation, etc.)
2. **Stage 2**: Custom fonts compilation (Vista Fonts, Wine Fonts)
3. **Stage 3**: Font consolidation
4. **Stage 4**: Final webPDF installation

This approach minimizes the final image size by excluding build tools and intermediate files.

## Security features
- Non-root user execution
- Chromium sandbox disabled (required for containerized PDF rendering)
- Modern GPG key management (`/etc/apt/keyrings/`)
- Minimal attack surface (slim base image)

# Development and support
If you have any questions on how to use webPDF or this image, or have ideas for future development, please get in touch via our [product homepage](https://www.webpdf.de/).

If you find any issues, please visit our [GitHub Repository](https://github.com/softvision-dev/webpdf-docker) and write an issue.

# License
Please, see the [license](https://github.com/softvision-dev/webpdf-docker/blob/master/LICENSE) file for more information.
