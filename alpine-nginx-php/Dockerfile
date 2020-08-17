FROM hypriot/rpi-alpine-scratch:v3.3
MAINTAINER Pieter van der Eems <docker@eemco.nl>

ARG S6_OVERLAY_VERSION=v1.18.1.5
ARG BUILD_DEPS="gnupg tar"

ARG USER_ID=1000
ARG GROUP_ID=1000

#ENV UID=991 GID=991
ENV UID=$USER_ID GID=$GROUP_ID

RUN apk update
RUN apk upgrade
RUN apk add bind-tools curl && \
    curl -sSL https://github.com/just-containers/s6-overlay/releases/download/${S6_OVERLAY_VERSION}/s6-overlay-armhf.tar.gz \
    | tar xfz - -C /

#RUN echo " https://nl.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories \
# && echo "@testing https://nl.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories
#RUN BUILD_DEPS="gnupg tar" \
RUN apk -U add \
    ${BUILD_DEPS} \
    nginx \
    openssl \
    ca-certificates \
    libsmbclient \
    samba-client \
    su-exec \
    php \
    php-fpm \
    php-intl \
    php-curl \
    php-gd \
    php-mcrypt \
    php-opcache \
    php-json \
#    php-session \
    php-pdo \
    php-dom \
    php-ctype \
    php-iconv \
    php-pdo_mysql \
    php-pdo_pgsql \
    php-pgsql \
    php-pdo_sqlite \
    php-sqlite3 \
    php-zlib \
    php-zip \
    php-xmlreader \
    php-xml \
    php-posix \
    php-openssl \
    php-ldap \
    php-ftp \
    php-apcu 

RUN delgroup www-data && \
    addgroup -g $GROUP_ID www-data

RUN adduser -S -G adm www-data -u $USER_ID && \
    addgroup www-data xfs && \
  ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log && \
    chown -R www-data:www-data /var/lib/nginx

RUN chown -R www-data:www-data /home

RUN rm -rf /var/lib/nginx

COPY nginx.conf /etc/nginx/nginx.conf
COPY php-fpm.conf /etc/php/php-fpm.conf
COPY run.sh /usr/local/bin/run.sh
COPY s6.d /etc/s6.d

RUN chmod +x /usr/local/bin/* /etc/s6.d/*/*

EXPOSE 80 443

CMD ["run.sh"]
