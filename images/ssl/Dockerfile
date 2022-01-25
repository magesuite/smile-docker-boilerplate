FROM nginx:1.21

ENV UPSTREAM_HOST web
ENV UPSTREAM_PORT 80

RUN openssl req -x509 -nodes -days 365 \
    -subj "/C=CA/ST=QC/O=Company, Inc./CN=magento2.docker" \
    -addext "subjectAltName=DNS:magento2.docker" \
    -newkey rsa:2048 \
    -keyout /etc/ssl/private/magento.key \
    -out /etc/ssl/certs/magento.pem

COPY ./etc/vhost.conf /etc/nginx/conf.d/default.conf

COPY ./docker-entrypoint.sh /
RUN ["chmod", "+x", "/docker-entrypoint.sh"]
ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["nginx", "-g", "daemon off;"]
