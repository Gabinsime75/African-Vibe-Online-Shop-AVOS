// Copyright 2026 African Vibe Online Shop (AVOS)
// SPDX-License-Identifier: Apache-2.0

'use strict';

function environmentFlag (name, fallback) {
  const value = process.env[name];
  if (value === undefined || value.trim() === '') return fallback;
  return ['1', 'true', 'yes'].includes(value.trim().toLowerCase());
}

function startTelemetry (logger) {
  if (!environmentFlag('ENABLE_OTEL', true)) {
    logger.info('OpenTelemetry disabled');
    return { shutdown: async () => {} };
  }

  const { OTLPTraceExporter } = require('@opentelemetry/exporter-trace-otlp-grpc');
  const { GrpcInstrumentation } = require('@opentelemetry/instrumentation-grpc');
  const { resourceFromAttributes } = require('@opentelemetry/resources');
  const { NodeSDK } = require('@opentelemetry/sdk-node');
  const {
    ATTR_SERVICE_NAME,
    ATTR_SERVICE_NAMESPACE,
    ATTR_SERVICE_VERSION
  } = require('@opentelemetry/semantic-conventions');

  const sdk = new NodeSDK({
    resource: resourceFromAttributes({
      [ATTR_SERVICE_NAME]: 'paymentservice',
      [ATTR_SERVICE_NAMESPACE]: 'avos',
      [ATTR_SERVICE_VERSION]: '1.0.0'
    }),
    traceExporter: new OTLPTraceExporter(),
    instrumentations: [new GrpcInstrumentation()]
  });

  sdk.start();
  logger.info('OpenTelemetry enabled');
  return { shutdown: () => sdk.shutdown() };
}

module.exports = { startTelemetry };
