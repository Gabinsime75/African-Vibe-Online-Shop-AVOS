# Copyright 2026 African Vibe Online Shop (AVOS)
# SPDX-License-Identifier: Apache-2.0

FROM mcr.microsoft.com/dotnet/sdk:10.0-noble AS build
WORKDIR /src

COPY cartservice.csproj ./
RUN dotnet restore cartservice.csproj

COPY . ./
RUN dotnet publish cartservice.csproj \
    --configuration Release \
    --no-restore \
    --output /app/publish \
    /p:UseAppHost=false

FROM mcr.microsoft.com/dotnet/aspnet:10.0-noble-chiseled AS runtime

LABEL org.opencontainers.image.title="AVOS Cart Service" \
      org.opencontainers.image.description="gRPC shopping-cart service for African Vibe Online Shop" \
      org.opencontainers.image.source="https://github.com/Gabinsime75/African-Vibe-Online-Shop-AVOS"

WORKDIR /app
COPY --from=build --chown=1654:1654 /app/publish ./

ENV ASPNETCORE_HTTP_PORTS=7070 \
    DOTNET_EnableDiagnostics=0

USER 1654
EXPOSE 7070

ENTRYPOINT ["dotnet", "cartservice.dll"]
