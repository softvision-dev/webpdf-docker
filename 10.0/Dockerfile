FROM debian:bookworm

LABEL maintainer="webPDF Docker Maintainers <info@softvision.de>"

# update packages
RUN apt-get --yes update

# get some default packages
RUN apt-get --yes install \
    wget \
    gpg \
    apt-utils \
    lsb-release \
    locales \
    locales-all \
    cabextract \
    fontforge

# set to true for using the local package 'webpdf.deb' in "./packages/'
ARG LOCAL_PACKAGE=false

# copy local packages if available (the folder may be empty if a public package repository is used)
COPY ./packages /app

# install with the local package `webpdf.deb` or with the latest package version from https://packages.softvision.de
RUN if $LOCAL_PACKAGE ; \
    then \
      apt-get --yes install gdebi && gdebi --n /app/webpdf.deb && rm -rf /app ; \
    else \
      wget -qO - https://packages.softvision.de/keys/public.gpg | apt-key add - && \
      echo "deb https://packages.softvision.de/debian/webpdf/10/ $(lsb_release -sc) non-free" | tee /etc/apt/sources.list.d/webpdf.list && \
      apt-get update &&  apt-get --yes install webpdf ; \
    fi

# switch Chromium mode
RUN sed -i -r 's/<bridges\/>/<bridges><chromium noSandbox="true"\/><\/bridges>/' /opt/webpdf/conf/application.xml

# add "contrib" to sources.list
RUN sed -r -i 's/^deb(.*)$/deb\1 contrib/g' /etc/apt/sources.list && apt-get --yes update

# install some Windows default fonts
RUN wget -q -O /root/ttf-vista-fonts-installer.sh https://gist.githubusercontent.com/tavinus/1a92c79d790657d5b66546996dd006b9/raw/ttf-vista-fonts-installer.sh
RUN chmod +x /root/ttf-vista-fonts-installer.sh
RUN /root/ttf-vista-fonts-installer.sh

RUN echo "deb http://deb.debian.org/debian bookworm contrib non-free" > /etc/apt/sources.list.d/contrib.list
RUN apt-get --yes update
RUN apt-get --yes install ttf-mscorefonts-installer

# install some fonts packages
RUN apt-get --yes install \
    fonts-liberation2 \
    fonts-noto-core \
    fonts-noto-mono \
    fonts-noto-color-emoji \
    fonts-opensymbol \
    fonts-dejavu \
    fonts-firacode

# get some fonts from Wine project
RUN wget -q -O /root/wingding.sfd https://raw.githubusercontent.com/wine-mirror/wine/master/fonts/wingding.sfd
RUN wget -q -O /root/tahoma.sfd https://raw.githubusercontent.com/wine-mirror/wine/master/fonts/tahoma.sfd
RUN wget -q -O /root/tahomabd.sfd https://raw.githubusercontent.com/wine-mirror/wine/master/fonts/tahomabd.sfd

RUN fontforge -lang=ff -c 'Open($1); Generate($2)' /root/wingding.sfd /usr/share/fonts/truetype/msttcorefonts/wingding.ttf
RUN fontforge -lang=ff -c 'Open($1); Generate($2)' /root/tahoma.sfd /usr/share/fonts/truetype/msttcorefonts/tahoma.ttf
RUN fontforge -lang=ff -c 'Open($1); Generate($2)' /root/tahomabd.sfd /usr/share/fonts/truetype/msttcorefonts/tahomabd.ttf

## copy the fonts into a single folder
RUN mkdir /root/fonts && \
    cp /usr/share/fonts/truetype/*/*.ttf /root/fonts -n && \
    rm /usr/share/fonts/truetype/* -R && \
    mv /root/fonts/* /usr/share/fonts/truetype/ && \
    rm /root/fonts/ -R && \
    dpkg-reconfigure -f noninteractive -plow fontconfig && \
    fc-cache -fv

## cleanup
RUN /etc/init.d/x11-common stop && \
    apt-get -y autoremove && \
    apt-get -y clean && \
    apt-get -y purge && \
    find /var/log/ -maxdepth 1 -type f -delete && \
    rm -rf /root/*

# Set the locale
ENV LANG de_DE.UTF-8
ENV LANGUAGE de_DE.UTF-8
ENV LC_ALL de_DE.UTF-8
ENV TZ Europe/Berlin

# create log folder
RUN mkdir /opt/webpdf/logs
RUN chown webpdf:webpdf /opt/webpdf/logs

# switch user
USER webpdf

# expose default server port
EXPOSE 8080

# start the server
CMD [ "/opt/webpdf/webpdf.starter.sh" ]
