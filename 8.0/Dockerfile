FROM debian:buster
LABEL maintainer="webPDF Docker Maintainers <info@softvision.de>"

# installing packages...
RUN apt-get update

RUN apt-get --yes install \
    wget \
    gpg \
    apt-transport-https \
    rcconf \
    locales \
    locales-all

# adding key for the package repository
RUN APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=1 apt-key adv --fetch-keys https://packages.softvision.de/keys/public.gpg  > /dev/null 2>&1

# installing repository
RUN echo "deb https://packages.softvision.de/debian/webpdf/8/ buster non-free" | tee /etc/apt/sources.list.d/webpdf.list && apt-get update

# installing application ...
RUN apt-get --yes install webpdf

# switching Chromium mode
RUN sed -i -r 's/<bridges\/>/<bridges><chromium noSandbox="true"\/><\/bridges>/' /opt/webpdf/conf/application.xml

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
    rm -rf /root/*

# Set the locale
ENV LANG de_DE.UTF-8
ENV LANGUAGE de_DE.UTF-8
ENV LC_ALL de_DE.UTF-8
ENV TZ Europe/Berlin

RUN mkdir /opt/webpdf/logs
RUN chown webpdf:webpdf /opt/webpdf/logs

ENV JAVA_PARAMETERS "-Xmx2048m -Xms1024m"
COPY run.sh /opt/webpdf/run.sh

RUN chmod +x /opt/webpdf/run.sh
RUN chown webpdf:webpdf /opt/webpdf/run.sh

USER webpdf

EXPOSE 8080

CMD [ "/opt/webpdf/run.sh" ]

