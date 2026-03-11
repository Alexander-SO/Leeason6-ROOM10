# ============================================================
# Dockerfile — node-express-chatbox
# Fija la versión de Node en 18 (LTS estable para este proyecto)
# ============================================================

FROM node:18-alpine

WORKDIR /app

# Copia primero los archivos de dependencias para aprovechar la caché de Docker
COPY package*.json ./

RUN npm install

# Copia el resto del código
COPY . .

EXPOSE ${PORT:-3001}

CMD ["node", "server.js"]
