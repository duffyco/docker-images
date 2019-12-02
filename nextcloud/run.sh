#!/bin/sh

if [ ! -f /config/config.php ]; then
    echo -e "<?php\n\$CONFIG = array (\n  'datadirectory' => '/data',\n);" > /config/config.php
fi

mkdir -p /var/log/nginx
touch /var/log/nginx/error.log
chown -R $UID:$GID /nextcloud /data /config /apps2 /etc/nginx /etc/php /var/log /var/lib/nginx /tmp /etc/s6.d
ln -s /config/config.php /nextcloud/config/config.php
ln -s /apps2 /nextcloud

crond
exec su-exec $UID:$GID /bin/s6-svscan /etc/s6.d
