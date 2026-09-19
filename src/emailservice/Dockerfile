# Copyright 2026 African Vibe Online Shop (AVOS)
# SPDX-License-Identifier: Apache-2.0

FROM python:3.14.2-alpine AS dependencies

ENV PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PIP_NO_CACHE_DIR=1

WORKDIR /install
COPY requirements.txt .
RUN python -m pip install --prefix=/install/packages -r requirements.txt

FROM python:3.14.2-alpine

LABEL org.opencontainers.image.title="AVOS Email Service" \
      org.opencontainers.image.description="Simulated gRPC order-confirmation email service for African Vibe Online Shop" \
      org.opencontainers.image.source="https://github.com/Gabinsime75/African-Vibe-Online-Shop-AVOS"

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PORT=8080

RUN addgroup -S avos && adduser -S -G avos -h /app avos

WORKDIR /app
COPY --from=dependencies /install/packages /usr/local
COPY --chown=avos:avos . .

USER avos
EXPOSE 8080

ENTRYPOINT ["python", "email_server.py"]
