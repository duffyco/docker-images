FROM alpine-nginx:latest

ADD etc/nginx /etc/nginx

VOLUME /etc/nginx/sites-enabled /etc/nginx/ssl-conf

EXPOSE 80 443

CMD ["nginx", "-g", "daemon off;"]
