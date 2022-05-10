## Makefile

This boilerplate is bundled with a Makefile that provides multiple targets that help you use docker and Magento.

The list of available targets can be listed by running `make` at the root of the docker boilerplate.

When you run a Make target (e.g. `make sh`, the command that is executed is displayed in your terminal).
As a consequence, using the Makefile helps you being more productive, without hiding what it does behind the hood.

## Docker

### Interacting with Containers

The following targets allow you to interact with the docker containers:

- `make up`: start all containers.
- `make down`: stop all containers (use this if you want to start working on another project).
- `make ps`: list active containers and their status.
- `make top`: list running processes on all containers.
- `make logs`: list Docker logs.
- `make build`: rebuild the images stored in ./docker/images.

Most targets accept a parameter named `service` (e.g. `make up service=php`).

The target "logs" also accepts a parameter named "tail", which defines the number of previous logs to display (20 by default).
For example, `make logs service=web tail=50` displays the 50 latest log entries for the web container (and continues displaying new logs).

### Connecting to a Container

You can open a SSH connection to any container by running `make sh`.
This target can also be used to run a specific command on a container.

For example:

- `make sh` opens a shell on the php container.
- `make sh service=redis` opens a shell on the redis container.
- `make sh service=redis c="redis-cli flushdb"` runs the command defined in the parameter "c=" on the redis container.

## Database

See [Working with the Database](03-database.md).

## Magento

The command"bin/magento" can be executed with `make magento`.

Example: `make magento c=indexer:status`.

The Makefile also contains some aliases for commands that are often used.
For example, `make cc type="config layout"` is the same as `make magento c="cache:clean config layout"`.

All Magento targets accept a parameter named `debug`.
This can be used to [debug a Magento command](04-xdebug.md).
Example: `make setup-upgrade debug=1`

## Code Quality

The following targets can be used to analyse your code/run tests:

- `make analyse`: run phpcs, phpmd, phpstan and smileanalyser.
- `make phpunit`: run phpunit.

**These targets must not report any error**!
Don't commit your code if these commands report errors.

## Composer

There are two targets that can be used to interact with composer:

- `make composer`: runs composer. Example: `make composer c="require vendor/package:^1.0"`.
- `make vendor/bin`: runs a binary file located in vendor/bin. Example: `make vendor-bin c=phpcs`.

## Grunt

Grunt can be executed with `make grunt`.

You can use the following commands (replace "mytheme" by your theme name, defined in dev/tools/grunt/configs/local-themes.js):

- `make grunt c=watch`
- `make grunt c="clean:mytheme"`
- `make grunt c="exec:mytheme"`
- `make grunt c="less:mytheme"`
