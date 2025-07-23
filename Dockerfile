# ---------- Build Frontend ----------
FROM node:18-alpine AS frontend

WORKDIR /client
COPY client/package*.json ./
RUN npm install
COPY client/ ./
RUN npm run build

# ---------- Build Backend ----------
FROM node:18-alpine AS backend

WORKDIR /server
COPY server/package*.json ./
RUN npm install --production
COPY server/ ./

# ---------- Final Image ----------
FROM node:18-alpine

WORKDIR /app

# Copy backend code
COPY --from=backend /server ./

# Copy built frontend files
COPY --from=frontend /client/dist ./client/dist

EXPOSE 8000

CMD ["node", "index.js"]
