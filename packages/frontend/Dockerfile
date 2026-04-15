FROM nginx:alpine

# Copiar o HTML
COPY index.html /usr/share/nginx/html/index.html

# Criar configuração do Nginx com proxy reverso CORRETO
RUN echo 'server { \
    listen 3005; \
    server_name localhost; \
    \
    location / { \
        root /usr/share/nginx/html; \
        index index.html; \
        try_files $uri $uri/ /index.html; \
    } \
    \
    location /api/catalog/ { \
        proxy_pass http://catalog-ms:3001/api/; \
        proxy_set_header Host $host; \
        proxy_set_header X-Real-IP $remote_addr; \
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for; \
        proxy_set_header X-Forwarded-Proto $scheme; \
        \
        add_header Access-Control-Allow-Origin * always; \
        add_header Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS" always; \
        add_header Access-Control-Allow-Headers "Content-Type, Authorization" always; \
        \
        if ($request_method = OPTIONS) { \
            return 204; \
        } \
    } \
    \
    location /api/cart/ { \
        proxy_pass http://cart-ms:3002/api/; \
        proxy_set_header Host $host; \
        proxy_set_header X-Real-IP $remote_addr; \
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for; \
        \
        add_header Access-Control-Allow-Origin * always; \
        add_header Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS" always; \
        add_header Access-Control-Allow-Headers "Content-Type, Authorization" always; \
        \
        if ($request_method = OPTIONS) { \
            return 204; \
        } \
    } \
}' > /etc/nginx/conf.d/default.conf

EXPOSE 3005
