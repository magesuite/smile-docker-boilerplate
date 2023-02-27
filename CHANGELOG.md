# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0-rc13] - 2023-02-27

- Removed nginx reverse proxy (already managed by traefik).
- Improved readability of compose files (compose.override.yaml file now only contains traefik labels).
- Updated php image (Alpine 3.17 instead of 3.16)
- Updated nginx image (nginx 1.22 instead of 1.21)

## [1.0.0-rc12] - 2023-02-16

- Compatibility with Magento 2.4.6.
- Added a warning about Magento authentication keys to the Magento installation docs.

## [1.0.0-rc11] - 2023-01-12

- Added how to set up multiple websites/stores.
- Added .fleet directory to .gitignore

## [1.0.0-rc10] - 2022-12-14

- Fixed inconsistent behavior of the Makefile target `toggle-cron`.
- Fixed missing files after Magento Cloud project initialization.

## [1.0.0-rc9] - 2022-10-13

- Added [Smile Quality Suite](https://github.com/Smile-SA/magento2-smilelab-quality-suite) (rulesets for phpcs, phpmd, phpstan).

## [1.0.0-rc8] - 2022-09-30

- Added an application user named `www` that uses the host UID/GID.

## [1.0.0-rc7] - 2022-09-29

- Added how to transfer SSH keys to the php container in the documentation.
- Added configuration file in docker/conf/rabbitmq/rabbitmq.conf.
- Use fpm-dev as the base fpm image.
- Upgraded RabbitMQ from 3.8 to 3.9.
- Removed compatibility with Magento 2.4.0 and 2.4.1 (requires composer 1, which is not installed in the fpm-dev image).
- Fixed rabbitmq data being deleted when the container is removed.

## [1.0.0-rc6] - 2022-08-10

- Compatibility with Magento 2.4.5

## [1.0.0-rc5] - 2022-08-03

- Enable debug toolbar in Magento installation script if the module is installed.
- It is now possible to apply composer patches (`patch` package added to the php image).

## [1.0.0-rc4] - 2022-07-05

- Added option to change elasticsearch port in Magento install script.
- Init script does not fail anymore if the templates directory was deleted.

## [1.0.0-rc3] - 2022-06-09

- Cron container is now disabled by default.
- Better smileanalyser output (requires SmileAnalyser >= 8.1).
- Improved the documentation (added docker architecture and deployment sections, moved multiple sections).
- Removed unused port mappings in compose.yaml.
- Removed phpcbf from the Makefile (can still be run with `make vendor-bin`).

## [1.0.0-rc2] - 2022-06-01

- Added configuration file for mariadb (fixes [slow reindexation issue](https://experienceleague.adobe.com/docs/commerce-operations/performance-best-practices/configuration.html#indexers)).
- Upgraded maildev from 1.1.1 to 2.0.5.
- Updated Varnish VCL file.
- Renamed configuration files with ambiguous names (e.g. "default.conf" renamed to "default-dev.conf").
- Fixed PHP file caching issue by setting `opcache.validate_timestamps = On` in the php dev image.

## 1.0.0-rc1 - 2022-05-19

- First release candidate.

[1.0.0-rc13]: https://git.smile.fr/magento2/docker-boilerplate/compare/1.0.0-rc12...1.0.0-rc13
[1.0.0-rc12]: https://git.smile.fr/magento2/docker-boilerplate/compare/1.0.0-rc11...1.0.0-rc12
[1.0.0-rc11]: https://git.smile.fr/magento2/docker-boilerplate/compare/1.0.0-rc10...1.0.0-rc11
[1.0.0-rc10]: https://git.smile.fr/magento2/docker-boilerplate/compare/1.0.0-rc9...1.0.0-rc10
[1.0.0-rc9]: https://git.smile.fr/magento2/docker-boilerplate/compare/1.0.0-rc8...1.0.0-rc9
[1.0.0-rc8]: https://git.smile.fr/magento2/docker-boilerplate/compare/1.0.0-rc7...1.0.0-rc8
[1.0.0-rc7]: https://git.smile.fr/magento2/docker-boilerplate/compare/1.0.0-rc6...1.0.0-rc7
[1.0.0-rc6]: https://git.smile.fr/magento2/docker-boilerplate/compare/1.0.0-rc5...1.0.0-rc6
[1.0.0-rc5]: https://git.smile.fr/magento2/docker-boilerplate/compare/1.0.0-rc4...1.0.0-rc5
[1.0.0-rc4]: https://git.smile.fr/magento2/docker-boilerplate/compare/1.0.0-rc3...1.0.0-rc4
[1.0.0-rc3]: https://git.smile.fr/magento2/docker-boilerplate/compare/1.0.0-rc2...1.0.0-rc3
[1.0.0-rc2]: https://git.smile.fr/magento2/docker-boilerplate/compare/1.0.0-rc1...1.0.0-rc2
