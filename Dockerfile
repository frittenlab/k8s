FROM php:7.2-apache
COPY src/ /var/www/html/
COPY config/php.ini /usr/local/etc/php/
RUN chown -R www-data: /var/www/html
RUN a2enmod rewrite 
RUN apt-get update && apt-get install -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libpng-dev \
        libicu-dev \
        libxml2-dev \
        vim \
        wget \
        zlib1g-dev \
        unzip \
        curl \
        libpcre3-dev \
        libcurl3-dev \
    && pecl install redis-3.1.5 \
    && docker-php-ext-enable redis \
    && docker-php-ext-install -j$(nproc) iconv intl xml soap opcache pdo pdo_mysql mysqli mbstring curl zip \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd
