FROM nginx:1.18

COPY ./etc/vhost.conf /etc/nginx/conf.d/default.conf

ENV WEB_HOST fpm
ENV FPM_HOST fpm
ENV FPM_PORT 9000
ENV MAGENTO_ROOT /var/www/html
ENV MAGENTO_RUN_MODE developer
ENV UPLOAD_MAX_FILESIZE 64M

COPY ./docker-entrypoint.sh /
RUN ["chmod", "+x", "/docker-entrypoint.sh"]
ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["nginx", "-g", "daemon off;"]
