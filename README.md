# Using Docker with Magento

## Description

This repository provides a skeleton that allows to set up a Magento project using Docker Compose.
It is the recommended skeleton to use for Smile projects.

It is compatible with Magento >= 2.4.2.
For older Magento versions, use the [ansible skeleton](https://git.smile.fr/magento2/architecture-skeleton).

/!\ It has never been tested with Mac/Windows.
Consider yourself a beta tester if you don't use it on Linux.

## Pre-requisites

This skeleton requires the following tools to be installed on your computer:

- git
- curl
- Docker
- [Docker Compose V2](https://docs.docker.com/compose/cli-command/#install-on-linux) (installed as a docker plugin)
- Optional: [Traefik Proxy](https://git.smile.fr/docker/traefik) (to work on multiple projects at the same time)

To install Docker (Linux):

```
sudo apt-get install docker
sudo groupadd docker
sudo usermod -aG docker $USER
```

To install Docker Compose V2 (Linux):

```
DOCKER_CONFIG=${DOCKER_CONFIG:-$HOME/.docker}
mkdir -p $DOCKER_CONFIG/cli-plugins
curl -SL https://github.com/docker/compose/releases/download/v2.4.1/docker-compose-linux-x86_64 -o $DOCKER_CONFIG/cli-plugins/docker-compose
chmod +x $DOCKER_CONFIG/cli-plugins/docker-compose
```

To install Traefik, check the [README](https://git.smile.fr/docker/traefik/-/blob/master/README.md) on the gitlab repository.

## Setting Up the Project

To set up a new Magento project with this skeleton:

1. First, create a new directory that will host your project:
    ```
    mkdir ~/projects/my-magento-project && cd $_
    ```
2. Then, run the following script in this new directory:
    ```
    bash <(git archive --remote=git@git.smile.fr:guvra/magento-docker HEAD setup | tar -xO)
    ```
    This script will prompt for the project information (Magento edition, version...).
    It will create the following structure:
    ```
    my-magento-project/
        bin/
            ... (useful scripts)
        env/
            ... (env files used by docker)
        src/
            ... (magento files)
        docker-compose.override.yml
        docker-compose.yml
        Makefile
    ```
3. Commit your project:
    ```
    git init
    git remote add origin <your_repo_url>
    git add .
    git commit -m "Initial commit"
    git push origin master
    ```

The script will automatically fetch the Magento authentication tokens from your composer auth file.
However, if they are not defined, you will have to specify them during the script execution.

## Installing Magento

To initialize the Magento database, run the following scripts at the root of the project:

```
./bin/install-magento
```

The first script runs the create-project command, the second script installs the magento database.

TODO: decide how to customize parameters (e.g. project URL). Possible implementation:

- Using environment vars (e.g. $PROJECT_URL)
- Using command-line options (e.g. --project-url=...)

## Interacting with the containers

The makefile provides multiple commands that interact with containers:

- **make up**: starts all containers in detached mode.
- **make down**: stops all containers.
- **make ps**: lists containers.
- **make images**: lists images.
- **make logs**: shows Docker logs (on all containers by default).
  Example: `make logs service=fpm`
- **make top**: shows running processes (on all containers by default).
  Example: `make top service=fpm`
- **make build**: build images (useful only if you use custom images)

You can also quickly access any container with the following commands:

- **make sh**: opens a bash terminal on any container (php cli by default).
  Example: `make sh service=fpm`
- **make db**: connects to the Magento database.

## Running command-line tools

The makefile provides multiple commands that interact with command-line tools:

- **make magento**: runs the Magento CLI.
  Example: `make magento cmd=indexer:reindex`
- **make composer**: runs composer.
  Example: `bin/composer cmd=update`
- **make phpcs**: runs phpcs.
- **make phpmd**: runs phpmd.
  Example: `make phpmd cmd="app/code xml phpmd.xml"`
- **make phpunit**: runs phpunit.
- **make phpstan**: runs phpstan.
- **make php-cs-fixer**: runs php-cs-fixer.
  Example: `make php-cs-fixer cmd="fix --config=.php-cs-fixer.dist.php"`

## Kubernetes Integration

TODO

## Script Automation

The initialization script provides command-line options that allow to automate a project creation.

You can get the list of these options by running the following command:

```
bash <(git archive --remote=git@git.smile.fr:guvra/magento-docker HEAD setup | tar -xO) --help
```

Example usage:

```
bash <(git archive --remote=git@git.smile.fr:guvra/magento-docker HEAD setup | tar -xO) my-project --magento-edition enterprise --no-interaction
```
