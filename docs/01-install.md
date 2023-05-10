# Setting Up the Project

**Important, please read this**:

- Make sure that you meet all the requirements listed in the [README](../README.md#requirements).
  Traefik must be [up and running](https://git.smile.fr/docker/traefik#usage).
- Before initializing a Magento cloud project, you must request a Smile packagist account (https://packagist.smile.fr) to dirtech@smile.fr.
  This is necessary, otherwise Magento cloud won't be able to install Smile modules.

## 1. Creating the Project Directory

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

You have successfully initialized your project directory, which contains the docker files.
The next step is to set up Magento.

## 2. Installing Magento

This step differs depending on whether you need to create a new Magento project from scratch, or move an existing project to the docker boilerplate.

### Creating a new Magento Project

Follow these steps if you need to create a new Magento project from scratch:

1. Run the following command (**don't blindly copy it, make sure to set the version and edition that you need**):

   ```
   make init-project PROJECT="$PROJECT_NAME" VERSION=2.4.6 EDITION=community
   ```

   This script will update the docker env files and initialize a Magento project in a subdirectory named "magento".

   The value of the "EDITION" variable must be one of "community", "enterprise" or "cloud".
   The full list of parameters handled by this script is [documented here](../docker/bin/setup#L6).

   During the script execution, you will be prompted for Magento authentication keys.
   Username is the Magento public key, password is the Magento private key.

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
You can move to the next step: [checking if the Magento store is available](#3-accessing-the-magento-store).

### Setting up the boilerplate with an existing Magento Codebase

Follow these steps if you need to move an existing Magento project to the boilerplate:

1. Move your Magento codebase to the subdirectory "magento":

   ```
   mv ~/path/to/magento/ magento/
   ```

   You now have the following file structure:

   ```
   myproject/
      docker/
      docs/
      magento/
         <Magento files here, including composer.json>
   ```

2. Run the following command (**don't blindly copy it, the version must match your composer.json file**):

   ```
   make init-project PROJECT="$PROJECT_NAME" VERSION=2.4.6
   ```

   This script will update the docker env files, and check if anything needs to be added to composer.json (Smile modules, Smile packagist repositories...).
   The full list of parameters handled by this script is [documented here](../docker/bin/setup#L6).

   During the script execution, you will be prompted for Magento authentication keys.
   Username is the Magento public key, password is the Magento private key.

3. *Optional:* if you need to import a database dump file, run the following command:
   `make db-import filename=/path/to/dump.sql`

4. Run the following command to install Magento:

   ```
   make install
   ```

   It will install Magento (or reconfigure it if a dump was imported) by running setup:install (as well as several other commands, such as deploy:mode:set).

   If you get the following error: "Could not connect to the Amqp Server", just run the command again.

5. The files located in the directory "docker/templates/magento" were automatically moved to the Magento subdirectory (.gitignore, .gitlab-ci.yml and code analysis config files).
   You must check if the contents of these files need to be updated.
   For example, you might need to add a missing location in .gitignore, or change the coding standard used in phpcs.xml.dist. By default, the coding standard used is [SmileLab](https://github.com/Smile-SA/magento2-smilelab-phpcs).

Magento is now installed.
You can move to the next step: [checking if the Magento store is available](#3-accessing-the-magento-store).

## 3. Accessing the Magento Store

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

If the Magento store is available, you can now initialize the git repositories.

## 4. Initializing the Repositories

### Creating the Repositories

1. Go to https://git.smile.fr/groups/new and create a new git group with the name of your project (if it doesn't already exist).

2. Go to https://git.smile.fr/projects/new and create two repositories:

   - One for the boilerplate. Example name: "docker-magento".
   - One for Magento files (if it doesn't already exist). Example name: "myproject-magento".

3. Update the file "docs/01-install.md" and update the sample git URLs.
   Don't forget to regularly update this file when necessary (e.g. adding a step to recommend running `make reconfigure env=dev` if your project uses the Smile reconfigure module).

4. Push the boilerplate and Magento files to these repositories.
   For example:

   ```
   git init && git remote add origin git@git.smile.fr:myproject/docker-magento.git
   git add . && git commit -m "Initial commit" && git push origin master

   cd magento/
   git init && git remote add origin git@git.smile.fr:myproject/myproject-magento.git
   git add . && git commit -m "Initial commit" && git push origin master
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

## 5. Updating the Installation Documentation

You are encouraged to regularly update the file docs/01-install.md.

For example, in a lot of projects, the installation procedure is usually the following:

1. Getting composer authentication keys from Bitwarden.
2. Downloading and importing a database dump.
3. Running the `make install` command to create the env.php file.
4. Running smilereconfigure with the `dev` environment.

## 6. Disabling 2FA

The admin area of Magento requires a 2FA authentication.
Magento doesn't provide any way to disable it.

If you want to bypass 2FA on a development environment, you can run the following commands:

```php
make composer c="require --dev markshust/magento2-module-disabletwofactorauth"
make magento c="module:enable MarkShust_DisableTwoFactorAuth"
```

It will install a module that disables 2FA on development environments.
