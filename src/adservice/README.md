# AVOS Ad Service

The AVOS Ad Service returns contextual advertisements for products sold by African Vibe Online Shop. It exposes a gRPC API on port `9555`; when a request has no recognized context keys, the service returns up to two random AVOS advertisements.

## Role in AVOS

| Item | Role |
| --- | --- |
| `AdService` | Serves contextual AVOS product promotions over gRPC. |
| gRPC health service | Reports readiness to Kubernetes and the service mesh. |
| Fluent Bit | Collects structured JSON logs written to standard output. |
| OpenTelemetry Collector | Receives application metrics and traces when instrumentation is enabled. |

Supported context keys are `clothing`, `accessories`, and `footwear`.

## Building locally

The service uses the committed Gradle wrapper. From `src/adservice`, run:

```bash
./gradlew clean test installDist
```

The executable is created at `build/install/avos-adservice/bin/avos-adservice`.

### Upgrading gradle version
If you need to upgrade the version of gradle then run

```bash
./gradlew wrapper --gradle-version <new-version>
```

## Building docker image

```bash
docker build -t avos/adservice:phase-1 .
```

The final image runs as the unprivileged `avos` user.

## Runtime configuration

| Variable | Default | Role |
| --- | --- | --- |
| `PORT` | `9555` | Selects the gRPC listening port. |
| `DISABLE_STATS` | unset | Disables metrics initialization when set. |
| `DISABLE_TRACING` | unset | Disables tracing initialization when set. |

## Compatibility note

The Java package and protobuf namespace remain `hipstershop` during Phase 1. Renaming the shared namespace in only this service would break the frontend and other clients; AVOS will migrate the shared contract across all languages in one coordinated phase.
