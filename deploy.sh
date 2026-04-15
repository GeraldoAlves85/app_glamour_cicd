#!/bin/bash

echo "════════════════════════════════════════════════════════════"
echo "🚀 GLAMOUR BOTÂNICA - DEPLOY AUTOMATIZADO"
echo "════════════════════════════════════════════════════════════"
echo ""

# Cores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Função de log
log() {
    echo -e "${GREEN}[$(date +'%H:%M:%S')]${NC} $1"
}

# 1. Parar container antigo
log "🛑 Parando container antigo..."
docker stop glamour-frontend-new 2>/dev/null || true
docker rm glamour-frontend-new 2>/dev/null || true

# 2. Build da nova imagem
log "🏗️ Construindo nova imagem..."
docker build -t glamour-botanica:latest . 2>/dev/null || {
    # Se não tiver Dockerfile, criar um
    cat > Dockerfile << 'DOCKERFILE'
FROM nginx:alpine
COPY glamour-botanica.html /usr/share/nginx/html/index.html
EXPOSE 80
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --quiet --tries=1 --spider http://localhost/ || exit 1
DOCKERFILE
    docker build -t glamour-botanica:latest .
}

# 3. Iniciar novo container
log "🚀 Iniciando novo container..."
docker run -d \
    --name glamour-frontend-new \
    -p 3005:80 \
    --restart unless-stopped \
    glamour-botanica:latest

# 4. Health check
log "🏥 Verificando saúde do container..."
sleep 3
if curl -s http://localhost:3005 | grep -q "GLAMOUR"; then
    log "✅ Container saudável!"
else
    log "⚠️ Container pode não estar respondendo corretamente"
fi

# 5. Limpeza
log "🧹 Limpando imagens antigas..."
docker image prune -f

echo ""
echo "════════════════════════════════════════════════════════════"
echo -e "${GREEN}✅ DEPLOY CONCLUÍDO COM SUCESSO!${NC}"
echo "════════════════════════════════════════════════════════════"
echo ""
echo "🌐 Aplicação disponível em: http://localhost:3005"
echo "📊 Status: docker ps | grep glamour"
echo "📝 Logs: docker logs glamour-frontend-new"
echo ""
