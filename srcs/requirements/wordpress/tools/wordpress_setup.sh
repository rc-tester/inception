#!/bin/bash
set -e

# Função para logs com timestamp
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

log "À espera que o MariaDB inicie..."

# Tentar conexão com root (mais confiável para verificar se MariaDB está pronto)
while ! mysqladmin ping -h mariadb -u root -p${MYSQL_ROOT_PASSWORD} --silent; do
    log "MariaDB ainda não está pronto, a tentar novamente..."
    sleep 3
done

log "MariaDB está pronto!"

# Garantir que o diretório existe
mkdir -p /var/www/wordpress
cd /var/www/wordpress

# Verificar se o WordPress já está instalado
if [ ! -f wp-config.php ]; then
    log "A descarregar WordPress..."
    
    # Descarregar WordPress
    wp core download --allow-root
    
    log "A configurar WordPress..."
    
    # Criar wp-config.php
    wp config create \
        --dbname=${MYSQL_DATABASE} \
        --dbuser=${MYSQL_USER} \
        --dbpass=${MYSQL_PASSWORD} \
        --dbhost=mariadb:3306 \
        --allow-root
    
    # Verificar conexão à base de dados
    log "A verificar conexão à base de dados..."
    if ! wp db check --allow-root; then
        log "ERRO: Não consegue conectar à base de dados!"
        exit 1
    fi
    
    log "A instalar WordPress..."
    wp core install \
        --url=https://${DOMAIN_NAME} \
        --title="${WP_TITLE}" \
        --admin_user=${WP_ADMIN_USER} \
        --admin_password=${WP_ADMIN_PASSWORD} \
        --admin_email=${WP_ADMIN_EMAIL} \
        --skip-email \
        --allow-root
    
    # Criar um utilizador normal
    log "A criar utilizador adicional..."
    wp user create \
        ${WP_USER} \
        ${WP_USER_EMAIL} \
        --role=author \
        --user_pass=${WP_USER_PASSWORD} \
        --allow-root
    
    # Instalar e ativar um tema
    log "A configurar tema..."
    wp theme install twentytwentyone --activate --allow-root
    
    # Configurações extras
    log "A aplicar configurações..."
    wp option update blogdescription "42 School Inception Project" --allow-root
    wp option update permalink_structure "/%postname%/" --allow-root
    
    # Criar um post de exemplo
    log "A criar post de exemplo..."
    wp post create \
        --post_type=post \
        --post_title="Bem-vindo ao Inception!" \
        --post_content="Este é o projeto Inception da 42. WordPress está a funcionar com Docker!" \
        --post_status=publish \
        --post_author=1 \
        --allow-root
    
    log "WordPress instalado com sucesso!"
else
    log "WordPress já está instalado."
fi

# Corrigir permissões
log "A corrigir permissões..."
chown -R www-data:www-data /var/www/wordpress

# Criar diretórios necessários para PHP
mkdir -p /var/lib/php/sessions
chown -R www-data:www-data /var/lib/php/sessions

# Verificar se PHP-FPM pode iniciar
log "A verificar configuração PHP-FPM..."
if ! /usr/sbin/php-fpm7.3 -t; then
    log "ERRO: Configuração PHP-FPM inválida!"
    exit 1
fi

# Iniciar PHP-FPM em foreground
log "A iniciar PHP-FPM..."
exec /usr/sbin/php-fpm7.3 -F