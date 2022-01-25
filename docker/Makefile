SHELL := /bin/bash

green = $(shell printf "\e[32;01m$1\e[0m")
format = $(shell printf "%-30s %s" "$(call green,$1)" $2)
args = `arg="$(filter-out $(firstword $(MAKECMDGOALS)),$(MAKECMDGOALS))" && echo $${arg:-${1}}`
service = fpm

.DEFAULT_GOAL:=help
.PHONY: cli cron db magento shell

	%:
		@:

help:
	@echo "Docker commands:"
	@echo "$(call format,docker-build,'Build containers.')"
	@echo "$(call format,docker-up,'Create and start containers.')"
	@echo "$(call format,docker-down,'Stop and remove containers.')"
	@echo
	@echo "CLI commands:"
	@echo "$(call format,composer,'Run composer.')"
	@echo "$(call format,cron,'Start or stop the Magento cronjob.')"

cli:
	@./bin/cli $(call args)

cron:
	@./bin/cron $(call args)

db:
	@./bin/db

magento:
	@./bin/magento $(call args)

shell:
	@echo "Connecting to the container \"$(service)\"."
	@docker-compose exec $(service) /bin/bash

docker-build:
	docker-compose build

docker-up:
	docker-compose up -d --remove-orphans
	#docker-sync start
	#docker-compose -f docker-compose.yml -f docker-compose.dev.yml up -d --remove-orphans

docker-down:
	docker-compose down
	#docker-compose -f docker-compose.yml -f docker-compose.dev.yml down
	#docker-sync stop

docker-ps:
	docker-compose ps
