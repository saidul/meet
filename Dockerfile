# Stage 1: Build the Next.js app
FROM node:22-alpine AS builder

# Install pnpm
RUN npm install -g pnpm

# Set working directory
WORKDIR /app

# Copy package.json and pnpm-lock.yaml files
COPY package.json pnpm-lock.yaml ./

# Install dependencies
RUN pnpm install --frozen-lockfile

# Copy the rest of the application code
COPY . .

# Build the Next.js app
RUN pnpm run build

# Stage 2: Production image
FROM node:22-alpine AS runner

# Set working directory
WORKDIR /app

# Install pnpm (if not using a multi-stage build)
RUN npm install -g pnpm

# Copy the build output and necessary files
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./package.json
COPY --from=builder /app/public ./public
COPY --from=builder /app/next.config.js ./next.config.js

# Expose the port
EXPOSE 3000

# Start the Next.js app
CMD ["pnpm", "start"]