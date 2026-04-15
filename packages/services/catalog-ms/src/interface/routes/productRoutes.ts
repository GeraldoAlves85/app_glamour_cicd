import { FastifyInstance, FastifyRequest, FastifyReply } from 'fastify';
import { z } from 'zod';
import prisma from '../../infra/database/prisma';

// Schemas de validação
const PaginationSchema = z.object({
  page: z.coerce.number().int().positive().optional().default(1),
  limit: z.coerce.number().int().positive().max(100).optional().default(20),
});

const IdParamSchema = z.object({
  id: z.coerce.number().int().positive(),
});

// Helper para converter Decimal para Number
function formatProduct(product: any) {
  return {
    ...product,
    price: Number(product.price),
    compareAtPrice: product.compareAtPrice ? Number(product.compareAtPrice) : null,
    costPrice: product.costPrice ? Number(product.costPrice) : null,
    ratingAverage: Number(product.ratingAverage),
  };
}

export default async function productRoutes(fastify: FastifyInstance) {
  
  // GET /api/products - Lista todos os produtos
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
      
      return reply.send({
        success: true,
        data: products.map(formatProduct),
        pagination: {
          page,
          limit,
          total,
          totalPages: Math.ceil(total / limit),
          hasNext: page < Math.ceil(total / limit),
          hasPrevious: page > 1
        }
      });
    } catch (error) {
      request.log.error(error);
      return reply.status(500).send({ 
        success: false, 
        error: 'Internal Server Error',
        message: 'Failed to fetch products'
      });
    }
  });

  // GET /api/products/featured - Produtos em destaque
  fastify.get('/featured', async (request: FastifyRequest, reply: FastifyReply) => {
    try {
      const products = await prisma.product.findMany({
        where: { 
          isActive: true, 
          isFeatured: true,
          stockQuantity: { gt: 0 }
        },
        take: 10,
        orderBy: [{ createdAt: 'desc' }, { salesCount: 'desc' }],
        include: { category: true }
      });
      
      return reply.send({
        success: true,
        data: products.map(formatProduct)
      });
    } catch (error) {
      request.log.error(error);
      return reply.status(500).send({ 
        success: false, 
        error: 'Internal Server Error' 
      });
    }
  });

  // GET /api/products/search - Busca produtos
  fastify.get('/search', async (request: FastifyRequest, reply: FastifyReply) => {
    try {
      const { q, page = 1, limit = 20 } = request.query as any;
      
      if (!q || q.trim().length === 0) {
        return reply.status(400).send({
          success: false,
          error: 'Bad Request',
          message: 'Search query is required'
        });
      }
      
      const skip = (Number(page) - 1) * Number(limit);
      
      const [products, total] = await Promise.all([
        prisma.product.findMany({
          where: {
            OR: [
              { name: { contains: q } },
              { description: { contains: q } },
              { brand: { contains: q } }
            ]
          },
          skip,
          take: Number(limit),
          include: { category: true }
        }),
        prisma.product.count({
          where: {
            OR: [
              { name: { contains: q } },
              { description: { contains: q } },
              { brand: { contains: q } }
            ]
          }
        })
      ]);
      
      return reply.send({
        success: true,
        data: products.map(formatProduct),
        pagination: {
          page: Number(page),
          limit: Number(limit),
          total,
          totalPages: Math.ceil(total / Number(limit))
        }
      });
    } catch (error) {
      request.log.error(error);
      return reply.status(500).send({ 
        success: false, 
        error: 'Internal Server Error' 
      });
    }
  });

  // GET /api/products/:id - Produto por ID
  fastify.get('/:id', async (request: FastifyRequest<{ Params: { id: string } }>, reply: FastifyReply) => {
    try {
      const { id } = IdParamSchema.parse({ id: parseInt(request.params.id) });
      
      const product = await prisma.product.findUnique({
        where: { id },
        include: { 
          category: true,
          variants: {
            where: { isActive: true }
          }
        }
      });
      
      if (!product) {
        return reply.status(404).send({
          success: false,
          error: 'Not Found',
          message: `Product with ID ${id} not found`
        });
      }
      
      // Incrementa view count (fire and forget)
      prisma.product.update({
        where: { id },
        data: { viewCount: { increment: 1 } }
      }).catch(() => {});
      
      return reply.send({
        success: true,
        data: formatProduct(product)
      });
    } catch (error) {
      if (error instanceof z.ZodError) {
        return reply.status(400).send({
          success: false,
          error: 'Validation Error',
          details: error.errors
        });
      }
      
      request.log.error(error);
      return reply.status(500).send({ 
        success: false, 
        error: 'Internal Server Error' 
      });
    }
  });

  // GET /api/products/slug/:slug - Produto por slug
  fastify.get('/slug/:slug', async (request: FastifyRequest<{ Params: { slug: string } }>, reply: FastifyReply) => {
    try {
      const { slug } = request.params;
      
      const product = await prisma.product.findUnique({
        where: { slug },
        include: { 
          category: true,
          variants: {
            where: { isActive: true }
          }
        }
      });
      
      if (!product) {
        return reply.status(404).send({
          success: false,
          error: 'Not Found',
          message: `Product with slug "${slug}" not found`
        });
      }
      
      return reply.send({
        success: true,
        data: formatProduct(product)
      });
    } catch (error) {
      request.log.error(error);
      return reply.status(500).send({ 
        success: false, 
        error: 'Internal Server Error' 
      });
    }
  });

  // GET /api/categories - Lista categorias
  fastify.get('/categories', async (request: FastifyRequest, reply: FastifyReply) => {
    try {
      const categories = await prisma.category.findMany({
        where: { isActive: true },
        orderBy: [{ displayOrder: 'asc' }, { name: 'asc' }]
      });
      
      return reply.send({
        success: true,
        data: categories
      });
    } catch (error) {
      request.log.error(error);
      return reply.status(500).send({ 
        success: false, 
        error: 'Internal Server Error' 
      });
    }
  });

  // GET /api/brands - Lista marcas
  fastify.get('/brands', async (request: FastifyRequest, reply: FastifyReply) => {
    try {
      const brands = await prisma.product.findMany({
        where: { 
          isActive: true, 
          brand: { not: null } 
        },
        distinct: ['brand'],
        select: { brand: true },
        orderBy: { brand: 'asc' }
      });
      
      return reply.send({
        success: true,
        data: brands.map((b: any) => b.brand).filter(Boolean)
      });
    } catch (error) {
      request.log.error(error);
      return reply.status(500).send({ 
        success: false, 
        error: 'Internal Server Error' 
      });
    }
  });

  // GET /api/price-range - Faixa de preços
  fastify.get('/price-range', async (request: FastifyRequest, reply: FastifyReply) => {
    try {
      const result = await prisma.product.aggregate({
        where: {
          isActive: true,
          stockQuantity: { gt: 0 }
        },
        _min: { price: true },
        _max: { price: true }
      });
      
      return reply.send({
        success: true,
        data: {
          min: result._min.price ? Number(result._min.price) : 0,
          max: result._max.price ? Number(result._max.price) : 0
        }
      });
    } catch (error) {
      request.log.error(error);
      return reply.status(500).send({ 
        success: false, 
        error: 'Internal Server Error' 
      });
    }
  });

  // GET /api/stats - Estatísticas
  fastify.get('/stats', async (request: FastifyRequest, reply: FastifyReply) => {
    try {
      const [
        totalProducts,
        activeProducts,
        totalCategories,
        featuredProducts,
        outOfStockProducts
      ] = await Promise.all([
        prisma.product.count(),
        prisma.product.count({ where: { isActive: true } }),
        prisma.category.count(),
        prisma.product.count({ where: { isFeatured: true } }),
        prisma.product.count({ where: { stockQuantity: 0 } })
      ]);
      
      return reply.send({
        success: true,
        data: {
          totalProducts,
          activeProducts,
          totalCategories,
          featuredProducts,
          outOfStockProducts
        }
      });
    } catch (error) {
      request.log.error(error);
      return reply.status(500).send({ 
        success: false, 
        error: 'Internal Server Error' 
      });
    }
  });
}
