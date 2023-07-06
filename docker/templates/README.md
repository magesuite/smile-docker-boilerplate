# Magento - Docker Development Environment

## Description

This repository is the development environment of the {{ project_name }} project.
It uses docker compose.

It was initialized with the [Magento docker boilerplate](https://git.smile.fr/magento2/docker-boilerplate).

## Requirements

### System Requirements

The following tools must be installed on your system:

- Git
- [Docker Compose V2](https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository) (don't forget to apply the [post-installation steps for Linux](https://docs.docker.com/engine/install/linux-postinstall/))
- [Traefik Proxy](https://git.smile.fr/docker/traefik)

Warning: if most of your available disk space is dedicated to the HOME partition, you will need to move the /var/lib/docker directory to /home/docker (cf. [how to move docker data directory](https://www.guguweb.com/2019/02/07/how-to-move-docker-data-directory-to-another-location-on-ubuntu/)).

### Smile Images

This repository uses container images hosted on the Smile image registry.
In order to use these images, generate a CLI secret on https://registry.smile.fr (in your user settings), then run the following command:

```
docker login -u <youruser> -p <your_secret> registry.smile.fr
```

### Composer Authentication Keys

During the installation of Magento, you will be prompted for authentication keys.
You can find them on [bitwarden](https://vault.galaxy.intranet/).

## Installation

First, make sure that the Traefik proxy is [up and running](https://git.smile.fr/docker/traefik#usage).

Then, follow these steps:

1. Go to the directory where you store your PHP projects, and clone the project repositories:

   ```
   git clone git@git.smile.fr:{{ project_name }}/docker-magento.git {{ project_name }} && cd "$_" && git clone git@git.smile.fr:{{ project_name }}/{{ project_name }}-magento.git
   ```

2. Run the following command:

   ```
   make install
   ```

   This command will initialize the vendor directory and install Magento.
   You will have to provide the composer authentication keys of the project during the command execution.

3. Launch containers that were not yet started:

   ```
   make up
   ```

Run the command `make ps` to check if all containers are up and running.
If a container failed to start, please refer to the [troubleshooting section](https://git.smile.fr/magento2/docker-boilerplate/-/wikis/Working-With-Docker-Compose#troubleshooting).

Magento is available at the following URLs:

- Magento frontend: https://{{ project_name }}.docker.localhost
- Magento admin: https://{{ project_name }}.docker.localhost/admin (user: "admin", password: "magent0")

There are other services available at the following URLs:

- Maildev interface: http://maildev.{{ project_name }}.docker.localhost (this is where mails will be sent)
- Opensearch REST API: http://opensearch.{{ project_name }}.docker.localhost
- Rabbitmq admin: http://rabbitmq.{{ project_name }}.docker.localhost (user: "magento", password: "magento")

## Documentation

The documentation of the docker boilerplate is available [here](https://git.smile.fr/magento2/docker-boilerplate/-/wikis/home).

In this documentation, the user guide explains how to use the Makefile and how to customize your docker installation (e.g. how to set up multiple stores).

## Resources

We encourage you to read the following resources:

- [Magento Best Practices](https://wiki.smile.fr/wiki/Best_Practices_(Magento))
- [Magento Performance Tuning](https://wiki.smile.fr/wiki/Performance_Tuning_(Magento))
