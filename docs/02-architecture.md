# Architecture

## Traefik

Traefik is a reverse proxy that automatically dispatches HTTP requests to docker containers.

Thanks to Traefik, it is possible to work on multiple docker projects at the same time without experiencing any issue related to port/url conflicts.
Traefik reads the labels defined in the docker compose files in order to know where to dispatch the HTTP requests.

It is only used on development environments.

## Services

The following services are defined in compose.yaml:

Name | Description | Ports
--- | --- | ---
varnish | HTTP cache server. | 80
web | Web server (nginx). | 8080
php | php-fpm. | 9000
php_xdebug | php-fpm with xdebug installed.<br>Automatically used when the xdebug session cookie is set. | 9000
db | SQL database (mariadb). | 3306
redis | Cache engine (stores Magento cache/sessions). | 6379
elasticsearch | Search engine. | 9300
maildev | Mail server. | 1025 (smtp)<br>1080 (web interface)
rabbitmq | [Message broker](https://devdocs.magento.com/guides/v2.4/install-gde/prereq/install-rabbitmq.html). | 5672<br>15672 (web interface)
cron | Runs the Magento crontab (disabled by default). | -

## Workflow

HTTP requests are handled with the following workflow:  
traefik > varnish (port 80) > web (port 8080) > php or php_xdebug (port 9000)

If the requested resource exists in the Varnish cache, Varnish returns the cached version of the resource.
Otherwise, Varnish transfers the HTTP request to nginx, which in turn transfers it to php-fpm.

If the cookie "XDEBUG_SESSION" is set, the request is handled by the php_xdebug container.
Otherwise, it is handled by the php container.
