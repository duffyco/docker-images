FROM alpine-nginx-php

ADD etc/nginx /etc/nginx
#COPY run.sh /usr/local/bin/run.sh

RUN chown -R www-data:www-data /home
VOLUME /home
#USER www-data

EXPOSE 80

CMD ["run.sh"]
