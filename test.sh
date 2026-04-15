#!/bin/bash

echo "🧪 GLAMOUR BOTÂNICA - EXECUTANDO TESTES"
echo "════════════════════════════════════════════════════════════"
echo ""

# Teste 1: Frontend responde
echo "📱 Teste 1: Frontend"
if curl -s http://localhost:3005 | grep -q "GLAMOUR"; then
    echo "   ✅ Frontend está respondendo"
else
    echo "   ❌ Frontend não responde"
fi

# Teste 2: API Catalog
echo "📦 Teste 2: API Catalog"
if curl -s http://localhost:3001/health | grep -q "healthy"; then
    echo "   ✅ API Catalog online"
else
    echo "   ❌ API Catalog offline"
fi

# Teste 3: API Cart
echo "🛒 Teste 3: API Cart"
if curl -s http://localhost:3002/health | grep -q "healthy"; then
    echo "   ✅ API Cart online"
else
    echo "   ❌ API Cart offline"
fi

# Teste 4: Banco de dados
echo "🗄️ Teste 4: Banco de dados"
if docker exec glamour-mysql-catalog mysqladmin ping -uroot -proot123 2>/dev/null | grep -q "alive"; then
    echo "   ✅ MySQL Catalog online"
else
    echo "   ❌ MySQL Catalog offline"
fi

# Teste 5: SonarQube
echo "🔒 Teste 5: SonarQube"
if curl -s http://localhost:9000 | grep -q "SonarQube"; then
    echo "   ✅ SonarQube online"
else
    echo "   ❌ SonarQube offline"
fi

echo ""
echo "════════════════════════════════════════════════════════════"
echo "📊 RESULTADO DOS TESTES"
echo "════════════════════════════════════════════════════════════"
