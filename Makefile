.PHONY: help up down restart logs install shell clean drush permissions cache-clear update db-export db-import redis-enable

# ─── Variables ────────────────────────────────────
DOCKER_COMPOSE = docker compose
PHP_CONT       = php

# ─── Help ─────────────────────────────────────────
help: ## Show all available commands
	@echo ""
	@echo "  🚀 Drupal 11 Headless — Make Commands"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-18s\033[0m %s\n", $$1, $$2}'
	@echo ""

# ─── Docker ───────────────────────────────────────
up: ## Start containers
	$(DOCKER_COMPOSE) up -d

down: ## Stop and remove containers
	$(DOCKER_COMPOSE) down

logs: ## Tail container logs
	$(DOCKER_COMPOSE) logs -f

shell: ## Open shell in PHP container
	$(DOCKER_COMPOSE) exec $(PHP_CONT) bash

# ─── Installation ─────────────────────────────────
install: ## 🟢 Full automated Drupal 11 Headless installation (CLEAN)
	@echo "🔥 Starting fresh installation..."
	$(DOCKER_COMPOSE) up -d --build
	$(DOCKER_COMPOSE) exec $(PHP_CONT) ./scripts/install.sh

# ─── Utilities ────────────────────────────────────
drush: ## Run Drush CMD="..."
	$(DOCKER_COMPOSE) exec $(PHP_CONT) ./vendor/bin/drush $(CMD)

permissions: ## Fix files permissions
	$(DOCKER_COMPOSE) exec -u root $(PHP_CONT) chown -R www-data:www-data web/sites/default/files

cache-clear: ## Clear Drupal caches
	$(DOCKER_COMPOSE) exec $(PHP_CONT) ./vendor/bin/drush cr

update: ## Run DB updates
	$(DOCKER_COMPOSE) exec $(PHP_CONT) ./vendor/bin/drush updatedb -y
	$(DOCKER_COMPOSE) exec $(PHP_CONT) ./vendor/bin/drush cr

clean: ## ⚠️  Destroy environmental files & containers
	@echo "⚠️  Warning: This will delete everything!"
	@read -p "Are you sure? [y/N] " ans && [ $${ans:-N} = y ]
	$(DOCKER_COMPOSE) down -v
	@rm -rf web vendor config composer.lock .env.local .gitignore > /dev/null 2>&1 || true

db-export: ## Export local DB to dump.sql.gz
	$(DOCKER_COMPOSE) exec db bash -c "mariadb-dump -u drupal -pdrupal drupal | gzip > /tmp/dump.sql.gz"
	$(DOCKER_COMPOSE) cp db:/tmp/dump.sql.gz ./dump.sql.gz

db-import: ## Import local DB from dump.sql.gz
	$(DOCKER_COMPOSE) cp ./dump.sql.gz db:/tmp/dump.sql.gz
	$(DOCKER_COMPOSE) exec db bash -c "zcat /tmp/dump.sql.gz | mariadb -u drupal -pdrupal drupal"
	$(MAKE) update

redis-enable: ## Activer Redis comme cache backend
	$(DOCKER_COMPOSE) exec $(PHP_CONT) ./vendor/bin/drush en redis -y
	@echo "⚡ Redis enabled. Remember to uncomment redis lines in settings.local.php"
