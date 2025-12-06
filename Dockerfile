# Base PHP image
FROM php:8.4-fpm

# Install system dependencies + PHP extensions
RUN apt-get update && apt-get install -y \
    git \
    curl \
    zip \
    unzip \
    supervisor \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libicu-dev \
    libonig-dev \
    libzip-dev \
    libxml2-dev \
    libsqlite3-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install \
        gd \
        bcmath \
        intl \
        pdo \
        pdo_mysql \
        pdo_sqlite \
        zip \
        mbstring \
        dom \
        simplexml \
        xml \
        xmlwriter \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /var/www/html

# Copy Composer binary
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Copy only composer files first for build caching
COPY composer.json composer.lock ./

# Install PHP dependencies without scripts first
RUN composer install --no-dev --optimize-autoloader --no-interaction --no-progress --no-scripts

# Now copy the full application code
COPY . .

# Run composer scripts now that artisan exists
RUN composer dump-autoload --optimize --no-dev && php artisan package:discover --ansi

# Create Laravel writable directories
RUN mkdir -p \
    storage/framework/cache \
    storage/framework/sessions \
    storage/framework/views \
    storage/logs \
    bootstrap/cache

# Chown all storage and bootstrap/cache to www-data
RUN chown -R www-data:www-data storage bootstrap/cache

# Copy Supervisor config
COPY supervisor.conf /etc/supervisor/conf.d/laravel.conf

# Expose PHP-FPM port
EXPOSE 9000

# Start Supervisor (which starts queue worker, scheduler, etc.)
CMD ["supervisord", "-c", "/etc/supervisor/supervisord.conf"]
