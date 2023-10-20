FROM php:8.1-fpm

# Setup user as root
USER root

WORKDIR /var/www/html

# Install environment dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        nginx \
        libpq-dev \
        libzip-dev \
        zip \
        unzip \
        curl \
        supervisor && \
    rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-install \
    pdo_mysql \
    pdo_pgsql \
    zip

# Copy files
COPY . /var/www/html

# Copy configuration files for php and nginx
COPY ./docker/local.ini /usr/local/etc/php/local.ini
COPY ./docker/nginx.conf /etc/nginx/nginx.conf

# Setup composer and laravel
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install application dependencies
RUN composer install --no-dev --no-interaction --no-progress --optimize-autoloader

# Generate security key
RUN php artisan key:generate

# Optimizing Configuration loading
RUN php artisan config:cache

# Optimizing Route loading
RUN php artisan route:cache

# Optimizing View loading
RUN php artisan view:cache

# Set permissions
RUN chown -R www-data:www-data /var/www/html && \
    chmod -R 755 /var/www/html/storage

# Expose port
EXPOSE 8080

# Start
CMD ["sh", "-c", "php-fpm -D && nginx -g 'daemon off;'"]