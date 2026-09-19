# AVOS Shopping Assistant Service

The Shopping Assistant Service uses Amazon Bedrock and Amazon OpenSearch Service to recommend real AVOS catalog products from a customer's text request and optional image.

## Request flow

1. **Frontend gRPC client** — Converts the browser request into a typed internal gRPC call.
2. **Bedrock multimodal model** — Describes the optional image without inferring sensitive personal traits.
3. **Titan Text Embeddings V2** — Converts the customer request and image description into a 1,024-dimension vector.
4. **Amazon OpenSearch Service** — Retrieves the closest indexed AVOS products using k-NN search.
5. **Bedrock response model** — Explains the retrieved recommendations without inventing products or IDs.
6. **Typed gRPC response** — Returns narrative content and explicit product IDs to the frontend.

## Runtime configuration

| Variable | Required | Role |
| --- | --- | --- |
| `AWS_REGION` | Yes | Selects the AWS Region used by Bedrock and OpenSearch signing. |
| `BEDROCK_MODEL_ID` | Yes | Selects a Bedrock Converse model that supports the intended text/image workload. |
| `OPENSEARCH_ENDPOINT` | Yes | Identifies the private OpenSearch domain or collection endpoint. |
| `BEDROCK_EMBEDDING_MODEL_ID` | No | Selects the embedding model; defaults to `amazon.titan-embed-text-v2:0`. |
| `OPENSEARCH_INDEX` | No | Selects the product-vector index; defaults to `avos-products`. |
| `OPENSEARCH_SERVICE` | No | Uses `es` for a managed domain or `aoss` for OpenSearch Serverless. |
| `RECOMMENDATION_LIMIT` | No | Limits results returned to the customer; defaults to three. |
| `MAX_IMAGE_BYTES` | No | Restricts uploaded image size; defaults to 3 MiB. |
| `ENABLE_TRACING` | No | Enables OTLP trace export when set to `1`. |
| `OTEL_EXPORTER_OTLP_ENDPOINT` | No | Identifies the OpenTelemetry Collector gRPC endpoint. |
| `PORT` | No | Sets the gRPC listener port; defaults to `8080`. |

The application does not read static AWS keys. EKS Pod Identity supplies temporary AWS credentials to the AWS SDK.

## Required AWS permissions

| Permission | Role |
| --- | --- |
| `bedrock:Converse` | Generates the image description and customer-facing recommendation. |
| `bedrock:InvokeModel` | Generates the vector used for product similarity search. |
| OpenSearch read access to `avos-products` | Retrieves only products already present in the AVOS catalog index. |

Scope the IAM policy to the selected models and OpenSearch resource during the infrastructure phase.

## OpenSearch contract

`opensearch-index.json` defines the initial index mapping. The ingestion workflow must create 1,024-dimension embeddings with the same embedding model configured for this service; otherwise k-NN queries are incompatible.

## Local validation

The unit tests mock Bedrock and OpenSearch, so AWS credentials are not required.

```bash
python -m venv .venv
source .venv/Scripts/activate
python -m pip install --upgrade pip
python -m pip install -r requirements.txt
python -m unittest discover -p "test_*.py" -v
python -m compileall -q .
deactivate
docker build -t avos/shoppingassistantservice:phase-1 .
```

To regenerate the Python bindings after changing the contract:

```bash
python -m pip install -r requirements-dev.in
bash genproto.sh
```

The frontend Go bindings are regenerated from the repository root contract by `src/frontend/genproto.sh`.
