FROM php:8.4-fpm

RUN apt-get update && apt-get install -y \
    git curl zip unzip supervisor \
    libpq-dev libzip-dev libonig-dev libxml2-dev \
    && docker-php-ext-install pdo pdo_mysql zip mbstring xml \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /var/www/html

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# copy only composer files first
COPY composer.json composer.lock ./

RUN composer install --no-dev --optimize-autoloader --no-interaction --no-progress

# now copy full project
COPY . .

RUN mkdir -p storage/framework/{cache,sessions,views} \
    storage/logs bootstrap/cache

RUN chown -R www-data:www-data storage bootstrap/cache

COPY supervisor.conf /etc/supervisor/conf.d/laravel.conf

EXPOSE 9000

CMD ["supervisord", "-c", "/etc/supervisor/supervisord.conf"]
