# Magento Docker Boilerplate

**/!\ This is a work in progress, there is no official release yet.**

## Description

This repository provides a boilerplate that allows to set up a Magento project using Docker Compose.
It is the recommended boilerplate to use for Magento projects.

It is compatible with Magento >= 2.4.2.
For older Magento versions, use the [ansible skeleton](https://git.smile.fr/magento2/architecture-skeleton).

/!\ It has never been tested with Mac/Windows.
Consider yourself a beta tester if you don't use it on Linux.

## Pre-requisites

This skeleton requires the following tools to be installed on your computer:

- git
- curl
- [Docker](https://docs.docker.com/engine/install/)
- [Docker Compose V2](https://docs.docker.com/compose/cli-command/#installing-compose-v2) (installed as a docker plugin)
- [Traefik Proxy](https://git.smile.fr/docker/traefik) (to work on multiple projects at the same time)

You don't need to install PHP or composer on your workstation.

## Installation

### Setting Up a New Project

To set up a **new** Magento project with this skeleton:

1. First, create a new directory that will host your project:

    ```
    git clone --depth=1 git@git.smile.fr:docker/magento/boilerplate myproject \
    && cd "$_" \
    && rm -rf .git
    ```

2. Then, run the following script in this new directory:

    ```
    make install
    ```

    This script will prompt for the project information (project name, Magento edition, version...).
    It will initialize Magento with composer (you don't need to install composer, it runs within a container).

3. Launch all services with the following command:

    ```
    make up
    ```

4. Check if Magento is available at the following URLs:
    - https://{project_name}.docker.localhost
    - https://{project_name}.docker.localhost/admin (user: "admin", password: "magent0")

5. Commit your project:

    ```
    git init
    git remote add origin <your_repo_url>
    git add .
    git commit -m "Initial commit"
    git push origin master
    ```

### Setting up an Existing Project

To set up a project that was already initialized with the boilerplate:

1. Clone the project repository.

2. Then, run the following script in this new directory:

    ```
    make install
    ```

3. Launch all services with the following command:

    ```
    make up
    ```

4. Check if Magento is available at the following URLs:
    - https://{project_name}.docker.localhost
    - https://{project_name}.docker.localhost/admin (user: "admin", password: "magent0")

## Makefile

This boilerplate is bundled with a Makefile that provides multiples that will help you using docker and Magento.

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
