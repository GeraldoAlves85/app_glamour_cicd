FROM node:20-alpine

# Instalar OpenSSL e outras dependências necessárias para o Prisma
RUN apk add --no-cache openssl openssl-dev libc6-compat curl

WORKDIR /app

# Copiar package.json
COPY package*.json ./
COPY prisma ./prisma/

# Instalar dependências
RUN npm install --legacy-peer-deps

# Gerar Prisma Client com binary target específico
RUN npx prisma generate

# Copiar código fonte
COPY . .

EXPOSE 3001

CMD ["npm", "run", "dev"]
