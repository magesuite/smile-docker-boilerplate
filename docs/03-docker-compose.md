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

## Crontab

By default, the cron container is disabled (it is quite resource-intensive).

To enable it, run the following command:

```
make toggle-cron
```

Running the command again will disable it.

## Customizing Containers

### Configuration Files

The configuration files are located in the directory "docker/conf".

These files are mapped to the containers in [compose.yaml](../compose.yaml).
You can create additional config files by using the same logic.

To apply a change:

- If you changed the contents of an existing file, you must restart the container:
  `make restart service=xxx`.
- If you added a new config file, you must recreate the container:
  `make up service=xxx`.

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

### Using Your SSH Keys Inside a Container

If you need to use your SSH keys inside the php container, add the following configuration in compose.override.yaml:

```yaml
services:
    php:
        # ...
        environment:
            # ...
            SSH_AUTH_SOCK: $SSH_AUTH_SOCK
        volumes:
            # ...
            - $SSH_AUTH_SOCK:$SSH_AUTH_SOCK
            - ~/.ssh:/home/www/.ssh
```

Then, run the following command to apply the change: `make up service=php`

### Replacing npm with yarn

Some packages require to use yarn instead of npm (e.g. elasticsuite premium).

To replace npm with yarn, apply the following changes:

- In Makefile:
    - Replace `npm install` with `yarn install`.
    - Replace `npm exec grunt` with `yarn exec grunt`.
- In compose.override.yaml:
    - Replace `npm:/home/www/.npm` with `yarn:/home/www/.cache/yarn`
    - Rename `npm` volume to `yarn`

### Setting up Multiple Stores

If you need to add stores (or websites), follow the steps below.

1. Make sure that the store URLs are properly defined in the Magento configuration.

2. In docker/conf/nginx/default-dev.conf, add the following code:

   ```
   map $http_host $MAGE_RUN_CODE {
       default '';
       myotherstore.docker.localhost myotherstore;
   }
   ```

3. In the same file, add the following fastcgi params:

   ```
   fastcgi_param MAGE_RUN_TYPE store;
   fastcgi_param MAGE_RUN_CODE $MAGE_RUN_CODE;
   ```

4. In compose.override.yaml, add Traefik labels to the `varnish` service (for each store/website):

   ```
   # Additional domains
   - traefik.http.routers.$PROJECT_NAME-magento-myotherstore-http.rule=Host(`myotherstore.docker.localhost`)
   - traefik.http.routers.$PROJECT_NAME-magento-myotherstore-http.entrypoints=http
   - traefik.http.routers.$PROJECT_NAME-magento-myotherstore-https.rule=Host(`myotherstore.docker.localhost`)
   - traefik.http.routers.$PROJECT_NAME-magento-myotherstore-https.entrypoints=https
   - traefik.http.routers.$PROJECT_NAME-magento-myotherstore-https.tls=true
   ```

5. Run the following command:

   ```
   make up && make restart service=web
   ```

Alternatively, you can use a regexp to define a single Traefik label for all stores.
For example:

```
# Additional domains
- traefik.http.routers.$PROJECT_NAME-magento-subdomains-http.rule=HostRegexp(`{subdomain:$PROJECT_NAME-[a-z0-9]+}.docker.localhost`)
- traefik.http.routers.$PROJECT_NAME-magento-subdomains-http.entrypoints=http
- traefik.http.routers.$PROJECT_NAME-magento-subdomains-https.rule=HostRegexp(`{subdomain:$PROJECT_NAME-[a-z0-9]+}.docker.localhost`)
- traefik.http.routers.$PROJECT_NAME-magento-subdomains-https.entrypoints=https
- traefik.http.routers.$PROJECT_NAME-magento-subdomains-https.tls=true
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
- The variables PHP_VERSION must match the requirements of your project.

If a container is failing, you can check the startup logs by running `docker compose run --rm <container_name>` (e.g. "web").
