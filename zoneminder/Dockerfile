FROM armv7/armhf-baseimage:0.9.16

MAINTAINER aptalca

VOLUME ["/config"]

EXPOSE 80

RUN export DEBCONF_NONINTERACTIVE_SEEN=true DEBIAN_FRONTEND=noninteractive && \
apt-get update && \
apt-get install -y \
software-properties-common \
python-software-properties && \
add-apt-repository -y ppa:iconnor/zoneminder && \
apt-get update && \
apt-get install -y \
wget \
apache2 \
mysql-server \
php5 \
libapache2-mod-php5 \
usbutils && \
service apache2 restart && \
service mysql restart && \
apt-get install -y \
zoneminder \
libvlc-dev \
libvlccore-dev vlc && \
a2enmod cgi && \
service apache2 restart && \
service mysql restart && \
rm -r /etc/init.d/zoneminder && \
mkdir -p /etc/my_init.d

RUN adduser -u 1000 pirate --disabled-login && \
adduser root pirate && \
adduser mysql pirate && \
adduser www-data pirate

ADD zoneminder /etc/init.d/zoneminder
ADD firstrun.sh /etc/my_init.d/firstrun.sh

RUN chmod +x /etc/init.d/zoneminder && \
chmod +x /etc/my_init.d/firstrun.sh && \
mkdir /etc/apache2/conf.d && \
ln -s /etc/apache2/conf-available/zoneminder.conf /etc/zm/apache.conf && \
ln -s /etc/zm/apache.conf /etc/apache2/conf.d/zoneminder.conf && \
ln -s /etc/zm/apache.conf /etc/apache2/conf-enabled/zoneminder.conf && \
adduser www-data video && \
service apache2 restart


RUN cd /usr/src && \
wget http://www.andywilcock.com/code/cambozola/cambozola-latest.tar.gz

RUN cd /usr/src && tar zxvf cambozola-latest.tar.gz && \
cp cambozola-*/dist/cambozola.jar /usr/share/zoneminder && \
cp /etc/zm/apache.conf /root/apache.conf && \
cp /etc/zm/zm.conf /root/zm.conf && \
update-rc.d -f apache2 remove && \
update-rc.d -f mysql remove && \
update-rc.d -f zoneminder remove
