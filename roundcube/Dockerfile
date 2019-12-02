FROM    armv7/armhf-debian
ENV     DEBIAN_FRONTEND noninteractive
ENV     TERM xterm
MAINTAINER Round Cube <rc@xxx.org>

ARG USER_ID=1000
ARG GROUP_ID=1000

RUN printf "deb http://archive.debian.org/debian/ jessie main\ndeb-src http://archive.debian.org/debian/ jessie main\ndeb http://security.debian.org jessie/updates main\ndeb-src http://security.debian.org jessie/updates main" > /etc/apt/sources.list

RUN apt-get -y update && apt-get -y upgrade
   
RUN apt-get install -y --no-install-recommends \
    nginx php5-fpm nano wget sqlite3 procps \
    php5-mcrypt php5-intl php5-sqlite php-pear \
    php-net-smtp php-mail-mime
WORKDIR /root

RUN deluser www-data && \
    addgroup --gid $GROUP_ID www-data && \
    adduser --ingroup www-data --uid $USER_ID www-data --disabled-login

# when roundcube grows older, change version in the download link, but also in the 'mv' command
ADD roundcubemail-1.3.0-complete.tar.gz /root/
RUN \
    rm -fr /usr/share/nginx/www ;\
    mv /root/roundcubemail-1.3.0 /usr/share/nginx/www ;\
    rm -fr /usr/share/nginx/www/installer ;\
    mkdir -p /rc
ADD config.inc.php /usr/share/nginx/www/config/
ADD default /etc/nginx/sites-enabled/default
ADD launch.sh /root/

RUN echo "upload_max_filesize=200M" >> /etc/php5/fpm/php.ini
RUN echo "post_max_size=201M" >> /etc/php5/fpm/php.ini

VOLUME /rc
CMD [ "bash", "/root/launch.sh" ]
