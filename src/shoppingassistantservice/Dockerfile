FROM python:3.12.12-slim@sha256:f3fa41d74a768c2fce8016b98c191ae8c1bacd8f1152870a3f9f87d350920b7c AS builder

ENV PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PIP_NO_CACHE_DIR=1

WORKDIR /build
COPY requirements.txt .
RUN python -m pip install --prefix=/install -r requirements.txt

FROM python:3.12.12-slim@sha256:f3fa41d74a768c2fce8016b98c191ae8c1bacd8f1152870a3f9f87d350920b7c

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PORT=8080

RUN groupadd --system --gid 10001 avos \
    && useradd --system --uid 10001 --gid avos --home-dir /app --shell /usr/sbin/nologin avos

WORKDIR /app
COPY --from=builder /install /usr/local
COPY shoppingassistantservice.py shoppingassistant_pb2.py shoppingassistant_pb2_grpc.py ./

USER 10001:10001
EXPOSE 8080

ENTRYPOINT ["python", "shoppingassistantservice.py"]
