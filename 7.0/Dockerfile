FROM debian:jessie
LABEL maintainer="webPDF Docker Maintainers <info@softvision.de>"

ENV VERSION="7.0.0.1947"
ENV WEBPDF_INSTALLER="https://download.softvision.de/?product=webpdf&version=$VERSION&platform=linux&arch=x86_64&ext=deb"

# installing packages...
RUN apt-get update && \
    apt-get --yes install \
    rcconf \
    libstdc++5 \
    libssl-dev \
    sudo \
    libfreetype6 \
    openjdk-7-jre

# installing webpdf...
ADD $WEBPDF_INSTALLER /app/webpdf.deb
RUN chmod +x /app/webpdf.deb && \
    dpkg -i /app/webpdf.deb

# install missing fonts
RUN echo "deb http://ftp.us.debian.org/debian jessie main contrib" >> /etc/apt/sources.list && \
    cat /etc/apt/sources.list && \
    apt-get update && \
    apt-get --yes install \
    ttf-mscorefonts-installer \
    ttf-liberation \
    ttf-linux-libertine \
    ttf-freefont \
    ttf-dejavu-extra \
    ttf-dejavu-core \
    ttf-opensymbol \
    ttf-aenigma

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
