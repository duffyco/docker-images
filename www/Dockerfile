FROM alpine-nginx:latest

RUN rm /etc/nginx/nginx.conf
ADD etc/nginx /etc/nginx

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
