#!/bin/sh

#mkdir /var/lib/nginx
#mkdir /var/lib/nginx/tmp
#chown -R www-data:www-data /etc/nginx /etc/php /var/log /var/lib/nginx /tmp /etc/s6.d
#chown -R www-data:www-data /etc/nginx /etc/php /var/log /var/lib/nginx /tmp /etc/s6.d
rm -rf /etc/sd6.d/nginx

crond
exec nginx -g 'daemon off;' &
exec su-exec www-data:www-data /bin/s6-svscan /etc/s6.d
