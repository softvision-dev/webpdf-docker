FROM debian:buster
LABEL maintainer="webPDF Docker Maintainers <info@softvision.de>"

ENV VERSION="7.0.0.2134"
ENV WEBPDF_INSTALLER="https://download.softvision.de/?product=webpdf&version=$VERSION&platform=linux&arch=x86_64&ext=deb"

# installing packages...
RUN apt-get update && \
    apt-get --yes install \
    rcconf \
    libstdc++5 \
    libssl-dev \
    sudo \
    libfreetype6 \
    locales \
    software-properties-common

# Get OpenJDK 8 from Debian Stretch
RUN apt-add-repository 'deb http://security.debian.org/debian-security stretch/updates main'
RUN apt-get update && apt-get --yes install openjdk-8-jre

# Set the locale
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

# installing webpdf...
ADD $WEBPDF_INSTALLER /app/webpdf.deb
RUN chmod +x /app/webpdf.deb && \
    dpkg -i /app/webpdf.deb

 # install missing fonts
 RUN echo "deb http://ftp.us.debian.org/debian stable main contrib" >> /etc/apt/sources.list && \
     cat /etc/apt/sources.list && \
     apt-get update && \
     apt-get --yes install \
     ttf-mscorefonts-installer \
     ttf-ancient-fonts \
     ttf-ancient-fonts-symbola \
     ttf-unifont \
     ttf-dejavu-extra \
     ttf-dejavu-core \
     ttf-opensymbol \
     ttf-aenigma \
     fonts-liberation \
     fonts-linuxlibertine \
     fonts-freefont-ttf

# copy the fonts
RUN mkdir /root/fonts && \
    cp /usr/share/fonts/truetype/*/*.ttf /root/fonts -n && \
    rm /usr/share/fonts/truetype/* -R && \
    mv /root/fonts/* /usr/share/fonts/truetype/ && \
    rm /root/fonts/ -R && \
    dpkg-reconfigure -f noninteractive -plow fontconfig && \
    fc-cache -fv

# cleanup
RUN /etc/init.d/x11-common stop && \
    rcconf --off x11-common && \
    apt-get -y autoremove && \
    apt-get -y clean && \
    apt-get -y purge && \
    find /var/log/ -maxdepth 1 -type f -delete && \
    rm /etc/init.d/x11-common && \
    rm -rf /root/* && \
    rm -rf /opt/webpdf/temp/* && \
    rm -rf /opt/webpdf/work/*

EXPOSE 8080

CMD service webpdf start && bash
