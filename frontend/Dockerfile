# LeaseLens frontend — Next.js 15 production build (Node 22)
# Multi-stage: deps -> build -> minimal runner using `next start`.
# Note: the project does not use Next's `output: 'standalone'` mode, so the
# runner stage ships .next + node_modules and starts the standard server.
# This keeps `npm run build` and next.config.ts completely untouched.

# ---------- Stage 1: Dependencies ----------
FROM node:22-alpine AS deps
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci

# ---------- Stage 2: Build ----------
FROM node:22-alpine AS build
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .
# NEXT_PUBLIC_* variables are inlined at build time. In the Compose stack
# the browser talks to the backend via the host-published port 8000, so
# the default below is correct for a single-host deployment.
ARG NEXT_PUBLIC_API_BASE_URL=http://localhost:8000
ENV NEXT_PUBLIC_API_BASE_URL=$NEXT_PUBLIC_API_BASE_URL
RUN npm run build

# ---------- Stage 3: Runner ----------
FROM node:22-alpine AS runner
WORKDIR /app
ENV NODE_ENV=production
COPY --from=build /app/package.json ./package.json
COPY --from=build /app/next.config.ts ./next.config.ts
COPY --from=build /app/.next ./.next
COPY --from=build /app/node_modules ./node_modules

EXPOSE 3000
CMD ["npx", "next", "start", "-p", "3000", "-H", "0.0.0.0"]
