FROM nginx:1.21-alpine

# Add self-signed certificate (otherwise Traefik would be mandatory for https)
RUN set -ex; \
    apk add --no-cache --virtual .build-deps \
        openssl; \
    mkdir /etc/nginx/certs; \
    openssl req -x509 -nodes -days 730 -newkey rsa:2048 -sha256 \
        -subj "/CN=*.docker.localhost" \
        -addext "subjectAltName=DNS:docker.localhost,DNS:*.docker.localhost" \
        -keyout /etc/nginx/certs/magento.key \
        -out /etc/nginx/certs/magento.crt; \
    apk del .build-deps
