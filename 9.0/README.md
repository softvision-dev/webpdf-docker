# webPDF - the PDF powerhouse

## TL;DR
```console
$ docker run --name webpdf softvisiondev/webpdf:latest
```

### Docker Compose
```console
$ curl -sSL https://raw.githubusercontent.com/softvision-dev/webpdf-docker/master/8.0/docker-compose.yml > docker-compose.yml
$ docker-compose up -d
```

## Supported tags and respective `Dockerfile` links
*  [`7.0` (7.0/Dockerfile)](https://github.com/softvision-dev/webpdf-docker/blob/master/7.0/Dockerfile)
*  [`8.0` (8.0/Dockerfile)](https://github.com/softvision-dev/webpdf-docker/blob/master/8.0/Dockerfile)
*  [`9.0`, `latest` (9.0/Dockerfile)](https://github.com/softvision-dev/webpdf-docker/blob/master/9.0/Dockerfile)

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
[webPDF](https://www.webpdf.de/) is the centralized multi-platform PDF server solution which provides
[SOAP and REST Web services](https://portal.webpdf.de/webPDF/help/doc/en/webservice_general.htm)
and a [Web portal](https://portal.webpdf.de/webPDF/). webPDF allows the creation and manipulation of PDF
documents including operations like digital signing, OCR and PDF/A conversion.

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
docker run --name webpdf softvisiondev/webpdf:[tag]
```

... where ```webpdf``` is the name you want to assign to your container and ```[tag]``` is the tag specifying the webPDF version you want. See the list above for relevant tags.

## Exposing external port
```shell
docker run -p 8080:8080 softvisiondev/webpdf:latest
```

...where ```-p``` maps the containers port 8080 to the hosts port 8080.

## Accessing webPDF
Based on the used ```-p``` parameter, you can access the webPDF portal by launching a web browser and go to
```http://localhost:8080/webPDF/```.

## Configure volume
Start webPDF with attached configuration volume to keep your settings after updates.

```shell
docker run -v webpdf-config:/opt/webpdf/conf softvisiondev/webpdf:latest
```

...where ```-v``` creates and attaches the volume named ```webpdf-config``` to the ```/opt/webpdf/conf``` path, where webPDF stores its configurations.

## Environment Variables
When you start the `webpdf` image, you can adjust the configuration of the webPDF instance by passing one or more environment variables on the docker run command line.

`JAVA_PARAMETERS`

Allows passing Java VM options to the webPDF server startup (e.g. set memory limits: `-Xmx2048m -Xms1024m`)

`LANG`, `LANGUAGE`, `LC_ALL`

Linux environment variables for the language and encoding used in the image and for the webPDF server (e.g. `de_DE.UTF-8`)

`TZ`

Linux environment variable for the used time tone in the image and for the webPDF server (e.g. `Europe/Berlin`)

You can pass the value of variables with the `-e` option in the command line:

```console
$ docker run --name webpdf -e TZ=Europe/Berlin softvisiondev/webpdf:latest
```

## Non-root container
The webPDF container runs under the non-privileged (non-root) user `webpdf`. Non-root container images add an extra layer of security and are generally recommended for production environments. However, because they run as a non-root user, privileged tasks such as installing system packages, editing configuration files, creating system users and groups, and modifying network information, are typically off-limits.

## Logging
The webPDF image sends the container logs to the `stdout`. To view the logs:

```console
$ docker logs webpdf
```

or using Docker Compose:

```console
$ docker-compose logs webpdf
```

You can configure the containers [logging driver](https://docs.docker.com/engine/admin/logging/overview/) using the `--log-driver` option if you wish to consume the container logs differently. In the default configuration docker uses the `json-file` driver.

# Development and support
If you have any questions on how to use webPDF or this image, or have ideas for future development, please get in touch via our [product homepage](https://www.webpdf.de/).

If you find any issues, please visit our [Github Repository](https://github.com/softvision-dev/webpdf-docker) and write an issue.

# License
Please, see the [license](https://github.com/softvision-dev/webpdf-docker/blob/master/LICENSE) file for more information.	