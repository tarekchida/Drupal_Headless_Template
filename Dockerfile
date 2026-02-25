FROM php:8.3-fpm-alpine

# Install essential alpine packages and PHP extensions for Drupal 11
RUN apk add --no-cache \
    curl \
    git \
    build-base \
    zlib-dev \
    libxml2-dev \
    freetype-dev \
    libpng-dev \
    libjpeg-turbo-dev \
    icu-dev \
    oniguruma-dev \
    postgresql-dev \
    autoconf \
    bash \
    mysql-client

# Configure and install PHP extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
    gd \
    pdo \
    pdo_mysql \
    opcache \
    intl \
    mbstring \
    xml \
    bcmath \
    && pecl install redis \
    && docker-php-ext-enable redis

# Setup Opcache settings recommended for Drupal
RUN { \
    echo 'opcache.memory_consumption=256'; \
    echo 'opcache.interned_strings_buffer=8'; \
    echo 'opcache.max_accelerated_files=20000'; \
    echo 'opcache.revalidate_freq=2'; \
    echo 'opcache.fast_shutdown=1'; \
    echo 'opcache.enable_cli=1'; \
    } > /usr/local/etc/php/conf.d/opcache-recommended.ini

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/local/bin/

# Set working directory to the project root
WORKDIR /var/www/html

CMD ["php-fpm"]
