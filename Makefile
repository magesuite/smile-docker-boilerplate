.DEFAULT_GOAL := help
SHELL := /bin/bash
UNAME := $(shell uname)

ifneq ($(shell docker compose version > /dev/null 2>&1; echo $$?),0)
    $(error Docker Compose plugin must be installed)
endif

ifeq ($(UNAME),Darwin)
    SEDI := sed -i ''
else
    SEDI := sed -i
endif

include .env

# Docker
DOCKER_COMPOSE := docker compose --profile cron
DOCKER_COMPOSE_NO_PROFILE := docker compose
PHP_SERVICE := php
PHP_XDEBUG_SERVICE := php_xdebug
DB_SERVICE := db
DB_CONNECTION := --user=$$MYSQL_USER --password=$$MYSQL_PASSWORD $$MYSQL_DATABASE
PHP_CLI := $(DOCKER_COMPOSE) run --rm --no-deps $(PHP_SERVICE)

# Apps
COMPOSER := $(PHP_CLI) composer
MAGENTO_BIN := $(DOCKER_COMPOSE) run --rm $(PHP_SERVICE) bin/magento

# Target dependencies
MAGENTO_ENV := $(MAGENTO_DIR)/app/etc/env.php
NODE_MODULES_DIR := $(MAGENTO_DIR)/node_modules
VENDOR_DIR := $(MAGENTO_DIR)/vendor

help:
	@grep -E '(^[a-zA-Z0-9_-]+:.*?##)|(^##)' $(firstword $(MAKEFILE_LIST)) | awk 'BEGIN {FS = ":.*?## "; printf "Usage: make \033[32m<target>\033[0m\n"}{printf "\033[32m%-20s\033[0m %s\n", $$1, $$2}' | sed -e 's/\[32m## /\n[33m/'

## Docker
.PHONY: up
up: ## Build and start containers. Pass the parameter "service=" to filter which containers to start. Example: make up service=php
	$(DOCKER_COMPOSE_NO_PROFILE) up -d --remove-orphans $(service)

.PHONY: down
down: ## Stop and remove containers.
	$(DOCKER_COMPOSE_NO_PROFILE) down --remove-orphans

.PHONY: restart
restart: ## Restart containers. Pass the parameter "service=" to filter which containers to restart.
	$(DOCKER_COMPOSE) restart $(service)

.PHONY: ps
ps: ## List active containers. Pass the parameter "service=" to filter which containers to list.
	$(DOCKER_COMPOSE) ps $(service)

.PHONY: logs
logs: ## Show container logs. Pass the parameter "service=" to filter which containers to watch.
	$(eval tail ?= 20)
	$(DOCKER_COMPOSE) logs -f --tail $(tail) $(service)

.PHONY: top
top: ## Show running processes. Pass the parameter "service=" to filter which containers to list.
	$(DOCKER_COMPOSE) top $(service)

.PHONY: build
build: ## Build images. Pass the parameter "service=" to filter which images to build.
	$(DOCKER_COMPOSE) build $(service)

## Services
.PHONY: sh
sh: ## Open a shell on the php container. Pass the parameter "service=" to connect to another container. Example: make sh service=redis
	$(eval service ?= php) $(eval c ?= sh)
	@[ "$(service)" = "$(PHP_SERVICE)" ] || [ "$(service)" = "$(PHP_XDEBUG_SERVICE)" ] \
		&& CMD="$(DOCKER_COMPOSE) run --rm $(service) $(c)" || CMD="$(DOCKER_COMPOSE) exec $(service) $(c)"; echo "$$CMD" && $$CMD

.PHONY: db
db: service := --wait $(DB_SERVICE)
db: up ## Connect to the Magento database.
	$(DOCKER_COMPOSE) exec $(DB_SERVICE) sh -c 'mysql $(DB_CONNECTION)'

.PHONY: db-import
db-import: service := --wait $(DB_SERVICE)
db-import: up ## Import a database dump. Pass the parameter "filename=" to set the filename (default: dump.sql).
	$(eval filename ?= dump.sql)
	$(DOCKER_COMPOSE) exec -T $(DB_SERVICE) sh -c 'mysql $(DB_CONNECTION)' < $(filename)

.PHONY: db-export
db-export: service := --wait $(DB_SERVICE)
db-export: up ## Dump the database. Pass the parameter "filename=" to set the filename (default: dump.sql), or "args=" to specify a list of tables to dump.
	$(eval filename ?= dump.sql)
	$(DOCKER_COMPOSE) exec $(DB_SERVICE) sh -c 'mysqldump $(DB_CONNECTION) --single-transaction --triggers $(args)' > $(filename)

.PHONY: toggle-cron
toggle-cron: ## Enable/disable the cron container (disabled by default).
	@if [[ $$($(DOCKER_COMPOSE) ps | grep cron) ]]; then CMD="$(DOCKER_COMPOSE) stop cron && $(DOCKER_COMPOSE) rm -f cron"; \
	else CMD="$(DOCKER_COMPOSE) up -d cron"; fi; \
	echo "$$CMD"; eval "$$CMD"

## Magento
.PHONY: install
install: $(VENDOR_DIR) ## Install Magento. If you change a value in magento.env, you must re-execute this to apply the change. Pass the parameter "reset_db=1" to reset the database.
	$(eval reset_db ?= 0)
	RESET_DB=$(reset_db) ./docker/bin/setup-db

.PHONY: magento
magento: $(VENDOR_DIR) ## Run "bin/magento". Pass the parameter "c=" to run a given command. Example: make magento c=indexer:status
	$(eval debug ?= 0)
	@if [ "$(debug)" != "0" ] && [ "$(debug)" != "1" ]; then echo "The variable \"debug\" must be equal to 0 or 1."; exit 1; \
	elif [ "$(debug)" = "1" ]; then CMD="$(DOCKER_COMPOSE) run --rm --env PHP_IDE_CONFIG=serverName=_ --env XDEBUG_SESSION=cli $(PHP_XDEBUG_SERVICE) php bin/magento $(c)"; \
	else CMD="$(MAGENTO_BIN) $(c)"; fi; \
	echo "$$CMD"; eval "$$CMD"

.PHONY: cache-clean
cache-clean: $(MAGENTO_ENV) ## Run "bin/magento cache:clean". Example: make cache-clean type="config layout"
cache-clean: c=cache:clean $(type)
cache-clean: magento
cc: cache-clean

.PHONY: reconfigure
reconfigure: $(MAGENTO_ENV) ## Run "bin/magento smilereconfigure:apply-conf". Example: make reconfigure env=dev
reconfigure: env ?= dev
reconfigure: c=smilereconfigure:apply-conf $(env)
reconfigure: magento

.PHONY: reindex
reindex: $(MAGENTO_ENV) ## Run "bin/magento indexer:reindex". Example: make reindex type="catalog_product"
reindex: c=indexer:reindex $(type)
reindex: magento

.PHONY: setup-upgrade
setup-upgrade: $(MAGENTO_ENV) ## Run "bin/magento setup:upgrade".
setup-upgrade: c=setup:upgrade
setup-upgrade: magento

.PHONY: grunt
grunt: $(NODE_MODULES_DIR) ## Run grunt. Example: make grunt c=watch
	$(PHP_CLI) npm exec grunt $(c)

## Composer
.PHONY: composer
composer: $(VENDOR_DIR) ## Run composer. Example: make composer c="require vendor/package:^1.0"
	$(COMPOSER) $(c)

.PHONY: vendor-bin
vendor-bin: $(VENDOR_DIR) ## Run a binary located in vendor/bin. Example: make vendor-bin c=phpcs
	@if [ -z "$(c)" ]; then echo "Please provide a command. Example: make vendor-bin c=phpcs."; exit 1; fi
	$(PHP_CLI) vendor/bin/$(c)

## Code Quality
.PHONY: analyse
analyse: $(VENDOR_DIR) ## Run a static code analysis on the entire codebase (files must be known to git).
	$(PHP_CLI) vendor/bin/grumphp run --testsuite=static
	$(PHP_CLI) vendor/bin/SmileAnalyser launch --strict --skipNotices yes

.PHONY: pre-commit
pre-commit: $(VENDOR_DIR) ## Run a static code analysis on staged files.
	$(PHP_CLI) vendor/bin/grumphp git:pre-commit
	$(PHP_CLI) vendor/bin/SmileAnalyser launch --strict --skipNotices yes

.PHONY: tests
tests: $(VENDOR_DIR) ## Run phpunit.
	$(PHP_CLI) vendor/bin/grumphp run --testsuite=tests

# Targets not shown in help
.PHONY: init-project
init-project:
	@./docker/bin/setup

# Docker files
.env: | .env.dist
	@cp .env.dist .env
	@echo ".env file was automatically created."
ifeq ($(UNAME),Linux)
	@$(SEDI) -e "s/^DOCKER_UID=.*/DOCKER_UID=$$(id -u)/" -e "s/^DOCKER_GID=.*/DOCKER_GID=$$(id -g)/" .env
endif
	@if [ -z "$(COMPOSER_AUTH)" ] && command -v composer > /dev/null; then \
		COMPOSER_GITHUB_TOKEN="$$(composer config --global github-oauth.github.com 2>/dev/null || true)"; \
		if [ -n "$$COMPOSER_GITHUB_TOKEN" ]; then \
			$(SEDI) -e "s/^#COMPOSER_AUTH=.*/COMPOSER_AUTH={\"github-oauth\":{\"github.com\":\"$$COMPOSER_GITHUB_TOKEN\"}}/" .env; \
			echo "Your composer GitHub token was saved in .env file."; \
		fi; \
	fi

# Magento config file
$(MAGENTO_ENV): | $(VENDOR_DIR)
	$(error Please run `make install` to initialize the database)

# Composer files
$(VENDOR_DIR): | $(MAGENTO_DIR)/composer.json
	$(COMPOSER) install

$(MAGENTO_DIR)/composer.json:
	$(error Please run `make init-project` to initialize the project)

# Node files
$(NODE_MODULES_DIR): | $(MAGENTO_DIR)/package.json
	$(PHP_CLI) npm install

$(MAGENTO_DIR)/package.json:
	$(error Please run `make init-project` to initialize the project)
