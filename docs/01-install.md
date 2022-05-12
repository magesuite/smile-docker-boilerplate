# Setting Up the Project

**Important**: make sure that you meet all the requirements listed in the [README](../README.md#requirements).
Traefik must be [up and running](https://git.smile.fr/docker/traefik#usage).

## Installation

1. First, Go to the directory where you store your Magento projects:

   ```
   cd ~/path/to/projects
   ```

2. Clone this repository (**make sure to change the value of the PROJECT_NAME variable**):

   ```
   PROJECT_NAME=myproject
   git clone --depth=1 git@git.smile.fr:magento2/docker-boilerplate $PROJECT_NAME && cd "$_" && rm -rf .git
   ```

The project name must only use the following characters:

- lowercase letters (`a-z`)
- numbers (`0-9`)
- hyphens (`-`)

3. The next step will depend on what you need to do:

   - [Creating a new Magento project with the boilerplate (**community** or **enterprise**).](#user-content-creating-a-new-magento-project-with-the-boilerplate-community-or-enterprise)
   - [Creating a new Magento **cloud** project with the boilerplate.](#creating-a-new-magento-cloud-project-with-the-boilerplate)
   - [Setting up the boilerplate with an **existing Magento codebase**.](#setting-up-the-boilerplate-with-an-existing-magento-codebase)

### Creating a new Magento project with the boilerplate (community or enterprise)

This section will show you how to initialize a new Magento community/enterprise project with the boilerplate.

Follow the steps below:

1. Run the following command (**don't blindly copy it, make sure to set the version and edition that you need**):

   ```
   make init-project PROJECT=$PROJECT_NAME VERSION=2.4.4 EDITION=community
   ```

   This script will create the Magento files in ./magento.

   The "EDITION" variable can be either `community` or `enterprise`.
   The full list of parameters handled by this script is [documented here](../docker/bin/setup#L6).

2. Install the Magento database with the following command:

   ```
   make install
   ```

Magento is now installed.
You can move to the next step: [checking if the Magento store is available](#accessing-the-magento-store).

### Creating a new Magento cloud project with the boilerplate

This section will show you how to initialize a new Magento cloud project with the boilerplate.

1. Make sure that you meet the following requirements:

   - Adobe has given you access to a repository that contains the Magento cloud files.
   - You must request a Smile packagist account (https://packagist.smile.fr) to dirtech@smile.fr.
     This is necessary, otherwise Magento cloud won't be able to install Smile modules.

2. Move the Magento cloud files (from the repository that Adobe provided) to the directory "magento":

   ```
   mv ~/path/to/magento/ ./magento/
   ```

   You now have the following file structure:

   ```
   myproject/
      magento/
         <Magento cloud files here, including composer.json>
   ```

3. Run the following command (**don't blindly copy it, the version must match your composer.json file**):

   ```
   make init-project PROJECT=$PROJECT_NAME VERSION=2.4.4
   ```

   This script will update the docker env files, and check if anything needs to be added to composer.json (Smile modules, Smile packagist repositories...).

   The full list of parameters handled by this script is [documented here](../docker/bin/setup#L6).

4. Install the Magento database with the following command:

   ```
   make install
   ```

Magento is now installed.
You can move to the next step: [checking if the Magento store is available](#accessing-the-magento-store).

### Setting up the boilerplate with an existing Magento codebase

This section will show you how to use this boilerplate with existing Magento sources.

1. Move your Magento codebase to the directory "magento":

   ```
   mv ~/path/to/magento/ magento/
   ```

   You now have the following file structure:

   ```
   myproject/
      magento/
         <Magento files here, including composer.json>
   ```

2. Run the following command (**don't blindly copy it, the version must match your composer.json file**):

   ```
   make init-project PROJECT=$PROJECT_NAME VERSION=2.4.4
   ```

   This script will update the docker env files, and check if anything needs to be added to composer.json (Smile modules, Smile packagist repositories...).

   The full list of parameters handled by this script is [documented here](../docker/bin/setup#L6).

3. Install the Magento database with the following command:

   ```
   make install
   ```

4. If you already had a .gitlab-ci.yml file in your Magento codebase, you might want to update it with the contents of [docker/templates/magento/.gitlab-ci.yml](../docker/templates/magento/.gitlab-ci.yml)
   (you will have to manually replace "{php_ci_version}" with a valid php version, e.g. "81"). 
   Same with the [.gitignore](../docker/templates/magento/.gitignore) file.

Magento is now installed.
You can move to the next step: [checking if the Magento store is available](#accessing-the-magento-store).

## Accessing the Magento Store

First, execute the following command to launch the containers that were not yet started (cron, web, varnish...):

```
make up
```

Then, run the command `make ps` to make sure that no container failed to start.

Magento is available at the following URLs (replace "myproject" with your project name):

- Magento frontend: https://myproject.docker.localhost
- Magento admin: https://myproject.docker.localhost/admin (user: "admin", password: "magent0")

There are other services available at the following URLs (replace "myproject" with your project name):

- Maildev interface: http://maildev.myproject.docker.localhost (this is where mails will be sent)
- Elasticsearch REST API: http://elastic.myproject.docker.localhost
- Rabbitmq admin: http://rabbitmq.myproject.docker.localhost (user: "magento", password: "magento")

If the Magento store is available, you can move to the final step: [creating Git repositories](#creating-git-repositories).

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

Alternatively, you could use a [git submodule](https://git-scm.com/book/en/v2/Git-Tools-Submodules), but that is quite complex to use on a day-to-day basis.

After you have pushed your code to both repositories, your project is now successfully initialized.

## Troubleshooting

### Docker

If you experience any issue with the docker containers:

- Make sure that Traefik is [up and running](https://git.smile.fr/docker/traefik#usage).
- Check if the .env file exists.
- In the .env file:
    - Check if that PROJECT_NAME is defined.
    - Check if DOCKER_UID and DOCKER_GID match the output of `id -u` and `id -g`.
    - Check if PHP_VERSION and COMPOSER_VERSION match the requirements of your project.

If a container is failing, you can check the startup logs by running `docker compose run --rm <container_name>` (e.g. "web").

### GitLab CI

If you are using Magento < 2.4.2, the gitlab runner will probably fail.
This is because the gitlab runner only has composer 2 available, but older versions of Magento require composer 1.

To fix the issue, in magento/.gitlab-ci.yml, change:

```
before_script:
    - composer install
```

To:

```
before_script:
    - curl -sS https://getcomposer.org/installer | php -- --1
    - ./composer.phar install
```
