SHELL := /bin/bash

# Docker containers
PHP_CLI = docker-compose run --rm cli
PHP_DATABASE = docker-compose exec db

.DEFAULT_GOAL:=help
.PHONY: help build up down ps logs bash db composer magento phpcs phpunit phpstan php-cs-fixer

help:
	@grep -E '(^[a-zA-Z0-9_-]+:.*?##)|(^##)' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}{printf "\033[32m%-30s\033[0m %s\n", $$1, $$2}' | sed -e 's/\[32m## /\n[33m/'

## Docker
build: ## Builds all images.
	@docker-compose build

up: ## Starts all containers in detached mode (no logs).
	@docker-compose up -d

down: ## Stops all containers.
	@docker-compose down --remove-orphans

ps: ## Lists active containers.
	@docker-compose ps

logs: ## Shows Docker logs. Pass the parameter "service=" to get logs of a given service. Example: make logs service=elasticsearch.
	@$(eval service ?=)
	@docker-compose logs --tail=0 --follow $(service)

## Services
bash: ## Opens a bash terminal on the php-cli container. Pass the parameter "service=" to connect to another service. Example: make bash service=redis.
	@$(eval service ?= cli)
	@echo "Connecting to container \"$(service)\""
	@if [ "$(service)" = "cli" ]; then $(PHP_CLI) bash; \
	else docker-compose exec $(service) bash; fi

db: ## Connects to the Magento database.
	@$(PHP_DATABASE) bash -c 'mysql --user=$$MYSQL_USER --password=$$MYSQL_PASSWORD $$MYSQL_DATABASE'

## CLI commands
composer: ## Runs composer. Example: make composer cmd="config --list"
	@$(eval cmd ?=)
	@$(PHP_CLI) composer $(cmd)

magento: ## Runs bin/magento. Example: make magento cmd=indexer:reindex
	@$(eval cmd ?=)
	@$(PHP_CLI) bin/magento $(cmd)

## Static Code Analysis
phpcs: ## Runs phpcs. Example: make phpcs cmd="--standard=ruleset.xml.dist"
	@$(eval cmd ?=)
	@$(PHP_CLI) vendor/bin/phpcs $(cmd)

phpunit: ## Runs phpunit. Example: make phpunit
	@$(eval cmd ?=)
	@$(PHP_CLI) vendor/bin/phpunit $(cmd)

phpstan: ## Runs phpstan. Example: make phpstan
	@$(eval cmd ?=)
	@$(PHP_CLI) vendor/bin/phpstan $(cmd)

php-cs-fixer: ## Runs php-cs-fixer. Example: make php-cs-fixer cmd="fix --config=.php-cs-fixer.dist.php"
	@$(eval cmd ?=)
	@$(PHP_CLI) vendor/bin/php-cs-fixer $(cmd)
