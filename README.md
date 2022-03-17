# Using Docker with Magento

## Setting Up the Project

Pre-requisites:

- git
- curl
- docker, docker-compose
- any bash terminal

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

- **make build**: lists all images.
- **make up**: starts all containers in detached mode.
- **make down**: stops all containers.
- **make ps**: lists containers.
- **make logs**: shows Docker logs (on all containers by default). 
  Example: `make logs service=fpm`

You can also quickly access any container with the following commands:

- **make bash**: opens a bash terminal on any container (cli by default).
  Example: `make bash service=fpm`
- **make db**: connects to the Magento database.

## Running command-line tools

The makefile provides multiple commands that interact with command-line tools:

- **make magento**: runs the Magento CLI.
  Example: `make magento cmd=indexer:reindex`
- **make composer**: runs composer.
  Example: `bin/composer update -d magento`
- **make phpcs**: runs phpcs.
  Example: `make phpcs cmd="--standard=ruleset.xml.dist"`
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
