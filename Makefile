# To list all available targets, type "make"

DOCKER_COMPOSE := docker compose
PHP_CLI := $(DOCKER_COMPOSE) run --rm cli
VENDOR_BIN := $(PHP_CLI) vendor/bin
DB_CONNECTION := --user=$$MYSQL_USER --password=$$MYSQL_PASSWORD $$MYSQL_DATABASE

.DEFAULT_GOAL := help

help:
	@grep -E '(^[a-zA-Z0-9_-]+:.*?##)|(^##)' $(firstword $(MAKEFILE_LIST)) | awk 'BEGIN {FS = ":.*?## "}{printf "\033[32m%-30s\033[0m %s\n", $$1, $$2}' | sed -e 's/\[32m## /\n[33m/'

.PHONY: check-requirements
check-requirements:
	@./docker/bin/check-requirements

.PHONY: setup-project
setup-project:
	@./docker/bin/setup

## Docker
.PHONY: up
up: check-requirements ## Build and start all containers.
	$(DOCKER_COMPOSE) up -d --remove-orphans

.PHONY: down
down: check-requirements ## Stop and remove all containers.
	$(DOCKER_COMPOSE) down --remove-orphans

PHONY: restart
restart: check-requirements ## Restart all containers. Pass the parameter "service=" to restart a specific container. Example: make restart service=varnish
	@$(eval service ?=)
	$(DOCKER_COMPOSE) restart $(service)

.PHONY: ps
ps: check-requirements ## List active containers.
	@$(eval service ?=)
	$(DOCKER_COMPOSE) ps $(service)

.PHONY: logs
logs: check-requirements ## Show Docker logs. Pass the parameter "service=" to get logs of a given service. Example: make logs service=elasticsearch
	@$(eval service ?=)
	$(DOCKER_COMPOSE) logs --tail=0 --follow $(service)

.PHONY: top
top: check-requirements ## Shows all running processes. Pass the parameter "service=" to display the processes of a specific container. Eample: make top service=fpm
	@$(eval service ?=)
	$(DOCKER_COMPOSE) top $(service)

.PHONY: images
images: check-requirements ## List images used by containers.
	@$(eval service ?=)
	$(DOCKER_COMPOSE) images $(service)

.PHONY: build
build: check-requirements ## Build all images. Only useful if you project uses custom Dockerfiles.
	@$(eval service ?=)
	$(DOCKER_COMPOSE) build $(service)

## Services
.PHONY: sh
sh: check-requirements ## Open a shell on the php container. Pass the parameter "service=" to connect to another service. Example: make sh service=redis
	@$(eval service ?= php)
	@$(eval cmd ?= sh)
	@if [ "$(service)" = "php" ]; then echo "$(PHP_CLI) $(cmd)"; $(PHP_CLI) $(cmd); \
	else echo "$(DOCKER_COMPOSE) exec $(service) $(cmd)"; $(DOCKER_COMPOSE) exec $(service) $(cmd); fi

.PHONY: db
db: check-requirements ## Connect to the Magento database.
	$(DOCKER_COMPOSE) exec db sh -c 'mysql $(DB_CONNECTION)'

.PHONY: db-dump
db-dump: check-requirements ## Dump the database. Pass the parameter "filename=" to customize the filename (default: dump.sql).
	$(eval filename ?= 'dump.sql')
	$(DOCKER_COMPOSE) exec db sh -c 'mysqldump $(DB_CONNECTION)' > $(filename)

.PHONY: db-import
db-import: check-requirements ## Import a database dump. Pass the parameter "filename=" to customize the filename (default: dump.sql).
	@if [ -z "$(filename)" ]; then echo "Please provide a filename."; echo "Example: make db-import filename=dump.sql"; fi
	$(DOCKER_COMPOSE) exec -T db sh -c 'mysql $(DB_CONNECTION)' < $(filename)

## Composer
.PHONY: composer
composer: check-requirements ## Run composer. Example: make composer cmd="config --list"
	@$(eval cmd ?=)
	$(PHP_CLI) composer $(cmd)

.PHONY: composer-install
composer-install: ## Run "composer install"
composer-install: cmd=install
composer-install: composer

.PHONY: composer-update
composer-update: ## Run "composer update"
composer-update: cmd=update
composer-update: composer

## Magento
.PHONY: magento
magento: check-requirements ## Run bin/magento. Example: make magento cmd=indexer:reindex
	@$(eval cmd ?=)
	$(PHP_CLI) bin/magento $(cmd)

.PHONY: cache-clean
cache-clean: ## Run "bin/magento cache:clean". Example: make cache-clean type="config layout"
cache-clean: type ?=
cache-clean: cmd=cache:clean $(type)
cache-clean: magento
cc: cache-clean

.PHONY: generate-di
generate-di: ## Run "bin/magento setup:di:compile".
generate-di: cmd=setup:di:compile
generate-di: magento

.PHONY: reconfigure
reconfigure: ## Run "bin/magento smilereconfigure:apply-conf".
reconfigure: env ?= dev
reconfigure: cmd=smilereconfigure:apply-conf $(env)
reconfigure: magento

.PHONY: reindex
reindex:## Run "bin/magento indexer:reindex". Example: make reindex type="catalog_product"
reindex: type ?=
reindex: cmd=indexer:reindex $(type)
reindex: magento

.PHONY: setup-install
setup-install: check-requirements ## (Re)install the Magento database. You will be prompted for confirmation if the database is already installed.
	./docker/bin/setup-db

.PHONY: setup-upgrade
setup-upgrade: ## Run "bin/magento setup:upgrade".
setup-upgrade: cmd=setup:upgrade
setup-upgrade: magento

## Static Code Analysis
.PHONY: phpcs
phpcs: check-requirements ## Run phpcs. Example: make phpcs
	@$(eval cmd ?=)
	$(VENDOR_BIN)/phpcs $(cmd)

phpmd: check-requirements ## Run phpmd. Example: make phpmd cmd="app/code xml phpmd.xml.dist"
	@$(eval sources ?= app/code)
	@$(eval format ?= ansi)
	@$(eval ruleset ?= phpmd.xml.dist)
	$(VENDOR_BIN)/phpmd $(sources) $(format) $(ruleset)

.PHONY: phpstan
phpstan: check-requirements ## Run phpstan. Example: make phpstan
	@$(eval cmd ?=)
	$(VENDOR_BIN)/phpstan $(cmd)

.PHONY: phpunit
phpunit: check-requirements ## Run phpunit. Example: make phpunit
	@$(eval cmd ?=)
	$(VENDOR_BIN)/phpunit $(cmd)

.PHONY: phpcbf
phpcbf: check-requirements ## Run phpcbf. Example: make phpcbf
	@$(eval cmd ?=)
	$(VENDOR_BIN)/phpcbf $(cmd)

.PHONY: php-cs-fixer
php-cs-fixer: check-requirements ## Run php-cs-fixer. Example: make php-cs-fixer cmd="fix --config=.php-cs-fixer.dist.php"
	@$(eval cmd ?=)
	$(VENDOR_BIN)/php-cs-fixer $(cmd)

.PHONY: smileanalyser
smileanalyser: check-requirements ## Run smileanalyser.
	@$(eval profile ?=magento2/*)
	$(VENDOR_BIN)/SmileAnalyser launch --profile $(profile)
