# Docker containers
PHP_CLI = docker compose run --rm cli
PHP_DATABASE = docker compose exec db

.DEFAULT_GOAL:=help
.PHONY: help up down ps logs images build sh db composer magento phpcs phpunit phpstan php-cs-fixer

help:
	@grep -E '(^[a-zA-Z0-9_-]+:.*?##)|(^##)' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}{printf "\033[32m%-30s\033[0m %s\n", $$1, $$2}' | sed -e 's/\[32m## /\n[33m/'

## Setup
install: ## Runs composer install (or compose create-project if this is the first time the command was run).
	@./docker/bin/setup

check-requirements: ## Checks if all required tools are installed (docker, docker compose, curl...).
	@./docker/bin/check-requirements

## Docker
up: ## Build and start all containers.
	@docker compose up -d --remove-orphans

down: ## Stop and remove all containers.
	@docker compose down --remove-orphans

ps: ## List active containers.
	@docker compose ps

logs: ## Show Docker logs. Pass the parameter "service=" to get logs of a given service. Example: make logs service=elasticsearch
	@$(eval service ?=)
	@docker compose logs --tail=0 --follow $(service)

top: ## Shows all running processes. Pass the parameter "service=" to display the processes of a specific container. Eample: make top service=fpm
	@$(eval service ?=)
	@docker compose top $(service)

images: ## List images used by containers.
	@docker compose images

build: ## Build all images. Only useful if you project uses custom Dockerfiles.
	@docker compose build

## Services
sh: ## Open a shell on the php-cli container. Pass the parameter "service=" to connect to another service. Example: make sh service=redis
	@$(eval service ?= cli)
	@echo "Connecting to container \"$(service)\""
	@if [ "$(service)" = "cli" ]; then $(PHP_CLI) sh; \
	else docker compose exec $(service) sh; fi

db: ## Connect to the Magento database.
	@$(PHP_DATABASE) bash -c 'mysql --user=$$MYSQL_USER --password=$$MYSQL_PASSWORD $$MYSQL_DATABASE'

## CLI commands
composer: ## Run composer. Example: make composer cmd="config --list"
	@$(eval cmd ?=)
	@$(PHP_CLI) composer $(cmd)

magento: ## Run bin/magento. Example: make magento cmd=indexer:reindex
	@$(eval cmd ?=)
	@$(PHP_CLI) bin/magento $(cmd)

## Static Code Analysis
phpcs: ## Run phpcs. Example: make phpcs
	@$(eval cmd ?=)
	@$(PHP_CLI) vendor/bin/phpcs $(cmd)

phpmd: ## Run phpmd. Example: make phpmd cmd="app/code xml phpmd.xml.dist"
	@$(eval cmd ?=)
	@$(PHP_CLI) vendor/bin/phpmd $(cmd)

phpunit: ## Run phpunit. Example: make phpunit
	@$(eval cmd ?=)
	@$(PHP_CLI) vendor/bin/phpunit $(cmd)

phpstan: ## Run phpstan. Example: make phpstan
	@$(eval cmd ?=)
	@$(PHP_CLI) vendor/bin/phpstan $(cmd)

php-cs-fixer: ## Run php-cs-fixer. Example: make php-cs-fixer cmd="fix --config=.php-cs-fixer.dist.php"
	@$(eval cmd ?=)
	@$(PHP_CLI) vendor/bin/php-cs-fixer $(cmd)
