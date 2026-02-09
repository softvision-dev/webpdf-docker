# Stage 1: system fonts
ARG BASE_IMAGE=docker.io/library/debian:trixie-slim
FROM ${BASE_IMAGE} AS system_fonts

ENV DEBIAN_FRONTEND=noninteractive

RUN echo "deb http://deb.debian.org/debian trixie contrib non-free" > /etc/apt/sources.list.d/contrib.list && \
    apt-get --yes update && \
    apt-get --yes --no-install-recommends install \
    ttf-mscorefonts-installer \
    fonts-liberation2 \
    fonts-noto-core \
    fonts-noto-mono \
    fonts-noto-color-emoji \
    fonts-opensymbol \
    fonts-dejavu \
    fonts-firacode && \
    rm -rf /var/lib/apt/lists/*

# Stage 2: custom fonts (from Vista & Wine)
FROM ${BASE_IMAGE} AS custom_fonts

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get --yes update && \
    apt-get --yes --no-install-recommends install wget ca-certificates cabextract fontforge && \
    update-ca-certificates && \
    mkdir -p /usr/share/fonts/truetype/msvistafonts && \
    wget -q -O /root/ttf-vista-fonts-installer.sh https://gist.githubusercontent.com/tavinus/1a92c79d790657d5b66546996dd006b9/raw/ttf-vista-fonts-installer.sh && \
    chmod +x /root/ttf-vista-fonts-installer.sh && \
    /root/ttf-vista-fonts-installer.sh && \
    wget -q -O /root/wingding.sfd https://raw.githubusercontent.com/wine-mirror/wine/master/fonts/wingding.sfd && \
    wget -q -O /root/tahoma.sfd https://raw.githubusercontent.com/wine-mirror/wine/master/fonts/tahoma.sfd && \
    wget -q -O /root/tahomabd.sfd https://raw.githubusercontent.com/wine-mirror/wine/master/fonts/tahomabd.sfd && \
    fontforge -lang=ff -c 'Open($1); Generate($2)' /root/wingding.sfd /usr/share/fonts/truetype/msvistafonts/wingding.ttf && \
    fontforge -lang=ff -c 'Open($1); Generate($2)' /root/tahoma.sfd /usr/share/fonts/truetype/msvistafonts/tahoma.ttf && \
    fontforge -lang=ff -c 'Open($1); Generate($2)' /root/tahomabd.sfd /usr/share/fonts/truetype/msvistafonts/tahomabd.ttf && \
    rm -rf /root/*.sfd && \
    rm -rf /var/lib/apt/lists/*

# Stage 3: font consolidation
FROM ${BASE_IMAGE} AS font_base

COPY --from=system_fonts /usr/share/fonts/truetype /usr/share/fonts/truetype
COPY --from=custom_fonts /usr/share/fonts/truetype/msvistafonts/*.ttf /usr/share/fonts/truetype/custom/

RUN mkdir -p /root/fonts && \
    cp /usr/share/fonts/truetype/*/*.ttf /root/fonts -n

# copy the installation package (will be mounted in the next build stage)
COPY ./packages /root

# Stage 4: final webPDF installation
FROM ${BASE_IMAGE}

LABEL maintainer="webPDF Docker Maintainers <info@softvision.de>"

ENV DEBIAN_FRONTEND=noninteractive

# change 'uid' and 'gid'
ARG USER_UID=10000
ARG USER_GID=10000

## set to true for using the local package 'webpdf.deb' in "./packages/'
ARG LOCAL_PACKAGE=false

## pin a specific webPDF package version (empty = latest from repo)
ARG WEBPDF_VERSION=""

# Set the locale
ENV LANG="de_DE.UTF-8"
ENV LANGUAGE="de_DE.UTF-8"
ENV LC_ALL="de_DE.UTF-8"
ENV TZ="Europe/Berlin"

COPY --from=font_base /root/fonts /usr/share/fonts/truetype

RUN --mount=type=bind,from=font_base,source=/root,target=/app \
    apt-get --yes update && \
    apt-get --yes --no-install-recommends install locales locales-all lsb-release fontconfig ca-certificates wget && \
    update-ca-certificates && \
    dpkg-reconfigure -f noninteractive -plow fontconfig && \
    fc-cache -fv && \
    if $LOCAL_PACKAGE ; \
    then \
      apt-get --yes --no-install-recommends install /app/webpdf.deb ; \
    else \
      wget -O /etc/apt/trusted.gpg.d/webpdf.gpg https://packages.softvision.de/keys/public.gpg && \
      echo "deb [signed-by=/etc/apt/trusted.gpg.d/webpdf.gpg] https://packages.softvision.de/debian/webpdf/10/ $(lsb_release -sc) non-free" | tee /etc/apt/sources.list.d/webpdf.list && \
      apt-get update && \
      if [ -n "$WEBPDF_VERSION" ]; then \
        apt-get --yes --no-install-recommends install "webpdf=$WEBPDF_VERSION" ; \
      else \
        apt-get --yes --no-install-recommends install webpdf ; \
      fi ; \
    fi && \
    rm -rf /usr/share/fonts/truetype/dejavu && \
    rm -rf /usr/share/fonts/truetype/liberation && \
    mv /usr/share/fonts/truetype/gonoto/* /usr/share/fonts/truetype/ && \
    rm -rf /usr/share/fonts/truetype/gonoto && \
    mkdir /opt/webpdf/logs && \
    userdel -f webpdf && \
    groupadd -f --gid $USER_GID webpdf && \
    useradd --shell /bin/bash --uid $USER_UID --gid $USER_GID webpdf && \
    chown -R $USER_UID:$USER_GID /home/webpdf && \
    chmod -R u+w,g+w /home/webpdf && \
    chgrp -R $USER_GID /opt/webpdf && \
    chmod -R g=u /opt/webpdf && \
    chown -R $USER_UID /opt/webpdf && \
    /etc/init.d/x11-common stop && \
    apt-get -y autoremove && \
    apt-get -y clean && \
    apt-get -y purge && \
    find /var/log/ -maxdepth 1 -type f -delete && \
    rm -rf /root/* && \
    rm -rf /var/lib/apt/lists/*

# disable Chromium sandbox mode
RUN sed -i -r 's/<bridges\/>/<bridges><chromium noSandbox="true"\/><\/bridges>/' /opt/webpdf/conf/application.xml

# Backup default configuration for initialization on first start
# This allows the container to initialize empty volumes with default config
RUN cp -a /opt/webpdf/conf /opt/webpdf/conf-defaults

# add modified start script with config initialization logic
COPY --chmod=755 --chown=webpdf:webpdf ./other/webpdf.starter.sh /opt/webpdf/webpdf.starter.sh

# switch user
USER webpdf

# expose default server port
EXPOSE 8080

# health check with the server endpoint
HEALTHCHECK --interval=30s \
            --timeout=10s \
            --start-period=90s \
            --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost:8080/webPDF/health || exit 1

## start the server
CMD [ "/opt/webpdf/webpdf.starter.sh" ]
