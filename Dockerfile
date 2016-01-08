# Moodle with Postgresql (external)
# Version: 0.2

FROM php:5.6-apache
MAINTAINER Faiz Azhar <gabanz@gmail.com>

# Environment variables (can be changed on docker run with -e)
ENV REFRESHED_AT 2016-01-08
ENV DEBIAN_FRONTEND noninteractive
ENV MOODLE_URL localhost

# DB
ENV DBHOST localhost
ENV DBNAME postgres
ENV DBUSER postgres
ENV DBPASS postgres
ENV DBPORT 5432
ENV DBDATA /var/lib/postgresql/data

# Apache
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_PID_FILE /var/run/apache2.pid
ENV APACHE_RUN_DIR /var/run/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_SERVERADMIN webmaster@localhost
ENV APACHE_SERVERNAME localhost
ENV APACHE_SERVERALIAS docker.localhost
ENV APACHE_DOCUMENTROOT /var/www

RUN usermod -u 1000 www-data

# Mount Moodle stateful data directory
VOLUME ["/var/www/moodledata"]

RUN chown -R www-data:www-data /var/www/moodledata \
	&& chmod 777 /var/www/moodledata

# Install dependencies
RUN apt-get -qq update && apt-get -y upgrade && apt-get -y install \
		git \
		php5-pgsql \
        libicu-dev \
        libmcrypt-dev \
        libpq-dev \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libpng12-dev \
		libxml2-dev \
		ssl-cert 
		
RUN docker-php-ext-install \
		pdo \
		pdo_pgsql \
		gd \
		intl \
		mbstring \
		zip \
		mcrypt \
		pgsql \
		xmlrpc \
		opcache \
		soap
		
RUN docker-php-ext-configure gd \
	--with-freetype-dir=/usr/include/ \
	--with-jpeg-dir=/usr/include/
	
RUN a2enmod rewrite && a2enmod headers
RUN a2enmod ssl && a2ensite default-ssl
RUN apachectl configtest

# Download from git repository
# RUN cd /tmp && git clone --branch MOODLE_30_STABLE --depth 1 git://git.moodle.org/moodle.git
# RUN mv /tmp/moodle/* &&  /var/www/html/ && chown -R www-data:www-data /var/www/html

# Direct download
ADD https://download.moodle.org/download.php/direct/stable30/moodle-3.0.1.tgz /tmp/moodle-3.0.1.tgz 
RUN cd /tmp \
	&& tar zxvf moodle-3.0.1.tgz \
	&& mv /tmp/moodle/* /var/www/html/ \
	&& chown -R www-data:www-data /var/www/html

COPY moodle-config.php /var/www/html/config.php
COPY php-info.php /var/www/html/info.php

EXPOSE 80 443
#USER www-data