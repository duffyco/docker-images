FROM hypriot/rpi-alpine-scratch:edge
MAINTAINER Pieter van der Eems <docker@eemco.nl>

ARG USER_ID=1000
ARG GROUP_ID=1000

#RUN deluser mysql && \
RUN    addgroup -g $GROUP_ID mysql && \
    adduser -D mysql -G mysql -u $USER_ID 

RUN apk update
RUN apk upgrade
RUN apk --update add mariadb mariadb-client pwgen && \
    rm -f /var/cache/apk/*

ADD run.sh /scripts/run.sh
RUN mkdir /scripts/pre-exec.d && \
    mkdir /scripts/pre-init.d && \
    chmod -R 755 /scripts

EXPOSE 3306

VOLUME ["/var/lib/mysql"]

ENTRYPOINT ["/scripts/run.sh"]
