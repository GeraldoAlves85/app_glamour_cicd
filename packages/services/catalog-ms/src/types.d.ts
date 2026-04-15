import 'fastify';

declare module 'fastify' {
  interface FastifyInstance {
    prisma: any;
  }
  
  interface FastifyRequest {
    startTime: number;
  }
}
