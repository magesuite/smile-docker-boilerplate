# Working with Docker

## Interacting with Containers

The following Makefile targets allow you to interact with the docker containers:

- `make up`: start all containers.
- `make down`: stop all containers (use this if you want to start working on another project).
- `make ps`: list active containers and their status.
- `make top`: list running processes on all containers.
- `make logs`: list Docker logs.
- `make build`: rebuild the images stored in ./docker/images.

Most targets accept a parameter named `service` (e.g. `make up service=php`).

The target "logs" also accepts a parameter named "tail", which defines the number of previous logs to display (20 by default).
For example, `make logs service=web tail=50` displays the 50 latest log entries for the web container (and continues displaying new logs).

## Connecting to a Container

You can open a SSH connection to any container by running `make sh`.
This target can also be used to run a specific command on a container.

For example:

- `make sh` opens a shell on the php container.
- `make sh service=redis` opens a shell on the redis container.
- `make sh service=redis c="redis-cli flushdb"` runs the command defined in the parameter "c=" on the redis container.

## Customizing Containers

### Editing a Configuration File

The configuration files are located here:

- Nginx vhost: ./docker/conf/nginx/default.conf
- Varnish VCL: ./docker/conf/varnish/default.vcl
- Redis conf: ./docker/conf/redis/redis.conf

These files are mapped to the containers in compose.yaml.

If you change the contents of one of these files, you must restart the container to apply the change.
For example, if you change the contents of the nginx vhost, run `make restart service=web`.

### Adding a Configuration File

It is very easy to bind a new configuration file to a container.
For example, to add a configuration file for MySQL:

- Create the file "./docker/conf/mysql/mysql.cnf".
- Add a volume to the `db` service in compose.yaml:

    ```yaml
    db:
        # Replace "myproject" by your project name
        volumes:
            - ./docker/conf/mysql/mysql.cnf:/etc/mysql/conf.d/myproject.cnf`
    ```

- Recreate the service: `make up service=db`.

### Persisting the Redis Cache

By default, this boilerplate does not mount a volume on the redis container.
This means that you will lose all cached data when the container is removed.

If for some reason, your project requires to persist the Magento cache, add a volume named `redisdata` in compose.yaml:

```yaml
services:
    redis:
        volumes:
            - redisdata:/data

volumes:
    redisdata:
```

## Troubleshooting

If you experience any issue related to your Docker containers, please follow these steps.

Check your Docker installation:

- Make sure that Traefik is [up and running](https://git.smile.fr/docker/traefik#usage).
- Double check that you applied the [post-installation steps for Linux](https://docs.docker.com/engine/install/linux-postinstall/) after you installed Docker Compose.
- Make sure that the "magento" directory isn't owned by the root user.

Check the .env file:

- The variable PROJECT_NAME must be defined.
- The variables DOCKER_UID and DOCKER_GID must match the output of `id -u` and `id -g`.
- The variables PHP_VERSION and COMPOSER_VERSION must match the requirements of your project.

If a container is failing, you can check the startup logs by running `docker compose run --rm <container_name>` (e.g. "web").
