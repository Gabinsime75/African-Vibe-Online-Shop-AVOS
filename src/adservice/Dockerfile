# Copyright 2020 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

FROM --platform=$BUILDPLATFORM eclipse-temurin:24.0.2_12-jdk-noble@sha256:dacac8e9a0df0d2bd24e702b4431132875c249930b70555ebd7ca285b5bee684 AS builder

WORKDIR /app

COPY ["build.gradle", "gradlew", "./"]
COPY gradle gradle
RUN chmod +x gradlew
RUN ./gradlew --no-daemon downloadRepos

COPY . .
RUN chmod +x gradlew
RUN ./gradlew --no-daemon installDist

FROM eclipse-temurin:25.0.1_8-jre-alpine@sha256:b51543f89580c1ba70e441cfbc0cfc1635c3c16d2e2d77fec9d890342a3a8687

LABEL org.opencontainers.image.title="AVOS Ad Service" \
      org.opencontainers.image.description="Contextual advertisement gRPC service for African Vibe Online Shop" \
      org.opencontainers.image.source="https://github.com/Gabinsime75/African-Vibe-Online-Shop-AVOS"

WORKDIR /app
RUN addgroup -S avos && adduser -S -G avos avos
COPY --from=builder --chown=avos:avos /app/build/install/avos-adservice/ /app/

ENV JAVA_TOOL_OPTIONS="-XX:MaxRAMPercentage=75.0"

USER avos

EXPOSE 9555
ENTRYPOINT ["/app/bin/avos-adservice"]
