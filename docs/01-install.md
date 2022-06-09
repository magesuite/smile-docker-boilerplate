# Setting Up the Project

**Important, please read this**:

- Make sure that you meet all the requirements listed in the [README](../README.md#requirements).
  Traefik must be [up and running](https://git.smile.fr/docker/traefik#usage).
- Before initializing a Magento cloud project, you must request a Smile packagist account (https://packagist.smile.fr) to dirtech@smile.fr.
  This is necessary, otherwise Magento cloud won't be able to install Smile modules.

## Installation

Open a terminal and apply the following steps:

1. Go to the directory where you store your Magento projects:

   ```
   cd ~/path/to/projects
   ```

2. Set the project name in a variable named "PROJECT_NAME" (will be reused in future commands):

   ```
   PROJECT_NAME=xxxx
   ```

   **The project name must only contain the following characters**: lowercase letters (`a-z`), numbers (`0-9`) and hyphens (`-`).

3. Clone the boilerplate repository:

   ```
   git clone -q -c advice.detachedHead=false --depth 1 --branch latest git@git.smile.fr:magento2/docker-boilerplate "$PROJECT_NAME" && cd $_ && rm -rf .git
   ```

4. The next step will depend on what you need to do:

   - [Creating a **new Magento project** with the boilerplate.](#user-content-creating-a-new-magento-project-with-the-boilerplate)
   - [Setting up the boilerplate with an **existing Magento codebase**.](#setting-up-the-boilerplate-with-an-existing-magento-codebase)

### Creating a new Magento project with the boilerplate

This section will show you how to initialize a new Magento project with the boilerplate.

Follow the steps below:

1. Run the following command (**don't blindly copy it, make sure to set the version and edition that you need**):

   ```
   make init-project PROJECT="$PROJECT_NAME" VERSION=2.4.4 EDITION=community
   ```

   This script will update the docker env files and run "composer create-project".
   The Magento project is created in the "magento" directory.

   The "EDITION" variable must be one of "community", "enterprise" or "cloud".
   The full list of parameters handled by this script is [documented here](../docker/bin/setup#L6).

2. *Cloud projects only*: in magento/composer.json, check if the following entry exists:

   ```json
   "autoload-dev": {
       "psr-4": {
           "Magento\\PhpStan\\": "dev/tests/static/framework/Magento/PhpStan/"
       }
   }
   ```

   If it doesn't exist, add it, and run `make composer c=update`.

3. Run the following command to install the Magento database:

   ```
   make install
   ```

   If you get the following error: "Could not connect to the Amqp Server", just run the command again.

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
   make init-project PROJECT="$PROJECT_NAME" VERSION=2.4.4
   ```

   This script will update the docker env files, and check if anything needs to be added to composer.json (Smile modules, Smile packagist repositories...).

   The full list of parameters handled by this script is [documented here](../docker/bin/setup#L6).

3. *Optional:* if you need to import a database dump file, run the following command:
   `make db-import filename=/path/to/dump.sql`

4. Run the following command to install Magento:

   ```
   make install
   ```

   It will install and configure Magento by running setup:install (as well as several other commands, such as deploy:mode:set).

   If you get the following error: "Could not connect to the Amqp Server", just run the command again.

5. If you already had a .gitlab-ci.yml file in your Magento codebase, you might want to update it with the contents of [docker/templates/magento/.gitlab-ci.yml](../docker/templates/magento/.gitlab-ci.yml)
   (you will have to manually replace "{php_ci_version}" with a valid php version, e.g. "81"). 
   Same with the [.gitignore](../docker/templates/magento/.gitignore) file.

Magento is now installed.
You can move to the next step: [checking if the Magento store is available](#accessing-the-magento-store).

## Accessing the Magento Store

1. First, execute the following command to launch the containers that were not yet started:

   ```
   make up
   ```

2. Run the command `make ps` to make sure that no container failed to start.
   If a container failed to start, please refer to [the troubleshooting section](03-docker-compose.md#troubleshooting).

3. Magento is available at the following URLs (replace "myproject" with your project name):

   - Magento frontend: https://myproject.docker.localhost
   - Magento admin: https://myproject.docker.localhost/admin (user: "admin", password: "magent0")

   There are other services available at the following URLs (replace "myproject" with your project name):

   - Maildev interface: http://maildev.myproject.docker.localhost (this is where mails will be sent)
   - Elasticsearch REST API: http://elastic.myproject.docker.localhost
   - Rabbitmq admin: http://rabbitmq.myproject.docker.localhost (user: "magento", password: "magento")

If the Magento store is available, you can move to the final step: [pushing the files to git](#initializing-the-repositories).

## Initializing the Repositories

### Creating the Repositories

1. Go to https://git.smile.fr/groups/new and create a new git group with the name of your project (if it doesn't already exist).

2. Go to https://git.smile.fr/projects/new and create two repositories:

   - One for the boilerplate. Example name: "docker-boilerplate".
   - One for Magento files (if it doesn't already exist). Example name: "magento".

3. Update the file "docs/01-install.md" and update the sample git URLs.
   Don't forget to regularly update this file when necessary (e.g. adding a step to recommend running `make reconfigure env=dev` if your project uses the Smile reconfigure module).

4. Push the boilerplate and Magento files to these repositories.
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

### Configuring the Repositories

In Settings > General > Merge Requests:

- Enable fast-forward merge.
- Enable "Pipelines must succeed" option.
- Enable "All discussions must be resolved" option.

In Settings > CI/CD, add a variable named "COMPOSER_AUTH":

```
{
    "http-basic": {
        "repo.magento.com": {
            "username": "xxxxxxxxxxxx",
            "password": "yyyyyyyyyyyy"
        }
    }
}
```

If you initialized a Magento cloud project, this variable must also contain the access keys to packagist.smile.fr.
