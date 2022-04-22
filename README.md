# Magento Docker Boilerplate

**/!\ This is a work in progress, there is no official release yet.**

## Description

This repository provides a boilerplate that allows to set up Magento projects with Docker Compose.

It is compatible with Magento >= 2.4.0.
For older Magento versions, use the [ansible skeleton](https://git.smile.fr/magento2/architecture-skeleton).

The documentation is not available yet, but this README explains how to set up a project.

## Requirements

### System Requirements

This boilerplate is currently only compatible with Linux.
It requires the following tools to be installed:

- Git
- Bash (with basic utilities, such as curl, grep or sed)
- [Docker](https://docs.docker.com/engine/install/)
- [Docker Compose V2](https://docs.docker.com/compose/cli-command/#installing-compose-v2) (installed as a docker plugin)
- [Traefik Proxy](https://git.smile.fr/docker/traefik) (to work on multiple projects at the same time)

The Traefik proxy is optional, but strongly recommended.

You don't need to install PHP on your workstation.

### Composer Requirements

This boilerplate uses composer to install Magento.
Magento projects have the following requirements:

- Generate a [GitHub token](https://getcomposer.org/doc/articles/authentication-for-private-packages.md#github-oauth) if you don't already have one.
- Get [Magento access keys](https://devdocs.magento.com/guides/v2.4/install-gde/prereq/connect-auth.html).

### Smile Images

This boilerplate uses images hosted on https://registry.smile.fr.

In order to use these images, generate a CLI secret on https://registry.smile.fr (in your user settings), then run the following command:

```
docker login -u <youruser> -p <your_secret> registry.smile.fr
```

## Installation

### Initial Setup

To set up a Magento project with this boilerplate:

1. Clone the boilerplate files in a directory:

    ```
    git clone --depth=1 git@git.smile.fr:docker/magento/boilerplate myproject \
    && cd "$_" \
    && rm -rf .git
    ```

    If you want to use this boilerplate with an existing Magento installation (e.g. Magento cloud), copy your Magento files to the "magento" directory:

    ```
    mv ~/path/to/magento magento
    ```

2. Run the following script in this new directory:

    ```
    make setup-project
    ```

    The script will behave differently depending on whether Magento files were found:

    - No Magento files found: the script will prompt you for the project information (project name, Magento files location, version, edition...), then initialize Magento with composer.
    - Magento files found: the script will update the docker env files, and check if there is anything to add in composer.json (e.g. Smile modules or repositories).

    By default, the script searches for the Magento files in the folder "magento".
    The script allows you to change this location.
    If you want to install Magento in the root directory, when the script prompts you for the folder location, choose "./".

3. Launch all containers:

    ```
    make up
    ```
   
   Then, make sure that they are running and healthy with the following command:

   ```
   make ps
   ```
   
   If some containers are still starting, wait a bit until they are all running before proceeding to the next step.

4. Install the database:

    ```
    make setup-install
    ```

5. Check if Magento is available at the following URLs:
    - https://{project_name}.docker.localhost
    - https://{project_name}.docker.localhost/admin (user: "admin", password: "magent0")

6. Commit your project.
   We recommend storing docker and Magento files in two separate repositories (e.g. with a git submodule).

   For example:

   ```
   cd magento/
   git init
   git remote add origin git@git.smile.fr:myproject/magento.git
   git add .
   git commit -m "Initial commit"
   git push origin master

   cd ..
   git init
   git remote add origin git@git.smile.fr:myproject/docker.git
   git submodule add ./magento/ magento/
   git add .
   git commit -m "Initial commit"
   git push origin master
   ```

### Installing an Existing Boilerplate

1. Clone the project repository. If it was set up with git submodules, use `git clone --recurse-submodules`.

2. Initialize the vendor directory with the following command:

    ```
    make composer-install
    ```

    It might ask you to provide a composer GitHub token.

3. Launch all containers:

    ```
    make up
    ```
   
   Then, make sure that they are running and healthy with the following command:

   ```
   make ps
   ```
   
   If some containers are still starting, wait a bit until they are all running before proceeding to the next step.

4. Check if Magento is available at the following URLs:
    - https://{project_name}.docker.localhost
    - https://{project_name}.docker.localhost/admin (user: "admin", password: "magent0")

## Makefile

This boilerplate is bundled with a Makefile that provides multiple commands that will help you use docker and Magento.

The list of available commands can be listed by running `make` at the root of your project.

Some commands accept arguments.
For example, `make sh` will open a shell to the php cli container, and `make sh service=fpm` will open a shell on the php fpm container.

### Docker

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

### Command-line tools

The makefile provides multiple commands that interact with command-line tools:

- **make magento**: runs the Magento CLI.
  Example: `make magento cmd=indexer:reindex`
- **make composer**: runs composer.
  Example: `bin/composer cmd=update`
- **make phpcs**: runs phpcs.
- **make phpmd**: runs phpmd.
- **make phpunit**: runs phpunit.
- **make phpstan**: runs phpstan.
- **make php-cs-fixer**: runs php-cs-fixer.
  Example: `make php-cs-fixer cmd="fix --config=.php-cs-fixer.dist.php"`

## Kubernetes Integration

Work in progress.
