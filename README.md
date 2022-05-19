# Magento Docker Boilerplate

**/!\ This is a work in progress, there is no official release yet.**

## Description

This repository provides a boilerplate that allows to set up Magento projects with Docker Compose.

It is compatible with Magento >= 2.4.0.
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

- Generate a [GitHub token](https://getcomposer.org/doc/articles/authentication-for-private-packages.md#github-oauth) if you don't already have one.
- Get [Magento access keys](https://devdocs.magento.com/guides/v2.4/install-gde/prereq/connect-auth.html).

### Smile Images

This boilerplate uses container images hosted on the Smile image registry.

In order to use these images, generate a CLI secret on https://registry.smile.fr (in your user settings), then run the following command:

```
docker login -u <youruser> -p <your_secret> registry.smile.fr
```

## Documentation

- [Installation](docs/01-install.md)
- [How to Use the Makefile](docs/02-makefile.md)
- [Working with the Database](docs/03-database.md)
- [How to use Xdebug](docs/04-xdebug.md)
- [Customizing Containers](docs/05-config.md)
- [Troubleshooting](docs/06-troubleshooting.md)

## Links

We encourage you to read the following resources:

- [Magento best practices](https://wiki.galaxy.intranet/wiki/Best_Practices_(Magento))
- [Magento performance tuning](https://wiki.galaxy.intranet/wiki/Performance_Tuning_(Magento))
- [Installing Magepack](https://wiki.galaxy.intranet/wiki/Magepack) (recommended if you extend the luma or blank themes)
