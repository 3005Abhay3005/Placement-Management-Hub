# ─── Stage 1: build ───────────────────────────────────────────────────────────
FROM node:20-alpine AS builder

WORKDIR /app

# Install dependencies
COPY package*.json ./
RUN npm install

# Copy all source files
COPY . .

# Run tests (fail build if tests fail)
RUN npm test

# ─── Stage 2: serve ───────────────────────────────────────────────────────────
FROM nginx:alpine AS runtime

# Remove default nginx page
RUN rm -rf /usr/share/nginx/html/*

# Copy static files
COPY --from=builder /app/login.html       /usr/share/nginx/html/index.html
COPY --from=builder /app/register.html    /usr/share/nginx/html/register.html
COPY --from=builder /app/css              /usr/share/nginx/html/css
COPY --from=builder /app/js               /usr/share/nginx/html/js

# Inject build-time git SHA for /health endpoint
ARG GIT_SHA=unknown
RUN echo "{\"status\":\"ok\",\"sha\":\"${GIT_SHA}\"}" > /usr/share/nginx/html/health.json

# Custom nginx config to serve /health
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
  CMD wget -qO- http://localhost/health || exit 1
