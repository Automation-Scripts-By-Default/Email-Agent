# Base image
FROM php:8.3-fpm

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    zip \
    unzip \
    supervisor \
    libpq-dev \
    libzip-dev \
    libonig-dev \
    libxml2-dev \
    && docker-php-ext-install pdo pdo_mysql zip mbstring xml \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /var/www/html

# Copy composer from official image (optional, but common)
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Copy application files
COPY . /var/www/html

# Install dependencies (optimize for production)
RUN composer install --no-dev --optimize-autoloader --no-interaction --no-progress

# Laravel storage & cache directories
RUN mkdir -p storage/framework/cache \
    storage/framework/sessions \
    storage/framework/views \
    storage/logs \
    bootstrap/cache \
    && chown -R www-data:www-data /var/www/html

# Copy Supervisor config
COPY supervisor.conf /etc/supervisor/conf.d/laravel.conf

# Expose PHP-FPM port
EXPOSE 9000

# Start Supervisor (which will start schedule:work, etc.)
CMD ["supervisord", "-c", "/etc/supervisor/supervisord.conf"]
