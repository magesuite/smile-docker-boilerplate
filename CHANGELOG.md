# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed

- Upgrade maildev from 1.1.1 to 2.0.5.
- Update Varnish VCL file
- Rename configuration files with ambiguous names (e.g. "default.conf" renamed to "default-dev.conf").

### Fixed

- Fix PHP file caching issue by setting `opcache.validate_timestamps = On` in the php dev image.

## 1.0.0-rc1 - 2022-05-19

- First release candidate.

[Unreleased]: https://git.smile.fr/magento2/docker-boilerplate/compare/1.0.0-rc1...master
