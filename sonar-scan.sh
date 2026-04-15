#!/bin/bash

echo "🔍 Iniciando análise SonarQube..."

# Verificar se SonarQube está rodando
if ! curl -s http://localhost:9000 > /dev/null; then
    echo "❌ SonarQube não está rodando!"
    echo "   Execute: docker-compose up -d sonarqube"
    exit 1
fi

# Instalar SonarScanner se não existir
if ! command -v sonar-scanner &> /dev/null; then
    echo "📦 Instalando SonarScanner..."
    npm install -g sonarqube-scanner
fi

# Executar análise
echo "📊 Executando análise de código..."
sonar-scanner \
    -Dsonar.host.url=http://localhost:9000 \
    -Dsonar.login=admin \
    -Dsonar.password=admin

echo ""
echo "✅ Análise concluída!"
echo "🌐 Acesse: http://localhost:9000"
echo "   Login: admin / admin"
echo "   Projeto: glamour-ecommerce"
