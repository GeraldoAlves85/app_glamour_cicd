#!/bin/bash
echo " Executando análise SonarQube..."

# Verificar se tem token
if [ -z "$SONAR_TOKEN" ]; then
    echo "Gerando novo token..."
    TOKEN=$(curl -s -X POST -u admin:admin "http://localhost:9000/api/user_tokens/generate?name=glamour"  grep -o '"token":"[^"]*"'  cut -d'"' -f4)
    
    if [ -n "$TOKEN" ]; then
        export SONAR_TOKEN=$TOKEN
        echo " Token: $TOKEN"
    else
        echo "⚠ Acesse http://localhost:9000 e gere um token manualmente"
        echo "   Login: admin / Senha: admin"
        echo "   Account > Security > Generate Token"
        exit 1
    fi
fi

# Executar scanner
docker run --rm \
    -e SONAR_HOST_URL="http://host.docker.internal:9000" \
    -e SONAR_TOKEN="$SONAR_TOKEN" \
    -v "$(pwd):/usr/src" \
    sonarsource/sonar-scanner-cli

echo ""
echo " Análise concluída!"
echo "🌐 Acesse: http://localhost:9000/dashboard?id=glamour-ecommerce"
