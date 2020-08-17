FROM hypriot/rpi-alpine-scratch
MAINTAINER Alexander Puzynia <werwolf.by@gmail.com>

ARG USER_ID=1000
ARG GROUP_ID=1000

RUN apk update && \
    apk upgrade && \
    delgroup www-data && \ 
    addgroup -g $GROUP_ID www-data && \
    apk add nginx && \
    adduser -D www-data -G www-data -u $USER_ID && \
    ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log && \
    chown -R www-data:www-data /var/lib/nginx

RUN chown -R www-data:www-data /home

EXPOSE 80 443

CMD ["nginx", "-g", "daemon off;"]
