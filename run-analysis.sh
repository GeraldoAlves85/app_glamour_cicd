#!/bin/bash

echo "🔍 GLAMOUR - ANÁLISE SONARQUBE"
echo "================================"

export SONAR_TOKEN="squ_cf03d8ba771c733a0408d9b69f068d0971a6b805"
export SONAR_HOST_URL="http://localhost:9000"

# Verificar se SonarQube está rodando
if ! curl -s http://localhost:9000 > /dev/null; then
    echo "❌ SonarQube não está rodando!"
    echo "   Execute: docker-compose up -d sonarqube"
    exit 1
fi

echo "✅ SonarQube online!"
echo ""

# Executar análise com Docker
echo "📊 Executando análise de código..."
docker run --rm \
    --network host \
    -e SONAR_HOST_URL="$SONAR_HOST_URL" \
    -e SONAR_TOKEN="$SONAR_TOKEN" \
    -v "$(pwd):/usr/src" \
    -w /usr/src \
    sonarsource/sonar-scanner-cli \
    -Dsonar.projectKey=glamour-ecommerce \
    -Dsonar.projectName="Glamour E-Commerce" \
    -Dsonar.projectVersion=1.0.0 \
    -Dsonar.sources=packages/services/catalog-ms/src \
    -Dsonar.exclusions=**/node_modules/**,**/dist/**,**/*.test.ts \
    -Dsonar.sourceEncoding=UTF-8

echo ""
echo "════════════════════════════════════════════════════════════"
echo "✅ ANÁLISE CONCLUÍDA!"
echo "════════════════════════════════════════════════════════════"
echo ""
echo "🌐 Acesse o dashboard:"
echo "   http://localhost:9000/dashboard?id=glamour-ecommerce"
echo ""
echo "📊 Métricas disponíveis:"
echo "   • Bugs e Vulnerabilidades"
echo "   • Code Smells"
echo "   • Cobertura de Testes"
echo "   • Duplicação de Código"
echo ""
