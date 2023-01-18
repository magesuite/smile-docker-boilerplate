# Magento Docker Boilerplate

## Description

This repository provides a boilerplate that allows to set up Magento projects with Docker Compose.

It is compatible with Magento >= 2.4.2.
For older Magento versions, use the [ansible skeleton](https://git.smile.fr/magento2/architecture-skeleton).

## Requirements

**This section is important, you must meet all the requirements listed below.**

### System Requirements

This boilerplate is currently only compatible with Linux.
The following tools **must** be installed on your system:

- Git
- [Docker Compose V2](https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository) (don't forget to apply the [post-installation steps for Linux](https://docs.docker.com/engine/install/linux-postinstall/))
- [Traefik Proxy](https://git.smile.fr/docker/traefik)

To check if Docker Compose V2 is installed on your system, run the following command: `docker compose version`.

Warning: if most of your available disk space is dedicated to the HOME partition, you will need to move the /var/lib/docker directory to /home/docker (cf. [how to move docker data directory](https://www.guguweb.com/2019/02/07/how-to-move-docker-data-directory-to-another-location-on-ubuntu/)).

### Composer Requirements

This boilerplate uses composer to install Magento.
Magento projects have the following requirements:

- Generate a [GitHub token](https://getcomposer.org/doc/articles/authentication-for-private-packages.md#github-oauth) if you don't already have one (no scope required).
- Get [Magento access keys](https://experienceleague.adobe.com/docs/commerce-operations/installation-guide/prerequisites/authentication-keys.html).

### Smile Images

This boilerplate uses container images hosted on the Smile image registry.

In order to use these images, generate a CLI secret on https://registry.smile.fr (in your user settings), then run the following command:

```
docker login -u <youruser> -p <your_secret> registry.smile.fr
```

## Documentation

- [Installation](docs/01-install.md)
- [Architecture](docs/02-architecture.md)
- [Working with Docker](docs/03-docker-compose.md)
- [Working with Magento](docs/04-magento.md)
- [Working with the Database](docs/05-database.md)
- [Code Quality](docs/06-code-quality.md)
- [How to use Xdebug](docs/07-xdebug.md)
- [Deployment](docs/08-deployment.md)
- [PhpStorm Configuration](docs/09-phpstorm.md) (optional)

## How to Update an Already Installed Boilerplate?

You can update an existing docker boilerplate by applying the following process:

1. Download the latest release:
   https://git.smile.fr/magento2/docker-boilerplate/-/archive/latest/docker-boilerplate-latest.tar.gz
2. At the root of your project:
    - Remove the current boilerplate files: `rm -rf docker docs .env`
    - Extract the archive: `tar -xf ~/Downloads/docker-boilerplate-latest.tar.gz --strip-components=1`
3. Use a git diff tool to reapply your project modifications to the updated files.
   Don't forget to set the project name in ".env.dist", and to restore the file "docs/01-install.md".
4. Rebuild the images: `make build`
5. *[Optional]*: run `make init-project version=xxx` (where "xxx" is your current version of Magento).
   This command will update some files and packages in the Magento installation (e.g. gitlab-ci.yml).
   **Warning**: Running this command will update your phpcs/phpstan rulesets.
6. Review and commit the changes.
   If you ran the step 5, you will also need to review and commit the changes made to the Magento directory.

## Links

We encourage you to read the following resources:

- [How to Start a Magento Project](https://wiki.smile.fr/wiki/How_to_start_a_Magento_project)
- [Magento Best Practices](https://wiki.smile.fr/wiki/Best_Practices_(Magento))
- [Magento Performance Tuning](https://wiki.smile.fr/wiki/Performance_Tuning_(Magento))
- [Installing Magepack](https://wiki.smile.fr/wiki/Magepack) (recommended if you extend the luma or blank themes)
