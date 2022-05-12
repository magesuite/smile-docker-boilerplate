# Installation

**Important**: make sure that you meet all the requirements listed in the [README](../README.md).
Traefik must be [up and running](https://git.smile.fr/docker/traefik#usage).

## Installing Magento

Follow these steps:

1. Go to the directory where you store your PHP projects, and clone the project repositories:

   ```
   git clone git@git.smile.fr:{project_name}/docker-boilerplate.git {project_name} && cd "$_" && git clone git@git.smile.fr:{project_name}/magento.git
   ```

2. Install Magento:

   ```
   make install
   ```

   This script will run "composer install" and install the database (by running "bin/magento setup:install").

3. Launch containers that were not yet started (cron, web, varnish...):

   ```
   make up
   ```

Run the command `make ps` to check if all containers are up and healthy.

## Accessing Magento

Magento is available at the following URLs:

- Magento frontend: https://{project_name}.docker.localhost
- Magento admin: https://{project_name}.docker.localhost/admin (user: "admin", password: "magent0")

There are other services available at the following URLs:

- Maildev interface: http://maildev.{project_name}.docker.localhost (this is where mails will be sent)
- Elasticsearch REST API: http://elastic.{project_name}.docker.localhost
- Rabbitmq admin: http://rabbitmq.{project_name}.docker.localhost (user: "magento", password: "magento")
