FROM registry.duffyco.ca:5000/alpine-nginx:20200331

RUN rm /etc/nginx/nginx.conf
ADD etc/nginx /etc/nginx

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
