# Using Docker with Magento

## Setting Up the Project

### Pre-requisites

Pre-requisites:

- git
- curl
- Docker
- Docker Compose V2 (installed as a docker plugin)

How to install Docker:

```
sudo apt-get install docker
sudo groupadd docker
sudo usermod -aG docker $USER
```

How to install [Docker Compose V2](https://docs.docker.com/compose/cli-command/#install-on-linux):

```
DOCKER_CONFIG=${DOCKER_CONFIG:-$HOME/.docker}
mkdir -p $DOCKER_CONFIG/cli-plugins
curl -SL https://github.com/docker/compose/releases/download/v2.4.1/docker-compose-linux-x86_64 -o $DOCKER_CONFIG/cli-plugins/docker-compose
```

Check if it is incorrectly installed:

```
docker compose
```

### Setting up a Magento Project

To setup a new Magento project with this skeleton:

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
