FROM node:20-alpine

RUN apk add --no-cache curl

WORKDIR /app

# Copiar package.json
COPY package*.json ./

# Instalar dependências
RUN npm install --legacy-peer-deps

# Copiar código fonte
COPY . .

EXPOSE 3002

CMD ["npm", "run", "dev"]
