#!/usr/bin/bash

cd /app

nginx

gunicorn -c /gunicorn.py app.wsgi:application
