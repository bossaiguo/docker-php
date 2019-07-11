#  手牵手一起使用 docker 搭建 PHP 环境，并使用 supervisor 管理你的 swoole 进程

## 使用本环境的一些基本说明

- 请配置docker的Registry mirrors为中国大陆的 daocloud.io（加速器）
- 使用 **docker-compose up -d** 快速搭建php环境


## 使用方法

### 基础配置
1. 安装Docker（官方默认会自带docker-compose 工具）, 已经安装过的可以跳过此步
2. 对Docker Machine 设置里，配置`Setting->Daemon->Registry mirrors`,增加加速器URL，比如http://xxxx.m.daocloud.io
3. 对Docker Machine 设置里，配置`Setting->Shared Drives(Windows)/File Sharing(Mac)`, 


### Docker-php使用
- 复制example.env到同级目录下，并重命名.env，命令操作 
```shell
cp ./example.env ./.env
```
- 【必】修改.env文件的配置。`LOCAL_STOARGE_PATH`=设置为此github clone的根目录。 比如/var/www/html/docker-php
- 【必】修改.env文件的配置。`LOCAL_WEB_PATH`=设置为你开发项目的基础根目录, 比如/var/www/html/docker-php/www
- 【必】启动所有命令行执行
```shell
docker-compose up -d
```

### Nginx使用
- 多个虚拟站点的配置，直接参考nginx/conf.d/demo.cfg， 复制粘贴demo.cfg在同目录下并重名为site1.conf, 并根据注释修改目录路径（以容器目录为准）,重命名文件必须以`conf`扩展名结尾, 举例命令行
```shell
cp ./nginx/conf.d/demo.cfg ./nginx/conf.d/site1.conf
```
- 开启HTTPS支持。 第一次进入nginx容器，命令行
```shell
docker-compose exec nginx bash
# 自动化生成相关证书，生成目录在容器目录/etc/nginx/ssl
sh /usr/local/bin/docker-make-ssl.sh
# 拷贝容器的所有证书到宿主机nginx/ca目录下
cp -R /etc/nginx/ssl /etc/nginx/ca
```
然后配置你的nginx虚拟站点conf，取消相关ssl_注释即可，默认开放443:443映射
- 使用动态扩展库方法，复制nginx/my_modules/xxxx.so 文件到nginx容器里/etc/nginx/module/内，并修改nginx.conf文件，在worker_processes下一行追加 `load_module modules/xxxx.so;`，可以参考conf.d/nginx.default配置.

### PHP配置
- 【Seaslog】的配置范本文件在宿主机php/ext/ini/seaslog.ini里，根据注释复制一下，然后进入PHP容器修改容器内的文件`/usr/local/etc/php/conf.d/docker-php-ext-seaslog.ini` 即可, 命令如下
```shell
# 进入PHP容器
docker-compose exec php bash
# 修改容器内的seaslog扩展配置
vi /usr/local/etc/php/conf.d/docker-php-ext-seaslog.ini
```


## 环境构成

将 `php-fpm` 和 `nginx` 容器分开，通过 `php:9000` 端口通信

### php

php镜像来自官方 `php:fpm`，目前最新稳定版本是 `7.2.8`

在此基础上添加了以下等扩展：

- swoole-4.0.3
- redis/hiredis
- mysqli
- pdo_mysql
- mongodb
- bz2
- dba
- GD
- zip
- pdo_sqlite
- memcached
- bcmath
- openssl
- mbstring
- sockets
- event
- posix
- pcntl
- intl
- xml
- tidy
- json
- ldap
- calendar
- soap
- gmp
- msgpack
- inotify
- grpc
- seaslog
- molten
- zlib
- apcu (可选)
- ...


手动添加了 `composer` 并替换了国内源，修改了时区（`Asia/Shanghai`）

### nginx

直接使用的 `nginx:latest` 镜像,需要挂载自己的PHP项目工作目录，并配置nginx/conf.d里各个站点
可以支持HTTPS 加密协议访问（单向、双向）

### mongodb

直接使用的 `mongodb:latest` 镜像，根据具体情况修改 `/data/mongodb` 本地映射的数据库文件夹，如不需要可注释掉，其他数据库同理。
Windows 磁盘是NTFS/FAT32，不支持Ext4大文件，不能挂载，需要注释挂载， Windows下无解

### ElasticSearch

这里强制使用ES5.5.2版本。 如果需要安装IK,请自行配置容器插件目录(`/usr/share/elasticsearch/plugins`)

### Beanstalk
包含Beanstalkd + Aurora, 进入容器执行`/usr/local/aurora/aurora -c /usr/local/aurora/conf/aurora.toml`, 就可以启动Aurora


### supervisor
配置文件：/docker-php/supervisord.conf
启动项目进程：/docker-php/supervisor/conf
启动日志： /docker/log/supervisor


## 常用运行

```sh
$ cd docker-php/
// 后台运行
$ docker-compose up -d
// 进入php容器bash环境
$ docker-compose exec php bash
```
