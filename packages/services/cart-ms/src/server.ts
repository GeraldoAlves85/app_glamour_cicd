import Fastify from 'fastify';
import cors from '@fastify/cors';
import dotenv from 'dotenv';

dotenv.config();

const server = Fastify({
  logger: true
});

server.register(cors, {
  origin: ['http://localhost:3000', 'http://localhost:3005']
});

// Health Check
server.get('/health', async () => {
  return {
    status: 'healthy',
    service: 'cart-ms',
    version: '1.0.0',
    timestamp: new Date().toISOString()
  };
});

// Rota raiz
server.get('/', async () => {
  return {
    service: 'Glamour Cart Microservice',
    version: '1.0.0',
    endpoints: {
      health: '/health',
      cart: '/api/cart'
    }
  };
});

// GET /api/cart/:userId
server.get('/api/cart/:userId', async (request: any, reply) => {
  const { userId } = request.params;
  return {
    success: true,
    data: {
      userId: parseInt(userId),
      items: [],
      total: 0
    }
  };
});

const start = async () => {
  try {
    const port = Number(process.env.PORT) || 3002;
    await server.listen({ port, host: '0.0.0.0' });
    console.log(`🚀 Cart MS rodando em http://localhost:${port}`);
  } catch (err) {
    server.log.error(err);
    process.exit(1);
  }
};

start();
