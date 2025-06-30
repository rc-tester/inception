#!/bin/bash
set -e

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

if [ ! -d "/var/lib/mysql/mysql" ]; then
    log "Initializing MariaDB..."

    # Instalar base de dados como mysql user
    mysql_install_db --user=mysql --datadir=/var/lib/mysql
    log "Creating initial database structure..."

    # Iniciar MariaDB temporariamente
    /usr/sbin/mysqld --user=mysql --datadir=/var/lib/mysql --skip-networking &
    MYSQL_PID=$!

    # Esperar que inicie
    sleep 10

    # Configurar base de dados
    mysql -u root << EOF
-- Configurar password do root
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';

-- Criar base de dados
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE} DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;

-- Criar utilizador do WordPress
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';

-- Permitir root conectar remotamente
CREATE USER IF NOT EXISTS 'root'@'%' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;

-- Aplicar mudanças
FLUSH PRIVILEGES;
EOF

    # Parar MariaDB temporário
    kill $MYSQL_PID
    wait $MYSQL_PID

    log "MariaDB database setup complete."
else
    log "MariaDB database already initialized."
fi

# Iniciar MariaDB final
log "Starting MariaDB..."
exec /usr/sbin/mysqld --user=mysql