FROM nginx:1.15.3

LABEL maintainer="bossaiguo<1058349313@qq.com>"

ENV TIMEZONE Asia/Shanghai

# replace sources.list
RUN sed -i 's/deb.debian.org/mirrors.aliyun.com/g' /etc/apt/sources.list \
    && sed -i 's/security.debian.org/mirrors.aliyun.com/g' /etc/apt/sources.list \
    && cp /usr/share/zoneinfo/${TIMEZONE} /etc/localtime \
    && echo "${TIMEZONE}" > /etc/timezone
# init
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    openssl \
    vim \
    locales \
    expect \
    && rm -rf /var/lib/apt/lists/*

# 替换VIM鼠标状态为非可视状态
RUN sed -i 's/mouse\=a/mouse=v/g' /usr/share/vim/vim80/defaults.vim

RUN echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen && locale-gen

ENV LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8

COPY docker-make-ssl.sh /usr/local/bin/

#RUN ln -s /usr/local/bin/docker-make-ssl.sh /docker-make-ssl.sh
#ENTRYPOINT ["docker-make-ssl.sh"]


EXPOSE 80
EXPOSE 443

STOPSIGNAL SIGTERM

CMD ["nginx", "-g", "daemon off;"]