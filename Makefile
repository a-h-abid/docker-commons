.DEFAULT_GOAL := help

COMPOSE := docker compose

# Extract service names from override files (exclude example)
AVAILABLE_SERVICES := $(sort $(patsubst docker-compose.override.%.yml,%,$(filter-out docker-compose.override.example.yml,$(wildcard docker-compose.override.*.yml))))

# ---------------------------------------------------------------------------
# Setup
# ---------------------------------------------------------------------------

.PHONY: setup
setup: copy-examples networks ## One-command project setup (copy configs + create networks)
	@echo ""
	@echo "Setup complete. Next steps:"
	@echo "  1. Edit .env to choose services (COMPOSE_FILE variable)"
	@echo "  2. Edit .envs/*.env files to configure each service"
	@echo "  3. Run 'make pull' then 'make up'"

.PHONY: copy-examples
copy-examples: ## Copy example config files (.env, docker-compose, .envs/)
	@bash copy-examples.sh
	@echo "Example files copied."

.PHONY: networks
networks: ## Create required Docker networks (common-net, common-traefik-net)
	@docker network create common-net 2>/dev/null || true
	@docker network create common-traefik-net 2>/dev/null || true
	@echo "Docker networks ready."

# ---------------------------------------------------------------------------
# Service lifecycle
# ---------------------------------------------------------------------------

.PHONY: up
up: ## Start services (use SERVICES="mysql redis" to pick specific ones)
ifdef SERVICES
	$(COMPOSE) up -d $(SERVICES)
else
	$(COMPOSE) up -d
endif

.PHONY: down
down: ## Stop and remove all services
	$(COMPOSE) down

.PHONY: stop
stop: ## Stop specific services (use SERVICES="mysql redis")
ifdef SERVICES
	$(COMPOSE) rm -sf $(SERVICES)
else
	$(COMPOSE) down
endif

.PHONY: restart
restart: ## Restart services (use SERVICES="mysql redis" to pick specific ones)
ifdef SERVICES
	$(COMPOSE) restart $(SERVICES)
else
	$(COMPOSE) restart
endif

.PHONY: pull
pull: ## Pull latest images for all configured services
	$(COMPOSE) pull

.PHONY: build
build: ## Build images that require it (use SERVICES="elasticsearch" to pick specific ones)
ifdef SERVICES
	$(COMPOSE) build $(SERVICES)
else
	$(COMPOSE) build
endif

# ---------------------------------------------------------------------------
# Status & logs
# ---------------------------------------------------------------------------

.PHONY: ps
ps: ## Show running services
	$(COMPOSE) ps

.PHONY: logs
logs: ## Tail logs (use SERVICES="mysql" and LINES=200 to customise)
ifdef SERVICES
	$(COMPOSE) logs --tail=$(or $(LINES),100) -f $(SERVICES)
else
	$(COMPOSE) logs --tail=$(or $(LINES),100) -f
endif

# ---------------------------------------------------------------------------
# Validation & health
# ---------------------------------------------------------------------------

.PHONY: validate
validate: ## Validate all docker-compose override files
	@bash validate.sh

# ---------------------------------------------------------------------------
# Cleanup
# ---------------------------------------------------------------------------

.PHONY: clean
clean: ## Stop services, remove volumes and networks
	$(COMPOSE) down -v --remove-orphans
	@docker network rm common-net 2>/dev/null || true
	@docker network rm common-traefik-net 2>/dev/null || true
	@echo "Cleaned up services, volumes and networks."

# ---------------------------------------------------------------------------
# Information
# ---------------------------------------------------------------------------

.PHONY: list
list: ## List all available services
	@echo "Available services:"
	@echo ""
	@printf '  %s\n' $(AVAILABLE_SERVICES)
	@echo ""
	@echo "Start a service: make up SERVICES=\"<name> ...\""

.PHONY: help
help: ## Show this help message
	@echo "Docker Commons — Makefile Commands"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-16s\033[0m %s\n", $$1, $$2}'
	@echo ""
	@echo "Examples:"
	@echo "  make setup                      Initial project setup"
	@echo "  make up                          Start all configured services"
	@echo "  make up SERVICES=\"mysql redis\"   Start only mysql and redis"
	@echo "  make logs SERVICES=\"mysql\"       Follow mysql logs"
	@echo "  make stop SERVICES=\"redis\"       Stop redis only"
	@echo "  make down                        Stop everything"
	@echo "  make list                        Show available services"
