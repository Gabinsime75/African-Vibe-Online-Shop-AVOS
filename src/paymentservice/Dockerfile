# Copyright 2026 African Vibe Online Shop (AVOS)
# SPDX-License-Identifier: Apache-2.0

FROM node:24.21.0-alpine AS dependencies

WORKDIR /usr/src/app
COPY package.json package-lock.json ./
RUN npm ci --omit=dev --ignore-scripts \
    && npm cache clean --force

FROM node:24.21.0-alpine

LABEL org.opencontainers.image.title="AVOS Payment Service" \
      org.opencontainers.image.description="Simulated gRPC payment processor for African Vibe Online Shop" \
      org.opencontainers.image.source="https://github.com/Gabinsime75/African-Vibe-Online-Shop-AVOS"

ENV NODE_ENV=production \
    PORT=50051

WORKDIR /usr/src/app
COPY --from=dependencies --chown=node:node /usr/src/app/node_modules ./node_modules
COPY --chown=node:node . .

USER node
EXPOSE 50051

ENTRYPOINT ["node", "index.js"]
