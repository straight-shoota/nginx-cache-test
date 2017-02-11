sudo ln -sf $(realpath nginx.conf) /etc/nginx/sites-enabled/nginx-cache-test

sudo nginx -t && sudo systemctl reload nginx && echo "Nginx restarted"


