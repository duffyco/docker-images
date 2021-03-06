#FROM armv7/armhf-ubuntu:14.04
FROM arm32v7/debian:stretch-slim
MAINTAINER Thomas VIAL

ENV DEBIAN_FRONTEND noninteractive
ENV VIRUSMAILS_DELETE_DELAY=7
ENV ONE_DIR=0

# Packages
RUN apt-get update -q --fix-missing && \
  apt-get -y upgrade && \
  apt-get -y install --no-install-recommends \
    amavisd-new \
    arj \
    bzip2 \
    clamav \
    clamav-daemon \
    curl \
    dovecot-core \
    dovecot-imapd \
    dovecot-ldap \
    dovecot-lmtpd \
    dovecot-managesieved \
    dovecot-pop3d \
    dovecot-sieve \
    ed \
    fail2ban \
    fetchmail \
    file \
    gamin \
    gzip \
    iptables \
    libmail-spf-perl \
    libnet-dns-perl \
    libsasl2-modules \
    opendkim \
    opendkim-tools \
    opendmarc \
    p7zip \
    postfix \
    postfix-ldap \
    postfix-policyd-spf-python \
    pyzor \
    razor \
    rsyslog \
    sasl2-bin \
    spamassassin \
    postgrey \
    unzip 

RUN apt-get update -q --fix-missing && apt-get -y upgrade fail2ban && \
  apt-get autoclean && rm -rf /var/lib/apt/lists/* && \
  rm -rf /usr/share/locale/* && rm -rf /usr/share/man/* && rm -rf /usr/share/doc/* && \
  touch /var/log/auth.log 

# Configures Postfix
RUN echo "" > /etc/aliases
RUN openssl dhparam -out /etc/postfix/dhparams.pem 2048
COPY target/postfix/main.cf target/postfix/master.cf /etc/postfix/

RUN mkdir -p /opt/filebeat
COPY ./filebeat-linux-arm /opt/filebeat/
RUN ls -al /opt/filebeat

# Install filebeat
#RUN apt-get update && \
#  apt-get -y install wget && \
#  wget https://beats-nightlies.s3.amazonaws.com/jenkins/filebeat/1346-074add2c8a39973c4af3d521432733a5960b2ff7/filebeat-linux-arm && \

#  mkdir /opt/filebeat && \
#  mv ~/filebeat-linux-arm /opt/filebeat && \
RUN  chmod +x /opt/filebeat/filebeat-linux-arm

# JD: Fix for Ca-certificates else freshclam won't connect
RUN apt-get update && apt-get install -y ca-certificates

# Enables Clamav
RUN (echo "0 0,6,12,18 * * * /usr/bin/freshclam --quiet" ; crontab -l) | crontab -
RUN chmod 644 /etc/clamav/freshclam.conf && freshclam

# Configures Dovecot
RUN sed -i -e 's/include_try \/usr\/share\/dovecot\/protocols\.d/include_try \/etc\/dovecot\/protocols\.d/g' /etc/dovecot/dovecot.conf
RUN sed -i -e 's/#mail_plugins = \$mail_plugins/mail_plugins = \$mail_plugins sieve/g' /etc/dovecot/conf.d/15-lda.conf
RUN sed -i -e 's/^.*lda_mailbox_autocreate.*/lda_mailbox_autocreate = yes/g' /etc/dovecot/conf.d/15-lda.conf
RUN sed -i -e 's/^.*lda_mailbox_autosubscribe.*/lda_mailbox_autosubscribe = yes/g' /etc/dovecot/conf.d/15-lda.conf
RUN sed -i -e 's/^.*postmaster_address.*/postmaster_address = '${POSTMASTER_ADDRESS:="postmaster@domain.com"}'/g' /etc/dovecot/conf.d/15-lda.conf
RUN sed -i 's/#imap_idle_notify_interval = 2 mins/imap_idle_notify_interval = 29 mins/' /etc/dovecot/conf.d/20-imap.conf
COPY target/dovecot/auth-passwdfile.inc /etc/dovecot/conf.d/
COPY target/dovecot/??-*.conf /etc/dovecot/conf.d/

# Configures LDAP
COPY target/dovecot/dovecot-ldap.conf.ext /etc/dovecot
COPY target/postfix/ldap-users.cf target/postfix/ldap-groups.cf target/postfix/ldap-aliases.cf /etc/postfix/

# Enables Spamassassin CRON updates
RUN sed -i -r 's/^(CRON)=0/\1=1/g' /etc/default/spamassassin

#Enables Postgrey
COPY target/postgrey/postgrey /etc/default/postgrey
COPY target/postgrey/postgrey.init /etc/init.d/postgrey
RUN chmod 755 /etc/init.d/postgrey
RUN mkdir /var/run/postgrey
RUN chown postgrey:postgrey /var/run/postgrey

# Enables Amavis
RUN sed -i -r 's/#(@|   \\%)bypass/\1bypass/g' /etc/amavis/conf.d/15-content_filter_mode
RUN adduser clamav amavis && adduser amavis clamav
RUN groupadd -g 1000 mailusers
RUN useradd -u 1000 -g 1000 -d /home/docker -s /bin/bash -p $(echo docker | openssl passwd -1 -stdin) docker
RUN (echo "0 4 * * * /usr/local/bin/virus-wiper" ; crontab -l) | crontab -

# Configure Fail2ban
COPY target/fail2ban/jail.conf /etc/fail2ban/jail.conf
COPY target/fail2ban/filter.d/dovecot.conf /etc/fail2ban/filter.d/dovecot.conf
RUN echo "ignoreregex =" >> /etc/fail2ban/filter.d/postfix-sasl.conf

# Enables Pyzor and Razor
USER amavis
RUN razor-admin -create && razor-admin -register && pyzor discover
USER root

# Configure DKIM (opendkim)
# DKIM config files
COPY target/opendkim/opendkim.conf /etc/opendkim.conf
COPY target/opendkim/default-opendkim /etc/default/opendkim

# Configure DMARC (opendmarc)
COPY target/opendmarc/opendmarc.conf /etc/opendmarc.conf
COPY target/opendmarc/default-opendmarc /etc/default/opendmarc
COPY target/opendmarc/ignore.hosts /etc/opendmarc/ignore.hosts

# Configure fetchmail
COPY target/fetchmail/fetchmailrc /etc/fetchmailrc_general
RUN sed -i 's/START_DAEMON=no/START_DAEMON=yes/g' /etc/default/fetchmail

# Configures Postfix
#COPY target/postfix/main.cf target/postfix/master.cf /etc/postfix/
#RUN echo "" > /etc/aliases
#RUN openssl dhparam -out /etc/postfix/dhparams.pem 2048

# Configuring Logs
RUN adduser --system syslog
RUN sed -i -r "/^#?compress/c\compress\ncopytruncate" /etc/logrotate.conf && \
  mkdir -p /var/log/mail && \
  chown syslog:root /var/log/mail && \
  touch /var/log/mail/clamav.log && \
  chown -R clamav:root /var/log/mail/clamav.log && \
  touch /var/log/mail/freshclam.log && \
  chown -R clamav:root /var/log/mail/freshclam.log && \
  sed -i -r 's|/var/log/mail|/var/log/mail/mail|g' /etc/rsyslog.conf && \
  sed -i -r 's|;auth,authpriv.none|;mail.none;mail.error;auth,authpriv.none|g' /etc/rsyslog.conf && \
  sed -i -r 's|LogFile /var/log/clamav/|LogFile /var/log/mail/|g' /etc/clamav/clamd.conf && \
  sed -i -r 's|UpdateLogFile /var/log/clamav/|UpdateLogFile /var/log/mail/|g' /etc/clamav/freshclam.conf && \
  sed -i -r 's|/var/log/clamav|/var/log/mail|g' /etc/logrotate.d/clamav-daemon && \
  sed -i -r 's|/var/log/clamav|/var/log/mail|g' /etc/logrotate.d/clamav-freshclam && \
  sed -i -r 's|/var/log/mail|/var/log/mail/mail|g' /etc/logrotate.d/rsyslog && \
  sed -i -r '/\/var\/log\/mail\/mail.log/d' /etc/logrotate.d/rsyslog && \
  # prevent syslog logrotate warnings \
  sed -i -e 's/\(printerror "could not determine current runlevel"\)/#\1/' /usr/sbin/invoke-rc.d && \
  sed -i -e 's/^\(POLICYHELPER=\).*/\1/' /usr/sbin/invoke-rc.d && \
  # prevent email when /sbin/init or init system is not existing \
  sed -i -e 's/invoke-rc.d rsyslog rotate > \/dev\/null/invoke-rc.d rsyslog --quiet rotate > \/dev\/null/g' /etc/logrotate.d/rsyslog


# Get LetsEncrypt signed certificate
RUN curl -k https://letsencrypt.org/certs/lets-encrypt-x3-cross-signed.pem > /etc/ssl/certs/lets-encrypt-x3-cross-signed.pem

COPY ./target/bin /usr/local/bin
# Run filebeat

ADD ./target/filebeat.yml.tmpl /etc/filebeat/filebeat.yml.tmpl
ADD ./target/filebeat.conf /etc/init/filebeat.conf

#RUN groupadd -g 1000 mailusers && \
RUN usermod dovecot -g mailusers && \
    usermod postfix -g mailusers &&  \
    usermod docker -g mailusers

RUN groupadd -g 507 vmail && \ 
    useradd -u 507 -g 507 vmail && \
    usermod vmail -g mailusers 

RUN apt-get update
RUN apt-get install -y procmail uudeview
RUN apt-get upgrade -y

RUN chown -R root:amavis /etc/spamassassin

RUN apt-get -y install iproute2 spamc
RUN adduser spamd --gecos "" --disabled-login


COPY ./target/spamassassin/local.cf /etc/spamassassin/local.cf
COPY ./target/spamassassin/spamassassin /etc/default/spamassassin 

# Start-mailserver script
COPY ./target/start-mailserver.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/*

EXPOSE 25 587 143 993 110 995 4190

CMD /usr/local/bin/start-mailserver.sh

