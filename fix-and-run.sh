#!/bin/bash

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}      CORREÇÃO COMPLETA - CATALOG MS                       ║${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════════════╝${NC}"

# =============================================
# 1. Popular o banco de dados
# =============================================
echo -e "${YELLOW}[1/5] Populando banco de dados com init.sql...${NC}"
docker exec -i glamour-mysql-catalog mysql -uroot -proot123 catalog_db < packages/services/catalog-ms/init.sql 2>/dev/null  {
    echo "Tentando método alternativo..."
    docker cp packages/services/catalog-ms/init.sql glamour-mysql-catalog:/tmp/
    docker exec glamour-mysql-catalog mysql -uroot -proot123 -e "source /tmp/init.sql"
}
echo -e "${GREEN} Banco populado com produtos de maquiagem!${NC}"

# =============================================
# 2. Corrigir productRoutes.ts
# =============================================
echo -e "${YELLOW}[2/5] Corrigindo productRoutes.ts...${NC}"
cat > packages/services/catalog-ms/src/interface/routes/productRoutes.ts << 'EOFROUTES'
import { FastifyInstance, FastifyRequest, FastifyReply } from 'fastify';
import { z } from 'zod';
import prisma from '../../infra/database/prisma';

const PaginationSchema = z.object({
  page: z.coerce.number().int().positive().optional().default(1),
  limit: z.coerce.number().int().positive().max(100).optional().default(20),
});

export default async function productRoutes(fastify: FastifyInstance) {
  
  // GET /api/products
  fastify.get('/', async (request: FastifyRequest, reply: FastifyReply) => {
    try {
      const { page, limit } = PaginationSchema.parse(request.query);
      const skip = (page - 1) * limit;
      
      const [products, total] = await Promise.all([
        prisma.product.findMany({
          skip,
          take: limit,
          orderBy: { createdAt: 'desc' },
          include: { category: true }
        }),
        prisma.product.count()
      ]);
      
      const formattedProducts = products.map(p => ({
        ...p,
        price: Number(p.price),
        compareAtPrice: p.compareAtPrice ? Number(p.compareAtPrice) : null
      }));
      
      return reply.send({
        success: true,
        data: formattedProducts,
        pagination: { page, limit, total, totalPages: Math.ceil(total / limit) }
      });
    } catch (error) {
      request.log.error(error);
      return reply.status(500).send({ success: false, error: 'Internal Server Error' });
    }
  });

  // GET /api/products/featured
  fastify.get('/featured', async (request: FastifyRequest, reply: FastifyReply) => {
    try {
      const products = await prisma.product.findMany({
        where: { isActive: true, isFeatured: true },
        take: 10,
        orderBy: { createdAt: 'desc' }
      });
      
      const formattedProducts = products.map(p => ({
        ...p,
        price: Number(p.price),
        compareAtPrice: p.compareAtPrice ? Number(p.compareAtPrice) : null
      }));
      
      return reply.send({ success: true, data: formattedProducts });
    } catch (error) {
      request.log.error(error);
      return reply.status(500).send({ success: false, error: 'Internal Server Error' });
    }
  });

  // GET /api/products/:id
  fastify.get('/:id', async (request: FastifyRequest<{ Params: { id: string } }>, reply: FastifyReply) => {
    try {
      const id = parseInt(request.params.id);
      const product = await prisma.product.findUnique({
        where: { id },
        include: { category: true }
      });
      
      if (!product) {
        return reply.status(404).send({ success: false, error: 'Product not found' });
      }
      
      const formattedProduct = {
        ...product,
        price: Number(product.price),
        compareAtPrice: product.compareAtPrice ? Number(product.compareAtPrice) : null
      };
      
      return reply.send({ success: true, data: formattedProduct });
    } catch (error) {
      request.log.error(error);
      return reply.status(500).send({ success: false, error: 'Internal Server Error' });
    }
  });

  // GET /api/categories
  fastify.get('/categories', async (request: FastifyRequest, reply: FastifyReply) => {
    try {
      const categories = await prisma.category.findMany({
        where: { isActive: true },
        orderBy: { displayOrder: 'asc' }
      });
      return reply.send({ success: true, data: categories });
    } catch (error) {
      request.log.error(error);
      return reply.status(500).send({ success: false, error: 'Internal Server Error' });
    }
  });

  // GET /api/brands
  fastify.get('/brands', async (request: FastifyRequest, reply: FastifyReply) => {
    try {
      const brands = await prisma.product.findMany({
        where: { isActive: true, brand: { not: null } },
        distinct: ['brand'],
        select: { brand: true },
        orderBy: { brand: 'asc' }
      });
      return reply.send({ success: true, data: brands.map(b => b.brand).filter(Boolean) });
    } catch (error) {
      request.log.error(error);
      return reply.status(500).send({ success: false, error: 'Internal Server Error' });
    }
  });

  // GET /api/stats
  fastify.get('/stats', async (request: FastifyRequest, reply: FastifyReply) => {
    try {
      const [totalProducts, activeProducts, totalCategories] = await Promise.all([
        prisma.product.count(),
        prisma.product.count({ where: { isActive: true } }),
        prisma.category.count()
      ]);
      
      return reply.send({
        success: true,
        data: { totalProducts, activeProducts, totalCategories }
      });
    } catch (error) {
      request.log.error(error);
      return reply.status(500).send({ success: false, error: 'Internal Server Error' });
    }
  });
}
EOFROUTES
echo -e "${GREEN} productRoutes.ts corrigido${NC}"

# =============================================
# 3. Corrigir server.ts (erro de tipo)
# =============================================
echo -e "${YELLOW}[3/5] Corrigindo server.ts...${NC}"
sed -i "s/server.log.error('Error during shutdown:', error);/server.log.error('Error during shutdown: ' + error);/g" packages/services/catalog-ms/src/server.ts
sed -i "s/server.log.error('Failed to start server:', error);/server.log.error('Failed to start server: ' + error);/g" packages/services/catalog-ms/src/server.ts
echo -e "${GREEN} server.ts corrigido${NC}"

# =============================================
# 4. Sincronizar Prisma com banco populado
# =============================================
echo -e "${YELLOW}[4/5] Sincronizando Prisma...${NC}"
cd packages/services/catalog-ms
npx prisma db pull
npx prisma generate
echo -e "${GREEN} Prisma sincronizado${NC}"

# =============================================
# 5. Verificar se tudo está pronto
# =============================================
echo -e "${YELLOW}[5/5] Verificando produtos no banco...${NC}"
docker exec glamour-mysql-catalog mysql -uroot -proot123 -e "SELECT COUNT(*) as total_products FROM catalog_db.products;"
docker exec glamour-mysql-catalog mysql -uroot -proot123 -e "SELECT id, name, price FROM catalog_db.products LIMIT 3;"

echo ""
echo -e "${GREEN}════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}      TUDO PRONTO!                                         ║${NC}"
echo -e "${GREEN}════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE} Para iniciar o servidor:${NC}"
echo -e "   ${YELLOW}cd ~/glamour-test/packages/services/catalog-ms${NC}"
echo -e "   ${YELLOW}npm run dev${NC}"
echo ""
echo -e "${BLUE} Para testar a API:${NC}"
echo -e "   ${YELLOW}curl http://localhost:3001/health${NC}"
echo -e "   ${YELLOW}curl http://localhost:3001/api/products${NC}"
echo ""

