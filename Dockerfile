FROM hacklab/php:7.3-apache

COPY entrypoint.sh /

RUN a2enmod rewrite expires
# install the PHP extensions we need
RUN apt-get -qqy update \
    && apt-get install -qqy libpng-dev \
                            libjpeg-dev \
                            libmcrypt-dev \
                            libxml2-dev \
                            libxslt-dev \
			    cron \
			    logrotate \
			    git \
          poppler-utils \
    && rm -rf /var/lib/apt/lists/* \
    && docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr \
    && docker-php-ext-install gd \
                              mysqli \
                              opcache


#First we try to install your extension, it will fail here so force exit code 0 to keep Dockerfile processing.
#We do this to have the extension files downloaded for step 2
RUN docker-php-ext-install zlib; exit 0

#Now we rename the in step 1 downloaded file to desired filename
RUN cp /usr/src/php/ext/zlib/config0.m4 /usr/src/php/ext/zlib/config.m4

#And try to install extension again, this time it works
RUN docker-php-ext-install zlib

RUN docker-php-ext-install soap \
			      xsl \
                              pdo \
			      pdo_mysql \
			      zip

# set recommended PHP.ini settings
# see https://secure.php.net/manual/en/opcache.installation.php
RUN { \
		echo 'opcache.memory_consumption=512'; \
		echo 'opcache.interned_strings_buffer=8'; \
		echo 'opcache.max_accelerated_files=4000'; \
		echo 'opcache.revalidate_freq=60'; \
		echo 'opcache.fast_shutdown=1'; \
		echo 'opcache.max_file_size=0'; \
		echo 'opcache.enable_cli=1'; \
	} > /usr/local/etc/php/conf.d/opcache-recommended.ini


## Install node ##
RUN apt-get update -yq && apt-get upgrade -yq && \
	apt-get install -yq curl git nano

RUN curl -sL https://deb.nodesource.com/setup_13.x | bash -
RUN apt-get install -y nodejs

# Install composer dependencies
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# enable mod_rewrite
RUN a2enmod rewrite

COPY config/php_local.ini /usr/local/etc/php/conf.d/

WORKDIR /var/www/html

# Get all OJS files
RUN git clone https://github.com/pkp/ojs.git . \
    && git checkout ojs-3_1_2-1 \
    && git submodule update --init --recursive


# Get necessary assets from composer
ENV COMPOSER_ALLOW_SUPERUSER 1
RUN cd lib/pkp \
    && composer update \
    && cd ../.. \
    && cd plugins/paymethod/paypal \
    && composer update \
    && cd ../../.. \
    && cd plugins/generic/citationStyleLanguage \
    && composer update \
    && cd ../../..


	# Get and build JS assets
	RUN npm install \
	    && npm run build

RUN cp config.TEMPLATE.inc.php config.inc.php

# Fix permissions for apache
RUN chown -R www-data:www-data .

RUN mkdir /var/www/files \
    && chown -R www-data:www-data /var/www/files


RUN chown www-data:www-data /var/www/html/plugins
