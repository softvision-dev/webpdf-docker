# Supported tags and respective `Dockerfile` links
*  [`7.0`, `latest` (7.0/Dockerfile)](https://github.com/softvision-dev/webpdf-docker/blob/master/7.0/Dockerfile)

# Quick reference
- **Where to get help**:   
    [the Docker Community Forums](https://forums.docker.com/), [the Docker Community Slack](https://blog.docker.com/2016/11/introducing-docker-community-directory-docker-community-slack/), or [Stack Overflow](https://stackoverflow.com/search?tab=newest&q=docker)

- **Where to file issues**:  
    [https://github.com/softvision-dev/webpdf-docker/issues](https://github.com/softvision-dev/webpdf-docker/issues)

- **Maintained by**:  
    [the webPDF Docker Maintainers](https://github.com/softvision-dev/webpdf-docker)

- **Supported Docker versions**:  
	[the latest release](https://github.com/docker/docker-ce/releases/latest)
	
# What is webPDF?
[webPDF](https://www.webpdf.de/) is the centralized multi-platform PDF server solution which provides 
[SOAP and REST Web services](https://portal.webpdf.de/webPDF/help/doc/en/webservice_general.htm) 
and a [Web portal](https://portal.webpdf.de/webPDF/). webPDF allows the creation and manipulation of PDF 
documents including operations like digital signing, OCR and PDF/A conversion.

[![logo](https://raw.githubusercontent.com/softvision-dev/webpdf-docker/master/images/logo.png)](https://www.webpdf.de/)

# How to use this image

## Starting webPDF

Starting a webPDF instance is simple:

```shell
docker run --name some-webpdf softvisiondev/webpdf:tag
```

... where ```some-webpdf``` is the name you want to assign to your container and ```tag``` is the tag specifying the webPDF version you want. See the list above for relevant tags.


## Exposing external port

```shell
docker run -p 8080:8080 softvisiondev/webpdf:latest
```

...where ```-p``` maps the containers port 8080 to the hosts port 8080.

## Accessing webPDF

Based on the used ```-p``` parameter, you can access the webPDF portal by launching a web browser and go to 
```http://localhost:8080/webPDF/```.

## Configuration volume

Start webPDF with attached configuration volume to keep your settings after updates.

```shell
docker run -v webpdf-config:/opt/webpdf/conf softvisiondev/webpdf:latest
```

...where ```-v``` creates and attaches the volume named ```webpdf-config``` to the ```/opt/webpdf/conf``` path, where webPDF stores its configurations.

# Development and support

If you have any questions on how to use webPDF or this image, or have ideas for future development, please get in touch via our [product homepage](https://www.webpdf.de/).

If you find any issues, please visit our [Github Repository](https://github.com/softvision-dev/webpdf-docker) and write an issue.

# License

Please, see the [license](https://github.com/softvision-dev/webpdf-docker/blob/master/LICENSE) file for more information.