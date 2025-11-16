FROM php:8.2-apache

# Instalar extensiones PHP necesarias
RUN docker-php-ext-install pdo pdo_mysql mysqli

# Habilitar mod_rewrite para Apache
RUN a2enmod rewrite

# Instalar herramientas adicionales
RUN apt-get update && apt-get install -y \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Configurar el directorio de trabajo
WORKDIR /var/www/html

# Copiar archivos de la aplicación
COPY . /var/www/html/

# Configurar permisos
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html

# Configurar ServerName para evitar el warning
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Configurar Apache para servir desde la raíz
RUN echo '<VirtualHost *:80>\n\
    ServerName localhost\n\
    DocumentRoot /var/www/html\n\
    <Directory /var/www/html>\n\
        Options Indexes FollowSymLinks\n\
        AllowOverride All\n\
        Require all granted\n\
    </Directory>\n\
    ErrorLog ${APACHE_LOG_DIR}/error.log\n\
    CustomLog ${APACHE_LOG_DIR}/access.log combined\n\
</VirtualHost>' > /etc/apache2/sites-available/000-default.conf

# Script de inicio que configura el puerto dinámicamente para Railway
# Railway asigna un puerto dinámico en la variable PORT
# IMPORTANTE: Railway mapea automáticamente su puerto externo al puerto 80 del contenedor
# Por lo tanto, el contenedor siempre debe escuchar en el puerto 80
RUN echo '#!/bin/bash\n\
set -e\n\
echo "=== Iniciando Apache ==="\n\
echo "PORT variable: ${PORT:-not set}"\n\
echo "Apache escuchará en puerto 80 (Railway mapeará su puerto externo a este)"\n\
# Verificar que healthcheck.php existe\n\
if [ -f /var/www/html/healthcheck.php ]; then\n\
    echo "✓ healthcheck.php encontrado"\n\
else\n\
    echo "✗ ERROR: healthcheck.php no encontrado"\n\
fi\n\
# Iniciar Apache\n\
exec apache2-foreground' > /usr/local/bin/start-apache.sh && \
    chmod +x /usr/local/bin/start-apache.sh

# Exponer el puerto 80 (Railway mapeará su puerto dinámico a este)
EXPOSE 80

# Comando por defecto
CMD ["/usr/local/bin/start-apache.sh"]

