// Copyright 2018 Google LLC
// Modifications copyright 2026 African Vibe Online Shop (AVOS)
// SPDX-License-Identifier: Apache-2.0

'use strict';

const path = require('node:path');
const grpc = require('@grpc/grpc-js');
const protoLoader = require('@grpc/proto-loader');
const { PaymentValidationError, charge } = require('./charge');
const logger = require('./logger');

const MAIN_PROTO_PATH = path.join(__dirname, 'proto/demo.proto');
const HEALTH_PROTO_PATH = path.join(__dirname, 'proto/grpc/health/v1/health.proto');

function loadProto (protoPath) {
  const definition = protoLoader.loadSync(protoPath, {
    keepCase: true,
    longs: String,
    enums: String,
    defaults: true,
    oneofs: true
  });
  return grpc.loadPackageDefinition(definition);
}

function createHandlers () {
  return {
    charge (call, callback) {
      try {
        const result = charge(call.request);
        logger.info(result.audit, 'simulated payment transaction processed');
        callback(null, result.response);
      } catch (error) {
        const expected = error instanceof PaymentValidationError;
        logger[expected ? 'warn' : 'error']({
          error_type: error.name,
          validation_kind: expected ? error.kind : undefined
        }, 'payment transaction rejected');
        callback({
          code: expected ? grpc.status.INVALID_ARGUMENT : grpc.status.INTERNAL,
          details: expected ? error.message : 'payment processing failed'
        });
      }
    },

    check (_call, callback) {
      callback(null, { status: 'SERVING' });
    }
  };
}

function createServer () {
  const shopProto = loadProto(MAIN_PROTO_PATH).hipstershop;
  const healthProto = loadProto(HEALTH_PROTO_PATH).grpc.health.v1;
  const handlers = createHandlers();
  const server = new grpc.Server({
    'grpc.max_receive_message_length': 64 * 1024,
    'grpc.max_send_message_length': 64 * 1024
  });

  server.addService(shopProto.PaymentService.service, { charge: handlers.charge });
  server.addService(healthProto.Health.service, { check: handlers.check });
  return server;
}

module.exports = { createHandlers, createServer };
