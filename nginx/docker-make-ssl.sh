#!/bin/bash

# set -e

# 生成CA证书
# 替换opensll 证书生成目录
sed -i 's/\.\/demoCA/\/etc\/nginx\/ssl/g' /etc/ssl/openssl.cnf

cd /etc/nginx/

rm -rf /etc/nginx/ssl/
mkdir -p /etc/nginx/ssl/certs/
mkdir -p /etc/nginx/ssl/crl/
mkdir -p /etc/nginx/ssl/private/

/usr/bin/openssl genrsa -out /etc/nginx/ssl/private/ca.pem 2048
/usr/bin/openssl rsa -in /etc/nginx/ssl/private/ca.pem -out /etc/nginx/ssl/private/ca.key
/usr/bin/openssl req -new -key /etc/nginx/ssl/private/ca.pem -out /etc/nginx/ssl/private/ca.csr -subj "/C=CN/ST=myprovince/L=mycity/O=myorganization/OU=mygroup/CN=myCA"
/usr/bin/openssl x509 -req -days 365 -sha1 -extensions v3_req -signkey /etc/nginx/ssl/private/ca.pem -in /etc/nginx/ssl/private/ca.csr -out /etc/nginx/ssl/certs/ca.cer


# 生成服务端证书
/usr/bin/openssl genrsa -out /etc/nginx/ssl/private/server.pem 2048
/usr/bin/openssl rsa -in /etc/nginx/ssl/private/server.pem -out /etc/nginx/ssl/private/server.key
/usr/bin/openssl req -new -key /etc/nginx/ssl/private/server.pem -out /etc/nginx/ssl/private/server.csr -subj "/C=CN/ST=myprovince/L=mycity/O=myorganization/OU=mygroup/CN=myServer"
/usr/bin/openssl x509 -req -days 365 -sha1 -CA /etc/nginx/ssl/certs/ca.cer -CAkey /etc/nginx/ssl/private/ca.pem -CAserial /etc/nginx/ssl/ca.srl -CAcreateserial  -in /etc/nginx/ssl/private/server.csr -out /etc/nginx/ssl/certs/server.cer

#生成客户端证书
/usr/bin/openssl genrsa  -out /etc/nginx/ssl/private/client.pem 2048
/usr/bin/openssl rsa -in /etc/nginx/ssl/private/client.pem -out /etc/nginx/ssl/private/client.key
/usr/bin/openssl req -new -key /etc/nginx/ssl/private/client.pem -out /etc/nginx/ssl/private/client.csr -subj "/C=CN/ST=myprovince/L=mycity/O=myorganization/OU=mygroup/CN=myClient"
/usr/bin/openssl x509 -req -days 365 -sha1 -CA /etc/nginx/ssl/certs/ca.cer -CAkey /etc/nginx/ssl/private/ca.pem -CAserial /etc/nginx/ssl/ca.srl -in /etc/nginx/ssl/private/client.csr -out /etc/nginx/ssl/certs/client.cer

# 导出证书
password='8888'
/usr/bin/expect <<-EOF
set timeout 30
spawn /usr/bin/openssl pkcs12 -export -clcerts -inkey /etc/nginx/ssl/private/client.pem -in /etc/nginx/ssl/certs/client.cer -out /etc/nginx/ssl/certs/client.p12
expect "*Password*"
send "$password\r"
sleep 1
expect "*Password*"
send "$password\r"
sleep 1
spawn /usr/bin/openssl pkcs12 -export -clcerts -inkey /etc/nginx/ssl/private/server.pem -in /etc/nginx/ssl/certs/server.cer -out /etc/nginx/ssl/certs/server.p12
expect "*Password*"
send "$password\r"
sleep 1
expect "*Password*"
send "$password\r"
interact
expect eof
EOF
