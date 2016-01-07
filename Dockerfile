# Moodle with Postgresql (external)

FROM php:5.6-apache
MAINTAINER Faiz Azhar <gabanz@gmail.com>

# Environment variables
ENV REFRESHED_AT 2016-01-07
ENV DEBIAN_FRONTEND noninteractive
ENV DBHOST localhost
ENV DBNAME postgres
ENV DBUSER postgres
ENV DBPASS postgres
ENV DBPORT 5432
ENV DBDATA /var/lib/postgresql/data
ENV MOODLE_URL localhost

RUN usermod -u 1000 www-data

# Mount Moodle stateful data directory
VOLUME ["/var/www/moodledata"]

# Install dependencies (refer from https://github.com/PortableStudios/docker-php-postgres/)
RUN apt-get -qq update && apt-get -y upgrade && apt-get -y install \
		git \
		php5-pgsql \
		php5-xmlrpc \
        libicu-dev \
        libmcrypt-dev \
        libpq-dev \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libpng12-dev \
		libxml2-dev
#		php-soap
RUN docker-php-ext-install pdo pdo_pgsql intl mbstring zip mcrypt pgsql xmlrpc
RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install gd && docker-php-ext-configure xmlrpc --with-xmlrpc

RUN a2enmod rewrite && a2enmod headers
RUN apachectl configtest

# Enable SSL
# RUN a2enmod ssl && a2ensite default-ssl

# Download from git repository
# RUN cd /tmp && git clone --branch MOODLE_30_STABLE --depth 1 git://git.moodle.org/moodle.git
# RUN mv /tmp/moodle/* &&  /var/www/html/ && chown -R www-data:www-data /var/www/html

# Direct download
ADD https://download.moodle.org/download.php/direct/stable30/moodle-3.0.1.tgz /tmp/moodle-3.0.1.tgz 
RUN cd /tmp && tar zxvf moodle-3.0.1.tgz && mv /tmp/moodle/* /var/www/html/ && chown -R www-data:www-data /var/www/html

COPY moodle-config.php /var/www/html/config.php
COPY php-info.php /var/www/html/info.php

RUN chown -R www-data:www-data /var/www/moodledata && chmod 777 /var/www/moodledata

EXPOSE 80 443
