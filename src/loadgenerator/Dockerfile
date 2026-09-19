# Copyright 2026 African Vibe Online Shop (AVOS)
# SPDX-License-Identifier: Apache-2.0

FROM python:3.14.2-alpine AS dependencies

ENV PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PIP_NO_CACHE_DIR=1

RUN apk add --no-cache g++ linux-headers
WORKDIR /install
COPY requirements.txt .
RUN python -m pip install --prefix=/install/packages -r requirements.txt

FROM python:3.14.2-alpine

LABEL org.opencontainers.image.title="AVOS Load Generator" \
      org.opencontainers.image.description="Locust traffic generator for African Vibe Online Shop" \
      org.opencontainers.image.source="https://github.com/Gabinsime75/African-Vibe-Online-Shop-AVOS"

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    GEVENT_SUPPORT=True \
    FRONTEND_ADDR=frontend:80 \
    USERS=10 \
    RATE=1

RUN apk add --no-cache libstdc++ \
    && addgroup -S avos \
    && adduser -S -G avos -h /app avos

WORKDIR /app
COPY --from=dependencies /install/packages /usr/local
COPY --chown=avos:avos locustfile.py run-load-test.sh ./
RUN chmod 0555 /app/run-load-test.sh

USER avos

ENTRYPOINT ["/app/run-load-test.sh"]
