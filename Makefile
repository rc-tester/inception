# Makefile

# Variáveis
DOCKER_COMPOSE = docker-compose
DOCKER_COMPOSE_FILE = ./srcs/docker-compose.yml
DATA_PATH = /home/$(USER)/data

# Cores para output
GREEN = \033[0;32m
RED = \033[0;31m
YELLOW = \033[0;33m
BLUE = \033[0;34m
RESET = \033[0m

all: setup up

setup:
	@echo "$(YELLOW)A criar diretórios de dados...$(RESET)"
	@mkdir -p $(DATA_PATH)/mysql
	@mkdir -p $(DATA_PATH)/wordpress
	@echo "$(GREEN)Diretórios criados!$(RESET)"

up:
	@echo "$(GREEN)A iniciar os containers...$(RESET)"
	@cd srcs && $(DOCKER_COMPOSE) up -d --build
	@echo "$(GREEN)Containers iniciados!$(RESET)"
	@echo "$(YELLOW)Aguarde cerca de 30 segundos para o WordPress configurar...$(RESET)"
	@echo "$(BLUE)Aceda a: https://localhost$(RESET)"
	@echo "$(BLUE)Admin: $(YELLOW)admin / admin42pass$(RESET)"
	@echo "$(BLUE)User: $(YELLOW)user / user42pass$(RESET)"

down:
	@echo "$(RED)A parar os containers...$(RESET)"
	@cd srcs && $(DOCKER_COMPOSE) down
	@echo "$(RED)Containers parados!$(RESET)"

stop:
	@echo "$(RED)A parar os containers...$(RESET)"
	@cd srcs && $(DOCKER_COMPOSE) stop

start:
	@echo "$(GREEN)A iniciar os containers...$(RESET)"
	@cd srcs && $(DOCKER_COMPOSE) start

status:
	@cd srcs && $(DOCKER_COMPOSE) ps

logs:
	@cd srcs && $(DOCKER_COMPOSE) logs -f

logs-db:
	@cd srcs && $(DOCKER_COMPOSE) logs -f mariadb

logs-nginx:
	@cd srcs && $(DOCKER_COMPOSE) logs -f nginx

logs-wp:
	@cd srcs && $(DOCKER_COMPOSE) logs -f wordpress

clean: down
	@echo "$(RED)A limpar imagens...$(RESET)"
	@docker system prune -af
	@echo "$(RED)Limpeza completa!$(RESET)"

fclean: clean
	@echo "$(RED)A remover dados persistentes...$(RESET)"
	@sudo rm -rf $(DATA_PATH)
	@docker volume prune -f
	@echo "$(RED)Limpeza total completa!$(RESET)"

re: fclean all

info:
	@echo "$(BLUE)=== Inception Project Info ===$(RESET)"
	@echo "$(GREEN)URL:$(RESET) https://localhost"
	@echo "$(GREEN)Admin Login:$(RESET) admin / admin42pass"
	@echo "$(GREEN)User Login:$(RESET) user / user42pass"
	@echo "$(GREEN)Database:$(RESET) wordpress_db"
	@echo "$(GREEN)DB User:$(RESET) wpuser / wpuser42pass"
	@echo "$(YELLOW)Volumes:$(RESET) $(DATA_PATH)"

.PHONY: all setup up down stop start status logs logs-db logs-nginx logs-wp clean fclean re info