#!/bin/bash

echo "════════════════════════════════════════════════════════════"
echo " GLAMOUR BOTÂNICA - DEPLOY LOCAL"
echo "════════════════════════════════════════════════════════════"

# Cores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

# 1. Build
echo -e "\n${BLUE} Construindo imagem...${NC}"
docker build -t glamour-botanica:local .

# 2. Parar container antigo
echo -e "\n${BLUE}🛑 Parando container antigo...${NC}"
docker stop glamour-local 2>/dev/null  true
docker rm glamour-local 2>/dev/null  true

# 3. Iniciar novo container
echo -e "\n${BLUE} Iniciando container...${NC}"
docker run -d \
    --name glamour-local \
    -p 3005:80 \
    --restart unless-stopped \
    glamour-botanica:local

# 4. Health check
echo -e "\n${BLUE}🏥 Verificando saúde...${NC}"
sleep 3
if curl -s http://localhost:3005  grep -q "GLAMOUR"; then
    echo -e "${GREEN} Container saudável!${NC}"
else
    echo "⚠ Container pode não estar respondendo"
fi

echo ""
echo "════════════════════════════════════════════════════════════"
echo -e "${GREEN} DEPLOY LOCAL CONCLUÍDO!${NC}"
echo "════════════════════════════════════════════════════════════"
echo ""
echo "🌐 Acesse: http://localhost:3005"
echo " Status: docker ps  grep glamour"
echo " Logs: docker logs glamour-local"
