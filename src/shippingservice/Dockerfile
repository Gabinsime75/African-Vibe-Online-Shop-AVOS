# Copyright 2026 African Vibe Online Shop (AVOS)
# SPDX-License-Identifier: Apache-2.0

FROM --platform=$BUILDPLATFORM golang:1.25.12-alpine AS builder

ARG TARGETOS=linux
ARG TARGETARCH=amd64
ARG SKAFFOLD_GO_GCFLAGS

WORKDIR /src
COPY go.mod go.sum ./
RUN set -eux; \
    for attempt in 1 2 3; do \
      GOPROXY=https://proxy.golang.org,direct go mod download && exit 0; \
      echo "Dependency download failed; retrying in 5 seconds"; \
      sleep 5; \
    done; \
    exit 1

COPY . .
RUN GOOS=${TARGETOS} GOARCH=${TARGETARCH} CGO_ENABLED=0 \
    go build -trimpath -ldflags="-s -w" -gcflags="${SKAFFOLD_GO_GCFLAGS}" \
    -o /shippingservice .

FROM gcr.io/distroless/static:nonroot

LABEL org.opencontainers.image.title="AVOS Shipping Service" \
      org.opencontainers.image.description="gRPC shipping quote and fulfillment simulator for African Vibe Online Shop" \
      org.opencontainers.image.source="https://github.com/Gabinsime75/African-Vibe-Online-Shop-AVOS"

ENV PORT=50051 \
    GOTRACEBACK=single

WORKDIR /app
COPY --from=builder --chown=nonroot:nonroot /shippingservice /app/shippingservice

USER nonroot:nonroot
EXPOSE 50051

ENTRYPOINT ["/app/shippingservice"]
