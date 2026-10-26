// Copyright 2026 African Vibe Online Shop (AVOS)
// SPDX-License-Identifier: Apache-2.0
'use strict';

const assert = require('node:assert/strict');
const test = require('node:test');

// Configure hooks before the first application import of grpc-js.
process.env.ENABLE_OTEL = 'false';
const telemetry = require('../telemetry').startTelemetry({ info: () => {} });
const grpc = require('@grpc/grpc-js');
const { trace, propagation, context } = require('@opentelemetry/api');

const method = {
  path: '/avos.test.Trace/Check',
  requestStream: false,
  responseStream: false,
  requestSerialize: value => Buffer.from(JSON.stringify(value)),
  requestDeserialize: value => JSON.parse(value.toString()),
  responseSerialize: value => Buffer.from(JSON.stringify(value)),
  responseDeserialize: value => JSON.parse(value.toString())
};

test('gRPC propagates W3C context without exporting and isolates requests', async () => {
  const server = new grpc.Server();
  server.addService({ check: method }, {
    check: (_call, callback) => {
      const span = trace.getSpan(context.active()).spanContext();
      const baggage = propagation.getBaggage(context.active());
      callback(null, {
        traceId: span.traceId,
        spanId: span.spanId,
        baggage: baggage?.getEntry('avos.test')?.value
      });
    }
  });
  const port = await new Promise((resolve, reject) => {
    server.bindAsync('127.0.0.1:0', grpc.ServerCredentials.createInsecure(),
      (error, port) => error ? reject(error) : resolve(port));
  });
  const Client = grpc.makeGenericClientConstructor({ check: method }, 'Trace');
  const client = new Client(`127.0.0.1:${port}`, grpc.credentials.createInsecure());
  const call = async traceparent => {
    const metadata = new grpc.Metadata();
    if (traceparent) {
      metadata.set('traceparent', traceparent);
      metadata.set('baggage', 'avos.test=propagated');
    }
    return new Promise((resolve, reject) => {
      client.check({}, metadata, { deadline: Date.now() + 3000 },
        (error, value) => error ? reject(error) : resolve(value));
    });
  };
  try {
    const traceId = '1234567890abcdef1234567890abcdef';
    const result = await call(`00-${traceId}-1234567890abcdef-01`);
    assert.equal(result.traceId, traceId);
    // With no exporting SDK, the incoming non-recording span is propagated.
    assert.equal(result.spanId, '1234567890abcdef');
    assert.equal(result.baggage, 'propagated');
    const fresh = await call();
    assert.notEqual(fresh.traceId, traceId);
    assert.equal(fresh.baggage, undefined);
    const malformed = await call('malformed');
    assert.notEqual(malformed.traceId, traceId);
  } finally {
    client.close();
    await new Promise(resolve => server.tryShutdown(resolve));
    await telemetry.shutdown();
  }
});
