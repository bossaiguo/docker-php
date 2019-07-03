FROM php:7.2-fpm

LABEL maintainer="bossaiguo<1058349313@qq.com>"

ENV TIMEZONE Asia/Shanghai
ENV SWOOLE_VERSION 4.0.3
ENV PHALCON_VERSION 3.4.1

# replace sources.list
RUN sed -i 's/deb.debian.org/mirrors.aliyun.com/g' /etc/apt/sources.list \
    && sed -i 's/security.debian.org/mirrors.aliyun.com/g' /etc/apt/sources.list \
    && cp /usr/share/zoneinfo/${TIMEZONE} /etc/localtime \
    && echo "${TIMEZONE}" > /etc/timezone
# init
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
    curl \
    wget \
    zip \
    unzip \
    vim \
    git \
    locales \
    procps \
    libz-dev \
    libpq-dev \
    libjpeg-dev \
    libpng-dev \
    libfreetype6-dev \
    libssl-dev \
    libmcrypt-dev \
    libmemcached-dev \
    libtool \
    libicu-dev \
    libxml2 \
    libxml2-dev \
    libgmp3-dev \
    libevent-dev \
    libzip-dev \
    zlib1g-dev \
    libldap2-dev \
    libbz2-dev \
    libjpeg62-turbo-dev \
    libtidy-dev \
    libsqlite3-dev \
    libsqlite3-0 \
    tmux \
    keychain \
    supervisor \
    && mkdir -p /etc/supervisord.d/log \
    && mkdir -p /etc/supervisord.d/conf \
    && rm -rf /var/lib/apt/lists/*

# 替换VIM鼠标状态为非可视状态
RUN sed -i 's/mouse\=a/mouse=v/g' /usr/share/vim/vim80/defaults.vim

RUN echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen && locale-gen

ENV LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8

# install hiredis
 RUN wget --no-check-certificate https://gitee.com/oschina/hiredis/repository/archive/v0.13.3.zip -O hiredis.zip \
    && mkdir -p hiredis \
    && unzip hiredis.zip \
    && rm hiredis.zip \
    && ( \
        cd hiredis \
        && make -j$(nproc) \
        && make install \
        && ldconfig \
    ) \
    && rm -r hiredis

# install php extentions
RUN pecl channel-update pecl.php.net \
    && docker-php-ext-configure gd \
    --with-jpeg-dir=/usr/lib \
    --with-freetype-dir=/usr/include/freetype2 \
    --with-zlib-dir=/usr \
    && docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/ \
    && docker-php-ext-install -j$(nproc) dba bz2 calendar ldap zip json tidy xml pdo_sqlite bcmath mysqli pdo_mysql gd sockets pcntl intl soap gmp \
    && pecl install msgpack \
    && docker-php-ext-enable msgpack \
    && pecl install seaslog \
    && docker-php-ext-enable seaslog \
# 一般情况，不需要用户变量缓存，所以注释掉安装apcu
#    && printf "\n" | pecl install apcu \
#    && docker-php-ext-enable apcu \
#    && pecl install mongodb \
#    && docker-php-ext-enable mongodb \
#    && pecl install memcached \
#    && docker-php-ext-enable memcached \
    && pecl install redis \
    && docker-php-ext-enable redis \
    && pecl install inotify \
    && docker-php-ext-enable inotify \
    && pecl install grpc \
    && docker-php-ext-enable grpc \
    && echo "no\r\/usr/local/php-event/\ryes"|pecl install event \
    && docker-php-ext-enable event \
    && pecl clear-cache

# install swoole extention
RUN wget --no-check-certificate https://gitee.com/swoole/swoole/repository/archive/v${SWOOLE_VERSION}.zip -O swoole.zip \
    && mkdir -p swoole \
    && unzip swoole.zip \
    && rm swoole.zip \
    && ( \
        cd swoole \
        && phpize \
        && ./configure --enable-async-redis --enable-mysqlnd --enable-openssl \
        && make -j$(nproc) \
        && make install \
    ) \
    && rm -r swoole \
    && docker-php-ext-enable swoole


# install composer
RUN curl -sS https://install.phpcomposer.com/installer | php \
    && mv composer.phar /usr/local/bin/composer \
    && composer self-update --clean-backups \
    && composer config -g repo.packagist composer https://packagist.laravel-china.org

# install supervior
COPY supervisord.conf /etc/supervisord.conf

# 对Seaslog默认存储目录增加www-data owner && 对Php默认bash登陆目录赋予www-data:www-data owner
RUN chown -R www-data:www-data /var/log/www && chown -R www-data:www-data /var/www

EXPOSE 9000 5200
ENTRYPOINT ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisord.conf"]