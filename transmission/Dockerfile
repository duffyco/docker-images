FROM sparklyballs/base-vanilla-armhf
MAINTAINER sparklyballs

# install packages
RUN \
 apk add --no-cache \
        curl \
        jq \
        p7zip \
        openssl \
        tar \
        transmission-cli \
        transmission-daemon \
        unrar \
        unzip

RUN apk add --no-cache\
    su-exec \
    python \
    python-dev \
    py-pip \
    build-base


RUN pip install -U pip setuptools \
    flexget transmissionrpc

RUN apk update
RUN apk upgrade --available

ARG USER_ID=1000

RUN adduser -D www-data -G users -u $USER_ID
RUN usermod -G xfs www-data

RUN chown -R www-data:users /config
RUN chmod -R 775 /config

#add local files
COPY root/ /

RUN chmod +x /etc/services.d/flexget/flexget-start.sh

# Volumes and Ports
VOLUME /config /downloads /watch
EXPOSE 9091 51413 5050
