ifneq ($(shell command -v docker > /dev/null; echo $$?), 0)
    $(error Docker must be installed)
endif

ifneq ($(shell docker compose > /dev/null 2>&1; echo $$?), 0)
    $(error Docker Compose plugin must be installed)
endif

include .env

UNAME := $(shell uname)
ifeq ($(UNAME), Darwin)
    SEDI := sed -i ''
else
    SEDI := sed -i
endif

# Docker
DOCKER_COMPOSE := docker compose
PHP_CLI := $(DOCKER_COMPOSE) run --rm php
COMPOSER := $(DOCKER_COMPOSE) run --rm --no-deps php composer
VENDOR_BIN := $(PHP_CLI) vendor/bin
DB_CONTAINER := db
DB_CONNECTION := --user=$$MYSQL_USER --password=$$MYSQL_PASSWORD $$MYSQL_DATABASE

# Target dependencies
COMPOSER_FILE := $(MAGENTO_DIR)/composer.json
VENDOR_DIR := $(MAGENTO_DIR)/vendor
MAGENTO_ENV := $(MAGENTO_DIR)/app/etc/env.php

.DEFAULT_GOAL := help

help:
	@grep -E '(^[a-zA-Z0-9_-]+:.*?##)|(^##)' $(firstword $(MAKEFILE_LIST)) | awk 'BEGIN {FS = ":.*?## "}{printf "\033[32m%-30s\033[0m %s\n", $$1, $$2}' | sed -e 's/\[32m## /\n[33m/'

.PHONY: init-project
init-project:
	@./docker/bin/setup

## Docker containers.
.PHONY: up
up: ## Build and start containers. Pass the parameter "service=" to target a specific container. Example: make up service=php
	@$(eval service ?=)
	$(DOCKER_COMPOSE) up -d --remove-orphans $(service)

.PHONY: down
down: ## Stop and remove all containers.
	$(DOCKER_COMPOSE) down --remove-orphans

PHONY: restart
restart: ## Restart containers. Pass the parameter "service=" to target a specific container.
	@$(eval service ?=)
	$(DOCKER_COMPOSE) restart $(service)

.PHONY: ps
ps: ## List active containers. Pass the parameter "service=" to target a specific container.
	@$(eval service ?=)
	$(DOCKER_COMPOSE) ps $(service)

.PHONY: logs
logs: ## Show Docker logs. Pass the parameter "service=" to target a specific container.
	@$(eval service ?=)
	$(DOCKER_COMPOSE) logs --tail=0 --follow $(service)

.PHONY: top
top: ## Shows running processes. Pass the parameter "service=" to target a specific container.
	@$(eval service ?=)
	$(DOCKER_COMPOSE) top $(service)

.PHONY: images
images: ## List images used by containers. Pass the parameter "service=" to target a specific container.
	@$(eval service ?=)
	$(DOCKER_COMPOSE) images $(service)

.PHONY: build
build: ## Build images. Pass the parameter "service=" to target a specific container.
	@$(eval service ?=)
	$(DOCKER_COMPOSE) build $(service)

## Services
.PHONY: sh
sh: ## Open a shell on the php container. Pass the parameter "service=" to connect to another service. Example: make sh service=redis
	@$(eval service ?= php)
	@$(eval c ?= sh)
	@if [ "$(service)" = "php" ]; then echo "$(PHP_CLI) $(c)"; $(PHP_CLI) $(c); \
	else echo "$(DOCKER_COMPOSE) exec $(service) $(c)"; $(DOCKER_COMPOSE) exec $(service) $(c); fi

.PHONY: db
db: ## Connect to the Magento database.
	$(DOCKER_COMPOSE) exec $(DB_CONTAINER) sh -c 'mysql $(DB_CONNECTION)'

.PHONY: db-import
db-import: ## Import a database dump. Pass the parameter "filename=" to set the filename (mandatory).
	@if [ -z "$(filename)" ]; then echo "Please provide a filename."; echo "Example: make db-import filename=dump.sql"; exit 1; fi
	@if [ ! -f "$(filename)" ]; then echo "File not found."; exit 1; fi
	$(DOCKER_COMPOSE) exec -T $(DB_CONTAINER) sh -c 'mysql $(DB_CONNECTION)' < $(filename)

.PHONY: db-dump
db-export: ## Dump the database. Pass the parameter "filename=" to set the filename (default: dump.sql).
	$(eval filename ?= 'dump.sql')
	$(DOCKER_COMPOSE) exec $(DB_CONTAINER) sh -c 'mysqldump $(DB_CONNECTION)' > $(filename)

.PHONY: toggle-cron
toggle-cron: ## Enable/disable the cron container.
ifeq ($(CRON_COMMAND), true)
	$(eval VALUE := run-cron)
	$(eval STATUS := enabled)
else
	$(eval VALUE := true)
	$(eval STATUS := disabled)
endif
	@$(SEDI) -e "s/^CRON_COMMAND=.*/CRON_COMMAND=$(VALUE)/" .env
	@echo "CRON_COMMAND was set to \"$(VALUE)\" in .env file ($(STATUS))."
	$(DOCKER_COMPOSE) up -d --no-deps cron

## Composer
.PHONY: composer
composer: $(COMPOSER_FILE) ## Run composer. Example: make composer c="require vendor/package:^1.0"
	@$(eval c ?=)
	$(COMPOSER) $(c)

## Magento
.PHONY: magento
magento: $(VENDOR_DIR) ## Run "bin/magento". Example: make magento c=indexer:reindex
	@$(eval c ?=)
	$(PHP_CLI) bin/magento $(c)

.PHONY: cache-clean
cache-clean: $(MAGENTO_ENV) ## Run "bin/magento cache:clean". Example: make cache-clean type="config layout"
cache-clean: type ?=
cache-clean: c=cache:clean $(type)
cache-clean: magento
cc: cache-clean

.PHONY: generate-di
generate-di: ## Run "bin/magento setup:di:compile".
generate-di: c=setup:di:compile
generate-di: magento

.PHONY: reconfigure
reconfigure: $(MAGENTO_ENV) ## Run "bin/magento smilereconfigure:apply-conf". Example: make reconfigure env=dev
reconfigure: env ?= dev
reconfigure: c=smilereconfigure:apply-conf $(env)
reconfigure: magento

.PHONY: reindex
reindex: $(MAGENTO_ENV) ## Run "bin/magento indexer:reindex". Example: make reindex type="catalog_product"
reindex: type ?=
reindex: c=indexer:reindex $(type)
reindex: magento

.PHONY: setup-install
setup-install: $(VENDOR_DIR) ## Run "bin/magento setup:install". You will need to execute this if you make a change in the magento.env file.
	@$(eval reset_db = 0)
ifneq ($(reset_db),$(filter $(reset_db),0 1))
	$(error The parameter "reset_db" must be equal to 0 or 1)
endif
	RESET_DB=$(reset_db) ./docker/bin/setup-db

.PHONY: setup-upgrade
setup-upgrade: $(MAGENTO_ENV) ## Run "bin/magento setup:upgrade".
setup-upgrade: c=setup:upgrade
setup-upgrade: magento

## Static Code Analysis
.PHONY: phpcs
phpcs: $(VENDOR_DIR) ## Run phpcs. Example: make phpcs
	@$(eval c ?=)
	$(VENDOR_BIN)/phpcs $(c)

phpmd: $(VENDOR_DIR) ## Run phpmd. Example: make phpmd c="app/code xml phpmd.xml.dist"
	@$(eval sources ?= app/code)
	@$(eval format ?= ansi)
	$(VENDOR_BIN)/phpmd $(sources) $(format) phpmd.xml.dist

.PHONY: phpstan
phpstan: $(VENDOR_DIR) ## Run phpstan. Example: make phpstan
	@$(eval c ?=)
	$(VENDOR_BIN)/phpstan $(c)

.PHONY: phpunit
phpunit: $(VENDOR_DIR) ## Run phpunit. Example: make phpunit
	@$(eval c ?=)
	$(VENDOR_BIN)/phpunit $(c)

.PHONY: phpcbf
phpcbf: $(VENDOR_DIR) ## Run phpcbf. Example: make phpcbf
	@$(eval c ?=)
	$(VENDOR_BIN)/phpcbf $(c)

.PHONY: php-cs-fixer
php-cs-fixer: $(VENDOR_DIR) ## Run php-cs-fixer. Example: make php-cs-fixer c="fix --config=.php-cs-fixer.dist.php"
	@$(eval c ?=)
	$(VENDOR_BIN)/php-cs-fixer $(c)

.PHONY: smileanalyser
smileanalyser: $(VENDOR_DIR) ## Run smileanalyser.
	@$(eval profile ?=magento2/*)
	$(VENDOR_BIN)/SmileAnalyser launch --profile $(profile)

.env: | .env.dist
	@cp .env.dist .env
	@echo ".env file was automatically created."
ifeq ($(UNAME), Linux)
	@sed -i -e "s/^DOCKER_UID=.*/DOCKER_UID=$$(id -u)/" -e "s/^DOCKER_GID=.*/DOCKER_GID=$$(id -g)/" .env
endif
	@if [ -z "$$COMPOSER_AUTH" ] && command -v composer > /dev/null; then \
		COMPOSER_GITHUB_TOKEN="$$(composer config --global github-oauth.github.com 2>/dev/null || true)"; \
		if [ -n "$$COMPOSER_GITHUB_TOKEN" ]; then \
			$(SEDI) -e "s/^#COMPOSER_AUTH=.*/COMPOSER_AUTH={\"github-oauth\":{\"github.com\":\"$$COMPOSER_GITHUB_TOKEN\"}}/g" .env; \
			echo "Your composer GitHub token was saved in .env file."; \
		fi; \
	fi

$(MAGENTO_ENV): | $(VENDOR_DIR)
	$(error Please run `make setup-install` to initialize the database)

$(VENDOR_DIR): | $(COMPOSER_FILE)
	$(COMPOSER) install

$(COMPOSER_FILE):
	$(error Please run `make init-project` to initialize the project)
