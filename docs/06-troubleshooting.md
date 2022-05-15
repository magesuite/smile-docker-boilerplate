# Troubleshooting

## Docker Containers

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

## GitLab CI

### Composer Authentication

If the CI fails, make sure that the variable "COMPOSER_AUTH" is defined in the settings of the git repository, and that it contains all required access keys.

### Composer 1

If you are using Magento < 2.4.2, the gitlab runner will probably fail.
This is because the gitlab runner only has composer 2 available, but older versions of Magento require composer 1.

To fix the issue, in magento/.gitlab-ci.yml, change:

```yaml
before_script:
    - composer install
```

To:

```yaml
before_script:
    - curl -sS https://getcomposer.org/installer | php -- --1
    - ./composer.phar install
```

## PhpStorm Code Inspection

Code inspection in PhpStorm doesn't work out of the box with docker.
The recommended way to validate your code is to [use the Makefile](02-makefile.md#code-quality).

However, if you still want to enable the code inspection in PhpStorm, follow these steps:

1. Open the PhpStorm configuration (File > Settings in the menu).

2. In the **PHP** section, add a CLI interpreter (choose the template "From Docker"):

    - Select "Docker Compose"
    - Configuration files: select the files "compose.yaml" and "compose.override.yaml" (in this order)
    - Service: select "php"

   Optional: to maximize performance, select "Connect to an existing container" in the Lifecycle section of the interpreter.

3. In the same **PHP** section, set the path mapping:

    - Local path: select the magento directory
    - Remote path: `/var/www/html`

4. Go to **PHP > Quality Tools**. For each tool, select the php interpreter that you created.

5. Go to **Editor > Inspections**. In the Quality tools section, enable and configure the following tools (disable the others):

    - PHP_CodeSniffer validation:
        - Uncheck "Installed standard path"
        - Set "Coding standard" to "custom", and use the value `phpcs.xml.dist`
    - PHP Mess Detector validation: nothing to do (except enabling it)
    - PHPStan validation:
        - Set "Configuration file" to `phpstan.neon.dist`
