# Customizing Containers

## Editing a Configuration File

The configuration files are located here:

- Nginx vhost: ./docker/conf/nginx/default.conf
- Varnish VCL: ./docker/conf/varnish/default.vcl
- Redis conf: ./docker/conf/redis/redis.conf

These files are mapped to the containers in `docker-compose.yml`.

If you change the contents of one of these files, you must restart the container to apply the change.
For example, if you change the contents of the nginx vhost, run `make restart service=web`.

## Adding a Configuration File

It is very easy to bind a new configuration file to a container.
For example, to add a configuration file for MySQL:

- Create the file "./docker/conf/mysql/mysql.cnf".
- Add a volume to the `db` service in docker-compose.yml:

    ```yaml
    db:
        # Replace "myproject" by your project name
        volumes:
            - ./docker/conf/mysql/mysql.cnf:/etc/mysql/conf.d/myproject.cnf`
    ```

- Recreate the service: `make up service=db`.

## Persisting the Redis Cache

By default, this boilerplate does not mount a volume on the redis container.
This means that you will lose all cached data when the container is removed.

If for some reason, your project requires to persist the Magento cache, add a volume named `redisdata` in docker-compose.yml:

```yaml
services:
    redis:
        volumes:
            - redisdata:/data
volumes:
    redisdata:
```
