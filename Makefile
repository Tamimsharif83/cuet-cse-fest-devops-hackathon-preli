# Docker Services:
#   up - Start services (use: make up [service...] or make up MODE=prod, ARGS="--build" for options)
#   down - Stop services (use: make down [service...] or make down MODE=prod, ARGS="--volumes" for options)
#   build - Build containers (use: make build [service...] or make build MODE=prod)
#   logs - View logs (use: make logs [service] or make logs SERVICE=backend, MODE=prod for production)
#   restart - Restart services (use: make restart [service...] or make restart MODE=prod)
#   shell - Open shell in container (use: make shell [service] or make shell SERVICE=gateway, MODE=prod, default: backend)
#   ps - Show running containers (use MODE=prod for production)
#
# Convenience Aliases (Development):
#   dev-up - Alias: Start development environment
#   dev-down - Alias: Stop development environment
#   dev-build - Alias: Build development containers
#   dev-logs - Alias: View development logs
#   dev-restart - Alias: Restart development services
#   dev-shell - Alias: Open shell in backend container
#   dev-ps - Alias: Show running development containers
#   backend-shell - Alias: Open shell in backend container
#   gateway-shell - Alias: Open shell in gateway container
#   mongo-shell - Open MongoDB shell
#
# Convenience Aliases (Production):
#   prod-up - Alias: Start production environment
#   prod-down - Alias: Stop production environment
#   prod-build - Alias: Build production containers
#   prod-logs - Alias: View production logs
#   prod-restart - Alias: Restart production services
#
# Backend:
#   backend-build - Build backend TypeScript
#   backend-install - Install backend dependencies
#   backend-type-check - Type check backend code
#   backend-dev - Run backend in development mode (local, not Docker)
#
# Database:
#   db-reset - Reset MongoDB database (WARNING: deletes all data)
#   db-backup - Backup MongoDB database
#
# Cleanup:
#   clean - Remove containers and networks (both dev and prod)
#   clean-all - Remove containers, networks, volumes, and images
#   clean-volumes - Remove all volumes
#
# Utilities:
#   status - Alias for ps
#   health - Check service health
#
# Help:
#   help - Display this help message

.PHONY: help up down build logs restart shell ps dev-up dev-down dev-build dev-logs dev-restart dev-shell dev-ps backend-shell gateway-shell mongo-shell prod-up prod-down prod-build prod-logs prod-restart backend-build backend-install backend-type-check backend-dev db-reset db-backup clean clean-all clean-volumes status health

# Default values
MODE ?= dev
SERVICE ?= backend
ARGS ?=

# Determine compose file based on MODE
ifeq ($(MODE),prod)
	COMPOSE_FILE = docker/compose.production.yaml
	ENV = production
else
	COMPOSE_FILE = docker/compose.development.yaml
	ENV = development
endif

# Docker Compose command
DC = docker compose -f $(COMPOSE_FILE) --env-file .env

# Colors for output
GREEN := \033[0;32m
YELLOW := \033[0;33m
NC := \033[0m # No Color

##@ Help
help: ## Display this help message
	@echo "$(GREEN)Available targets:$(NC)"
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

##@ Docker Services
up: ## Start services (use: make up MODE=prod ARGS="--build")
	@echo "$(GREEN)Starting $(ENV) environment...$(NC)"
	$(DC) up -d $(ARGS)
	@echo "$(GREEN)Services started successfully!$(NC)"

down: ## Stop services (use: make down MODE=prod ARGS="--volumes")
	@echo "$(YELLOW)Stopping $(ENV) environment...$(NC)"
	$(DC) down $(ARGS)
	@echo "$(GREEN)Services stopped successfully!$(NC)"

build: ## Build containers (use: make build MODE=prod)
	@echo "$(GREEN)Building $(ENV) containers...$(NC)"
	$(DC) build $(ARGS)
	@echo "$(GREEN)Containers built successfully!$(NC)"

logs: ## View logs (use: make logs SERVICE=backend MODE=prod)
	$(DC) logs -f $(SERVICE)

restart: ## Restart services (use: make restart MODE=prod)
	@echo "$(YELLOW)Restarting $(ENV) services...$(NC)"
	$(DC) restart
	@echo "$(GREEN)Services restarted successfully!$(NC)"

shell: ## Open shell in container (use: make shell SERVICE=gateway MODE=prod)
	@echo "$(GREEN)Opening shell in $(SERVICE) container...$(NC)"
	$(DC) exec $(SERVICE) sh

ps: ## Show running containers (use: make ps MODE=prod)
	$(DC) ps

##@ Development Aliases
dev-up: ## Start development environment
	@$(MAKE) up MODE=dev ARGS="--build"

dev-down: ## Stop development environment
	@$(MAKE) down MODE=dev

dev-build: ## Build development containers
	@$(MAKE) build MODE=dev

dev-logs: ## View development logs
	$(DC) logs -f

dev-restart: ## Restart development services
	@$(MAKE) restart MODE=dev

dev-shell: ## Open shell in backend container (development)
	@$(MAKE) shell SERVICE=backend MODE=dev

dev-ps: ## Show running development containers
	@$(MAKE) ps MODE=dev

backend-shell: ## Open shell in backend container
	@$(MAKE) shell SERVICE=backend MODE=dev

gateway-shell: ## Open shell in gateway container
	@$(MAKE) shell SERVICE=gateway MODE=dev

mongo-shell: ## Open MongoDB shell
	@echo "$(GREEN)Opening MongoDB shell...$(NC)"
	$(DC) exec mongo mongosh -u $${MONGO_INITDB_ROOT_USERNAME} -p $${MONGO_INITDB_ROOT_PASSWORD} --authenticationDatabase admin

##@ Production Aliases
prod-up: ## Start production environment
	@$(MAKE) up MODE=prod ARGS="--build"

prod-down: ## Stop production environment
	@$(MAKE) down MODE=prod

prod-build: ## Build production containers
	@$(MAKE) build MODE=prod

prod-logs: ## View production logs
	$(DC) logs -f

prod-restart: ## Restart production services
	@$(MAKE) restart MODE=prod

##@ Backend Commands
backend-build: ## Build backend TypeScript
	@echo "$(GREEN)Building backend TypeScript...$(NC)"
	cd backend && npm run build
	@echo "$(GREEN)Backend built successfully!$(NC)"

backend-install: ## Install backend dependencies
	@echo "$(GREEN)Installing backend dependencies...$(NC)"
	cd backend && npm install
	@echo "$(GREEN)Dependencies installed successfully!$(NC)"

backend-type-check: ## Type check backend code
	@echo "$(GREEN)Type checking backend code...$(NC)"
	cd backend && npm run type-check
	@echo "$(GREEN)Type check completed!$(NC)"

backend-dev: ## Run backend in development mode (local, not Docker)
	@echo "$(GREEN)Starting backend in local development mode...$(NC)"
	cd backend && npm run dev

##@ Database
db-reset: ## Reset MongoDB database (WARNING: deletes all data)
	@echo "$(YELLOW)WARNING: This will delete all data in the database!$(NC)"
	@read -p "Are you sure? (yes/no): " confirm && [ "$$confirm" = "yes" ] || (echo "Cancelled." && exit 1)
	@echo "$(YELLOW)Stopping services...$(NC)"
	$(DC) down -v
	@echo "$(GREEN)Database reset complete. Start services with 'make up'$(NC)"

db-backup: ## Backup MongoDB database
	@echo "$(GREEN)Creating MongoDB backup...$(NC)"
	@mkdir -p backups
	$(DC) exec -T mongo mongodump --username=$${MONGO_INITDB_ROOT_USERNAME} --password=$${MONGO_INITDB_ROOT_PASSWORD} --authenticationDatabase=admin --db=$${MONGO_DATABASE} --archive > backups/mongo-backup-$$(date +%Y%m%d-%H%M%S).archive
	@echo "$(GREEN)Backup created in backups/$(NC)"

##@ Cleanup
clean: ## Remove containers and networks (both dev and prod)
	@echo "$(YELLOW)Cleaning up containers and networks...$(NC)"
	docker compose -f docker/compose.development.yaml down
	docker compose -f docker/compose.production.yaml down
	@echo "$(GREEN)Cleanup complete!$(NC)"

clean-all: ## Remove containers, networks, volumes, and images
	@echo "$(YELLOW)WARNING: This will remove all containers, networks, volumes, and images!$(NC)"
	@read -p "Are you sure? (yes/no): " confirm && [ "$$confirm" = "yes" ] || (echo "Cancelled." && exit 1)
	docker compose -f docker/compose.development.yaml down -v --rmi all
	docker compose -f docker/compose.production.yaml down -v --rmi all
	@echo "$(GREEN)Complete cleanup finished!$(NC)"

clean-volumes: ## Remove all volumes
	@echo "$(YELLOW)WARNING: This will delete all data in volumes!$(NC)"
	@read -p "Are you sure? (yes/no): " confirm && [ "$$confirm" = "yes" ] || (echo "Cancelled." && exit 1)
	docker compose -f docker/compose.development.yaml down -v
	docker compose -f docker/compose.production.yaml down -v
	@echo "$(GREEN)Volumes cleaned!$(NC)"

##@ Utilities
status: ps ## Alias for ps

health: ## Check service health
	@echo "$(GREEN)Checking service health...$(NC)"
	@echo "\n$(YELLOW)Gateway Health:$(NC)"
	@curl -s http://localhost:5921/health | jq . || echo "Gateway not responding"
	@echo "\n$(YELLOW)Backend Health (via Gateway):$(NC)"
	@curl -s http://localhost:5921/api/health | jq . || echo "Backend not responding"
	@echo ""


