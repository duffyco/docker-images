FROM registry.duffyco.ca:5000/alpine-nginx-php:20200331

ADD etc/nginx /etc/nginx
#COPY run.sh /usr/local/bin/run.sh

RUN chown -R www-data:www-data /home
VOLUME /home
#USER www-data

EXPOSE 80

CMD ["run.sh"]
