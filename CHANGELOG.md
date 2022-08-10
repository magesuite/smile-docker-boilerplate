# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Unreleased

### Added

- Compatibility with Magento 2.4.5

## [1.0.0-rc5] - 2022-08-03

### Added

- Enable debug toolbar in Magento installation script if the module is installed.

### Fixed

- It is now possible to apply composer patches (`patch` package added to the php image).

## [1.0.0-rc4] - 2022-07-05

### Added

- Add option to change elasticsearch port in Magento install script.

### Fixed

- Init script does not fail anymore if the templates directory was deleted.

## [1.0.0-rc3] - 2022-06-09

### Changed

- Cron container is now disabled by default.
- Better smileanalyser output (requires SmileAnalyser >= 8.1).
- Improve the documentation (added docker architecture and deployment sections, moved multiple sections).

### Removed

- Remove unused port mappings in compose.yaml.
- Remove phpcbf from the Makefile (can still be run with `make vendor-bin`).

## [1.0.0-rc2] - 2022-06-01

### Added

- Add configuration file for mariadb (fixes [slow reindexation issue](https://experienceleague.adobe.com/docs/commerce-operations/performance-best-practices/configuration.html#indexers)).

### Changed

- Upgrade maildev from 1.1.1 to 2.0.5.
- Update Varnish VCL file.
- Rename configuration files with ambiguous names (e.g. "default.conf" renamed to "default-dev.conf").

### Fixed

- Fix PHP file caching issue by setting `opcache.validate_timestamps = On` in the php dev image.

## 1.0.0-rc1 - 2022-05-19

- First release candidate.

[1.0.0-rc5]: https://git.smile.fr/magento2/docker-boilerplate/compare/1.0.0-rc4...1.0.0-rc5
[1.0.0-rc4]: https://git.smile.fr/magento2/docker-boilerplate/compare/1.0.0-rc3...1.0.0-rc4
[1.0.0-rc3]: https://git.smile.fr/magento2/docker-boilerplate/compare/1.0.0-rc2...1.0.0-rc3
[1.0.0-rc2]: https://git.smile.fr/magento2/docker-boilerplate/compare/1.0.0-rc1...1.0.0-rc2
