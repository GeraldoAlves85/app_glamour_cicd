// =============================================
// GLAMOUR CATALOG MICROSERVICE - SERVER
// =============================================
import Fastify from 'fastify';
import cors from '@fastify/cors';
import helmet from '@fastify/helmet';
import rateLimit from '@fastify/rate-limit';
import dotenv from 'dotenv';

// Configuração de ambiente
dotenv.config();

// Importações locais
import prisma, { testDatabaseConnection, disconnectDatabase } from './infra/database/prisma';
import productRoutes from './interface/routes/productRoutes';

// Estender tipos do Fastify
declare module 'fastify' {
  interface FastifyRequest {
    startTime?: number;
  }
}

// =============================================
// CONFIGURAÇÃO DO SERVIDOR
// =============================================
const server = Fastify({
  logger: {
    level: process.env.LOG_LEVEL || 'info',
    transport: process.env.NODE_ENV === 'development'
      ? {
          target: 'pino-pretty',
          options: {
            translateTime: 'HH:MM:ss Z',
            ignore: 'pid,hostname',
            colorize: true,
          },
        }
      : undefined,
  },
});

// Adicionar prisma à instância do Fastify
server.decorate('prisma', prisma);

// =============================================
// PLUGINS
// =============================================

// CORS
server.register(cors, {
  origin: process.env.CORS_ORIGIN?.split(',') || ['http://localhost:3000'],
  credentials: true,
});

// Helmet (Segurança)
server.register(helmet, {
  contentSecurityPolicy: false, // Desabilitado para desenvolvimento
});

// Rate Limiting
server.register(rateLimit, {
  max: Number(process.env.RATE_LIMIT_MAX) || 100,
  timeWindow: Number(process.env.RATE_LIMIT_WINDOW_MS) || 900000,
});

// =============================================
// HOOKS
// =============================================

// Hook para logging de requisições
server.addHook('onRequest', async (request) => {
  request.startTime = Date.now();
});

// Hook para logging de respostas
server.addHook('onResponse', async (request, reply) => {
  const responseTime = Date.now() - (request.startTime || Date.now());
  
  request.log.info({
    method: request.method,
    url: request.url,
    statusCode: reply.statusCode,
    responseTime: `${responseTime}ms`,
  }, 'Request completed');
});

// =============================================
// ROTAS
// =============================================

// Health Check
server.get('/health', async () => {
  return {
    status: 'healthy',
    service: 'catalog-ms',
    version: '1.0.0',
    timestamp: new Date().toISOString(),
  };
});

// Readiness Check
server.get('/ready', async (request, reply) => {
  try {
    await prisma.$queryRaw`SELECT 1`;
    return {
      status: 'ready',
      service: 'catalog-ms',
      database: 'connected',
    };
  } catch (error) {
    return reply.status(503).send({
      status: 'not ready',
      service: 'catalog-ms',
      database: 'disconnected',
    });
  }
});

// Registra as rotas de produtos
server.register(productRoutes, { prefix: '/api' });

// Rota raiz
server.get('/', async () => {
  return {
    service: 'Glamour Catalog Microservice',
    version: '1.0.0',
    endpoints: {
      health: '/health',
      products: '/api/products',
      categories: '/api/categories',
      brands: '/api/brands',
      stats: '/api/stats',
    },
  };
});

// =============================================
// ERROR HANDLER
// =============================================
server.setErrorHandler((error, request, reply) => {
  const statusCode = error.statusCode || 500;
  
  request.log.error({
    error: error.message,
    stack: error.stack,
    statusCode,
  });
  
  return reply.status(statusCode).send({
    success: false,
    error: error.name,
    message: error.message,
    statusCode,
  });
});

// =============================================
// GRACEFUL SHUTDOWN
// =============================================
const gracefulShutdown = async (signal: string) => {
  server.log.info(`Received ${signal}. Shutting down...`);
  
  try {
    await server.close();
    await disconnectDatabase();
    process.exit(0);
  } catch (error) {
    server.log.error('Error during shutdown: ' + error);
    process.exit(1);
  }
};

process.on('SIGTERM', () => gracefulShutdown('SIGTERM'));
process.on('SIGINT', () => gracefulShutdown('SIGINT'));

// =============================================
// START SERVER
// =============================================
const start = async () => {
  try {
    const isConnected = await testDatabaseConnection();
    
    const port = Number(process.env.PORT) || 3001;
    const host = '0.0.0.0';
    
    await server.listen({ port, host });
    
    console.log(`
╔══════════════════════════════════════════════════════════╗
║     🚀 GLAMOUR CATALOG MICROSERVICE                      ║
╠══════════════════════════════════════════════════════════╣
║  Status:      Online                                     ║
║  Port:        ${port}                                       ║
║  Database:    ${isConnected ? 'Connected' : 'Disconnected'} ║
║  Health:      http://localhost:${port}/health               ║
║  API:         http://localhost:${port}/api/products         ║
╚══════════════════════════════════════════════════════════╝
    `);
  } catch (error) {
    console.error('Failed to start server: ' + error);
    process.exit(1);
  }
};

start();
