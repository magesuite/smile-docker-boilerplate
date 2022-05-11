# Setting Up the Project

**Important**: First, make sure that you meet all the requirements listed in the [README](../README.md).
Traefik must be [up and running](https://git.smile.fr/docker/traefik#usage).

## Boilerplate Installation

Follow these steps:

1. Go to the directory where you store your PHP projects, and clone this repository:

   ```
   PROJECT_DIR=myproject
   git clone --depth=1 git@git.smile.fr:magento2/docker-boilerplate $PROJECT_DIR && cd "$_" && rm -rf .git
   ```

   *Optional*: If you want to use this boilerplate with an existing Magento installation (e.g. Magento cloud project), copy your Magento files to the "magento" directory:

   ```
   mv ~/path/to/magento/ magento/
   ```

2. Initialize the project with the following command:

   ```
   make init-project
   ```

   This script will:

   - Update .env.dist and .env files (PROJECT_NAME, PHP_VERSION, COMPOSER_VERSION)
   - Run composer create-project (if you did not copy a Magento installation to the "magento" directory)
   - Add smile repositories / modules to composer.json file

   By default, Magento is initialized in a directory named "magento" (cf. $MAGENTO_DIR variable in .env.dist).

3. Install the database with the following command:

   ```
   make install
   ```

   This script will install the database (by running "bin/magento setup:install").

4. Launch containers that were not yet started (cron, web, varnish...):

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
- Elasticsearch REST API: http://elastic.{project_name}.skeleton.docker.localhost
- Rabbitmq admin: http://rabbitmq.{project_name}.docker.localhost (user: "magento", password: "magento")

## Creating Git Repositories

After you have confirmed that Magento is properly installed:

1. Create two git repositories (one for the boilerplate, one for Magento) on https://git.smile.fr.

   For example:

   - https://git.smile.fr/myproject/docker-boilerplate
   - https://git.smile.fr/myproject/magento

2. Update the file docs/01-install.md and update the sample URLs (git repository URLs, docker container URLs).

3. Push the boilerplate and Magento files to these repositories.
   For example:

   ```
   git init && git remote add origin git@git.smile.fr:myproject/docker-boilerplate.git
   git add . && git commit -m "Initial commit" && git push origin master

   cd magento/
   git init && git remote add origin git@git.smile.fr:myproject/magento.git
   git add . && git commit -m "Initial commit" && git push origin master
   ```

You will end up with the following project structure:

```
myproject/
   .git
   magento/
      .git
```
