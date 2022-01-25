# Using Docker with Magento

## Setting Up the Project

Pre-requisites:

- git, curl
- docker, docker-compose
- any bash terminal

1. First, create a new directory that will host your project:
    ```
    mkdir ~/projects/my-magento-project && cd $_
    ```
2. Then, run the following script in this new directory:
    ```
    bash <(curl -sL https://git.smile.fr/guvra/magento-docker/raw/master/setup)
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
./bin/setup-magento
./bin/install-magento
```

The first script runs the create-project command, the second script installs the magento database.

TODO: decide how to customize parameters (e.g. project URL). Possible implementation:

- Using environment vars (e.g. $PROJECT_URL)
- Using command-line options (e.g. --project-url=...)

## Starting/stopping the containers

To start or stop the containers, you can use the Makefile:

```
# Starts the containers
make docker-start

# Stops the containers
make docker-stop
```

## Running the Magento CLI

The directory "bin" contains several scripts that allow to run CLI commands:

- **bin/cli**: runs a generic CLI command. Example: `bin/cli ls -l`
- **bin/magento**: runs the Magento CLI. Example: `bin/magento setup:di:compile`
- **bin/composer**: runs composer. Example: `bin/composer update -d magento`
- **bin/db**: connects to the database.
- **bin/install-magento**: initializes the Magento database.
- **bin/set-permissions**: fixes file/folder permissions.

## Kubernetes Integration

TODO

## Script Automation

The initialization script provides command-line options that allow to automate a project creation.

You can get the list of these options by running the following command:

```
bash <(curl -sL https://git.smile.fr/guvra/magento-docker/raw/master/setup) --help
```

Example usage:

```
bash <(curl -sL https://git.smile.fr/guvra/magento-docker/raw/master/setup) my-project --magento-edition enterprise --no-interaction
```
