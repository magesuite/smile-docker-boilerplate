FROM nginx:1.21-alpine

RUN set -ex; \
    apk update; \
    apk add --no-cache --virtual .build-deps \
        openssl; \
    mkdir /etc/ssl/private; \
    openssl req -x509 -nodes -days 365 \
        -subj "/C=CA/ST=QC/O=Company, Inc./CN=magento2.docker" \
        -addext "subjectAltName=DNS:magento2.docker" \
        -newkey rsa:2048 \
        -keyout /etc/ssl/private/magento.key \
        -out /etc/ssl/certs/magento.pem; \
    apk del .build-deps

COPY ./etc/vhost.conf /etc/nginx/conf.d/default.conf

ENV FPM_HOST fpm
ENV FPM_PORT 9000
ENV UPSTREAM_HOST varnish
ENV UPSTREAM_PORT 80
ENV MAGENTO_ROOT /var/www/html
ENV MAGENTO_RUN_MODE developer
ENV UPLOAD_MAX_FILESIZE 64M

COPY ./docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["nginx", "-g", "daemon off;"]
