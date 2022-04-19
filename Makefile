VALIDATE_TARGET = check-requirements

# Docker containers
PHP_CLI = docker compose run --rm cli
PHP_DATABASE = docker compose exec db

# Commands
VENDOR_BIN = $(PHP_CLI) vendor/bin

.DEFAULT_GOAL := help

help:
	@echo "Help:"
	@grep -E '(^[a-zA-Z0-9_-]+:.*?##)|(^##)' $(firstword $(MAKEFILE_LIST)) | awk 'BEGIN {FS = ":.*?## "}{printf "\033[32m%-30s\033[0m %s\n", $$1, $$2}' | sed -e 's/\[32m## /\n[33m/'

.PHONY: check-requirements
check-requirements:
	@./docker/bin/check-requirements

.PHONY: setup-project
setup-project:
	@./docker/bin/setup

## Docker
.PHONY: up
up: $(VALIDATE_TARGET) ## Build and start all containers.
	@docker compose up -d --remove-orphans

.PHONY: down
down: $(VALIDATE_TARGET) ## Stop and remove all containers.
	@docker compose down --remove-orphans

PHONY: restart
restart: $(VALIDATE_TARGET) ## Restart all containers. Pass the parameter "service=" to restart a specific container. Example: make restart service=varnish
	@$(eval service ?=)
	@docker compose restart $(service)

.PHONY: ps
ps: $(VALIDATE_TARGET) ## List active containers.
	@$(eval service ?=)
	@docker compose ps $(service)

.PHONY: logs
logs: $(VALIDATE_TARGET) ## Show Docker logs. Pass the parameter "service=" to get logs of a given service. Example: make logs service=elasticsearch
	@$(eval service ?=)
	@docker compose logs --tail=0 --follow $(service)

.PHONY: top
top: $(VALIDATE_TARGET) ## Shows all running processes. Pass the parameter "service=" to display the processes of a specific container. Eample: make top service=fpm
	@$(eval service ?=)
	@docker compose top $(service)

.PHONY: images
images: $(VALIDATE_TARGET) ## List images used by containers.
	@$(eval service ?=)
	@docker compose images $(service)

.PHONY: build
build: $(VALIDATE_TARGET) ## Build all images. Only useful if you project uses custom Dockerfiles.
	@$(eval service ?=)
	@docker compose build $(service)

## Services
.PHONY: sh
sh: $(VALIDATE_TARGET) ## Open a shell on the php-cli container. Pass the parameter "service=" to connect to another service. Example: make sh service=redis
	@$(eval service ?= cli)
	@echo "Connecting to container \"$(service)\""
	@if [ "$(service)" = "cli" ]; then $(PHP_CLI) sh; \
	else docker compose exec $(service) sh; fi

.PHONY: db
db: $(VALIDATE_TARGET) ## Connect to the Magento database.
	@$(PHP_DATABASE) bash -c 'mysql --user=$$MYSQL_USER --password=$$MYSQL_PASSWORD $$MYSQL_DATABASE'

## Composer
.PHONY: composer
composer: $(VALIDATE_TARGET) ## Run composer. Example: make composer cmd="config --list"
	@$(eval cmd ?=)
	@$(PHP_CLI) composer $(cmd)

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
magento: $(VALIDATE_TARGET) ## Run bin/magento. Example: make magento cmd=indexer:reindex
	@$(eval cmd ?=)
	@$(PHP_CLI) bin/magento $(cmd)

.PHONY: cache-clean
cache-clean: ## Run "bin/magento cache:clean". Example: make cache-clean type="config layout"
cache-clean: $(eval type ?=)
cache-clean: cmd=cache:clean $(type)
cache-clean: magento
cc: cache-clean

.PHONY: generate-di
generate-di: ## Run "bin/magento setup:di:compile".
generate-di: cmd=setup:di:compile
generate-di: magento

.PHONY: reconfigure
reconfigure: ## Run "bin/magento smilereconfigure:apply-conf".
reconfigure: $(eval env ?= dev)
reconfigure: cmd=smilereconfigure:apply-conf $(env)
reconfigure: magento

.PHONY: reindex
reindex:## Run "bin/magento indexer:reindex". Example: make reindex type="catalog_product"
reindex: $(eval type ?=)
reindex: cmd=indexer:reindex $(type)
reindex: magento

.PHONY: setup-install
setup-install: $(VALIDATE_TARGET) ## (Re)install the Magento database. You will be prompted for confirmation if the database is already installed.
	@./docker/bin/setup-db

.PHONY: setup-upgrade
setup-upgrade: ## Run "bin/magento setup:upgrade".
setup-upgrade: cmd=setup:upgrade
setup-upgrade: magento

## Static Code Analysis
.PHONY: phpcs
phpcs: $(VALIDATE_TARGET) ## Run phpcs. Example: make phpcs
	@$(eval cmd ?=)
	@$(VENDOR_BIN)/phpcs $(cmd)

.PHONY: phpmd
phpmd: $(VALIDATE_TARGET) ## Run phpmd. Example: make phpmd cmd="app/code xml phpmd.xml.dist"
	@$(eval cmd ?=)
	@$(VENDOR_BIN)/phpmd app/code ansi phpmd.xml $(cmd)

.PHONY: phpstan
phpstan: $(VALIDATE_TARGET) ## Run phpstan. Example: make phpstan
	@$(eval cmd ?=)
	@$(VENDOR_BIN)/phpstan $(cmd)

.PHONY: phpunit
phpunit: $(VALIDATE_TARGET) ## Run phpunit. Example: make phpunit
	@$(eval cmd ?=)
	@$(VENDOR_BIN)/phpunit $(cmd)

.PHONY: php-cs-fixer
php-cs-fixer: $(VALIDATE_TARGET) ## Run php-cs-fixer. Example: make php-cs-fixer cmd="fix --config=.php-cs-fixer.dist.php"
	@$(eval cmd ?=)
	@$(VENDOR_BIN)/php-cs-fixer $(cmd)

.PHONY: smileanalyser
smileanalyser: $(VALIDATE_TARGET) ## Run smileanalyser.
	@$(eval profile ?=magento2/*)
	@$(VENDOR_BIN)/SmileAnalyser launch --profile $(profile)
