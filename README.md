# Python Django App For Deploy [~](https://github.com/lucky-whb/django-gunicorn-nginx)

## Product RESTful API in Python with Django.
```
docker build -t lucien/django-app .
```
## Deploy

### Manual deployment ~ Product
**Note：You need to ensure that the name of the directory 
where the wsgi file is located is app, 
refer to the directory description of the django official website, 
or modify the load directory through the option. 
The default port 80 jumps to port 443. The internal 
Django startup port is 8080 but it will be requested by nginx 80 and 443 port proxy. so you need export 443 port**

---

### Version

Python 3.7.2

Django 3.1.2

### Run

#### Normal
```
docker run -d --name myApp lucien/django-app
```

#### Add your Project and your Static File and Export port
```
docker run -d --name myApp -v /yourDir/yourApp:/app -v /youDir/yourStatic:/usr/share/nginx/html -p 80:80 -p 443:443 lucien/django-app
```

#### Before start App if you need install your pip requirement.txt

You need a simple django demo project with your requirement.txt file

Then execute the following command

```
docker exec -it myApp bash
cd /app
pip install -r requirement.txt
```
Replace django demo project, use your project

#### Option

##### Add your nginx conf
```
-v yourDir/yourNginx.conf:/usr/local/nginx/conf/nginx.conf
```

##### Add your start.sh
```
-v yourDir/yourStart.sh:/start.sh
```
**Note：If you change this option, remember to add gunicorn launcher**

**For example: "cd /app && nginx && gunicorn -c /gunicorn.py app.wsgi:application" add this in your bash file end line**

##### Add your gunicorn.py
```
-v yourDir/yourGunicorn.py:/gunicorn.py
```

##### Add your ssl

```
- v yourDir/yourSSl.crt:/etc/nginx_ssl/my.crt
- v yourDir/yourSSl.key:/etc/nginx_ssl/my.key
```

##### Export Port
**Note：If you want change this export port , you need add your nginx.conf**

**The App default Export Port 80 and 443 for http or https**
```
-p yourPort:80
```

#### HTTPS or HTTP

**To enable the http or https function, you need to load your nginx configuration file and map it in the app specified directory, and the certificate under the ssl module needs to be able to be accessed correctly.**

**For example:**

**Http**

```
docker run -d --name myApp -v /yourDir/yourApp:/app -v /youDir/yourStatic:/usr/share/nginx/html -p 80:80 -p 443:443 -v yourDir/yourNginx.conf:/usr/local/nginx/conf/nginx.conf lucien/django-app
```

**Https**

```
docker run -d --name myApp -v /yourDir/yourApp:/app -v /youDir/yourStatic:/usr/share/nginx/html -p 443:443 -v yourDir/yourNginx.conf:/usr/local/nginx/conf/nginx.conf lucien/django-app

```

**Https and Http**

```
docker run -d --name myApp -v /yourDir/yourApp:/app -v /youDir/yourStatic:/usr/share/nginx/html -p 443:443 -p 80:80 -v yourDir/yourNginx.conf:/usr/local/nginx/conf/nginx.conf lucien/django-app
```

### No need Https
*Change your nginx.conf*
```
-v yourDir/yourNginx.conf:/usr/local/nginx/conf/nginx.conf
```

### Default Nginx Conf

```
worker_processes  3;

events {
    worker_connections  1024;
}


http {
    include       mime.types;
    default_type  application/octet-stream;

    sendfile        on;
    keepalive_timeout  65;

    gzip  on;
    gzip_min_length 1k;
    gzip_comp_level 1;
    gzip_types text/plain application/javascript application/x-javascript text/css application/xml text/javascript application/x-httpd-php image/jpeg image/gif image/png application/vnd.ms-fontobject font/ttf font/opentype font/x-woff image/svg+xml;
    gzip_vary on;
    gzip_disable "MSIE [1-6]\.";
    gzip_http_version 1.0;

    server {
        listen 80;
        server_name www.domain.com;
        rewrite ^(.*)$ https://$host$1 permanent;
        location / {
            index index.html index.htm;
        }
    }

     server {
        listen       443 ssl;
        server_name  www.domain.com;
        root html;
        index index.html index.htm;
        ssl_certificate /etc/nginx_ssl/my.crt;
        ssl_certificate_key /etc/nginx_ssl/my.key;
        ssl_session_timeout 5m;
        ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:ECDHE:ECDH:AES:HIGH:!NULL:!aNULL:!MD5:!ADH:!RC4;
        ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
        ssl_prefer_server_ciphers on;
        charset koi8-r;

        location /static {
            alias   /usr/share/nginx/html;
        }

        location / {
            proxy_pass http://localhost:8080;
            proxy_set_header Host $host:$server_port;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Real-PORT $remote_port;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        }
    }
}

```

### Default start.sh

```
#!/usr/bin/bash

cd /app

nginx

gunicorn -c /gunicorn.py app.wsgi:application
```

### Default gunicorn.py

```
import multiprocessing

bind = "0.0.0.0:8080"

workers = multiprocessing.cpu_count() * 2 + 1
```

