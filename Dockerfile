# ---- Build stage ----
FROM node:20-alpine AS builder

WORKDIR /app

# Install dependencies
COPY package.json package-lock.json* ./
RUN npm config set registry https://registry.npmjs.org/ --global
# RUN npm ci
RUN --network=host npm ci

# Copy the rest of the project files
COPY . .

# Build SvelteKit app
RUN npm run build

# ---- Production stage ----
FROM node:20-alpine

WORKDIR /app

# Only copy the output and necessary files
COPY --from=builder /app/build ./build
COPY --from=builder /app/package.json ./
COPY --from=builder /app/package-lock.json* ./
COPY --from=builder /app/node_modules ./node_modules

# If you need static assets (e.g., SvelteKit's static dir), add:
COPY --from=builder /app/static ./static

ENV NODE_ENV=production

# Expose SvelteKit default port
EXPOSE 3000

# Start the server (adjust if your adapter uses a different command)
CMD ["node", "build"]

