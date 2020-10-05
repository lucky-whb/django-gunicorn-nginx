FROM scratch
ADD centos-7-docker.tar.xz /

LABEL org.label-schema.schema-version = "1.0" \
    org.label-schema.name="Django" \
    org.label-schema.vendor="Haibo.Wang" \
    org.label-schema.license="Haibo.Wang-Django" \
    org.label-schema.build-date="20190618"

COPY CentOS-Base.repo /

COPY pip.conf /.pip/pip.conf

ADD Python-3.7.2.tgz /

ADD nginx-1.15.1.tar.gz /

WORKDIR Python-3.7.2/

RUN /usr/bin/rm -rf /etc/yum.repos.d/* && \
    mv /CentOS-Base.repo /etc/yum.repos.d/ && \
    yum clean all && \
    yum makecache && \
    yum upgrade -y && \
    yum install zlib-devel bzip2-devel openssl-devel ncurses-devel  tk-devel gcc gcc-c++ make libffi-devel perl-devel perl-ExtUtils-Embed -y && \
    ./configure --prefix=/usr/local/python3 && \
    make && make install && \
    /usr/bin/rm -rf /usr/bin/python && \
    ln -s /usr/local/python3/bin/python3 /usr/bin/python && \
    ln -s /usr/local/python3/bin/pip3 /usr/bin/pip && \
    pip config --global set global.index-url https://mirrors.aliyun.com/pypi/simple/ && \
    pip config --global set install.trusted-host mirrors.aliyun.com && \
    pip install --upgrade pip && \
    pip install cryptography

WORKDIR /nginx-1.15.1/

RUN ./configure --prefix=/usr/local/nginx --with-pcre --with-http_v2_module --with-http_ssl_module --with-http_realip_module --with-http_addition_module --with-http_sub_module --with-http_dav_module --with-http_flv_module --with-http_mp4_module --with-http_gunzip_module --with-http_gzip_static_module --with-http_random_index_module --with-http_secure_link_module --with-http_stub_status_module --with-http_auth_request_module --with-mail --with-mail_ssl_module --with-file-aio --with-http_v2_module --with-threads --with-stream --with-stream_ssl_module && \
    make && make install && \
    ln -s /usr/local/nginx/sbin/nginx /usr/bin/nginx && \
    nginx

WORKDIR /

EXPOSE 80

EXPOSE 443

COPY start.sh start.sh

COPY gunicorn.py /

COPY requirement.txt /

RUN /usr/bin/rm -rf Python-3.7.2/ && \
    mkdir app && \
    pip install gunicorn && \
    ln -s /usr/local/python3/bin/gunicorn /usr/bin/gunicorn && \
    /usr/bin/pip install -r /requirement.txt && \
    /usr/bin/rm -rf /requirement.txt && \
    /usr/bin/rm -rf /nginx-1.15.1 && \
    /usr/bin/rm -rf /usr/local/nginx/conf/nginx.conf

COPY app/wsgi.py /app/app/wsgi.py

COPY app/urls.py /app/app/urls.py

COPY app/settings.py /app/app/settings.py

COPY nginx.conf /usr/local/nginx/conf/nginx.conf

COPY nginx_ssl/my.crt /etc/nginx_ssl/my.crt

COPY nginx_ssl/my.key /etc/nginx_ssl/my.key

ENV PYTHON_VERSION Python-3.7.2

ENV HOME app/

ENV PYTHON_PATH /usr/bin/python

ENV PORT 80

ENV NGINX_VERSION nginx-1.15.1

ENV NGINX_PATH /usr/bin/nginx

ENV NGINX_CONFIG_PATH /usr/local/nginx/conf/nginx.conf

CMD ["./start.sh"]
