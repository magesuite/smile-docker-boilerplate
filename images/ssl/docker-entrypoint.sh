#!/bin/sh

VHOST_FILE="/etc/nginx/conf.d/default.conf"

[ ! -z "${UPSTREAM_HOST}" ] && sed -i "s/!UPSTREAM_HOST!/${UPSTREAM_HOST}/" $VHOST_FILE
[ ! -z "${UPSTREAM_PORT}" ] && sed -i "s/!UPSTREAM_PORT!/${UPSTREAM_PORT}/" $VHOST_FILE

# Check if the nginx syntax is fine, then launch
nginx -t

exec "$@"
