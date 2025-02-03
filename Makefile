define HEADER
######### MAGENTO 2 DOCKER ENVIRONMENT ##########
endef

export HEADER

all: help

.DEFAULT_GOAL := help

include .env

# Last-Resort Default Rules
%::
	@echo $@

docker-up: ## Up
	make warden-up
	@echo Warden: Start the project environment
	warden env up -d
docker-destroy: ## Destroy (stop and remove containers, networks, and services)
	@echo Warden: Environment Down
	warden env rm -f
	warden env down -v --remove-orphans
docker-halt: ## Halt
	@echo Warden: Environment Stop
	warden env stop
docker-build: ## Build
	@echo Warden: Environment Pull and Build
	warden env pull && warden env up -d --force-recreate --build
warden-up: ## Initialise Warden global services
	@echo Warden: Initialise Warden global services
	warden svc up
flush-varnish: ## Flush Varnish cache
	@echo Varnish: Flusing Varnish - ensure Varnish container is enabled otherwise this will error
	warden env exec varnish bash -lc 'varnishadm "ban req.http.host == ${TRAEFIK_DOMAIN}"'
flush-redis: ## Flush Redis cache
	@echo Warden: Flush Redis
	warden env exec -T redis redis-cli flushall
logs-nginx-php: ## Tail environment nginx and php logs
	@echo Tail environment nginx and php logs
	warden env logs --tail 0 -f nginx php-fpm php-debug
logs-varnish: ## Tail environmment varnish logs
	@echo Tail environment varnish logs - ensure Varnish container is enabled otherwise this will errror
	warden env exec -T varnish varnishlog
warden-view-dc: ## Display compiled docker-compose.yml for environment
	warden env config
db-dump: ## Create Magento dev database dump to backfill directory
	./tools/magento-db-dump.sh
db-import: ## Import the backfill/dump.sql.gz database
	./tools/magento-db-import.sh
set-default-config: ## Set the default Magento 2 configurations
	./tools/set-default-config.sh

help:
	@echo "$$HEADER"
	@echo Commands start with make e.g. make docker-up
	@grep -hE '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) |\
		sort |\
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'
