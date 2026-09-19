// Copyright 2018 Google LLC
// Modifications copyright 2026 African Vibe Online Shop (AVOS)
// SPDX-License-Identifier: Apache-2.0

'use strict';

const path = require('node:path');
const pino = require('pino');
const { startTelemetry } = require('./telemetry');

const logger = pino({
  name: 'currencyservice',
  messageKey: 'message',
  base: { service: 'currencyservice', service_namespace: 'avos' },
  formatters: {
    level (label) {
      return { severity: label };
    }
  }
});

// Telemetry must start before grpc-js is loaded so gRPC instrumentation can patch it.
const telemetry = startTelemetry(logger);
const grpc = require('@grpc/grpc-js');
const protoLoader = require('@grpc/proto-loader');
const {
  CurrencyError,
  convertMoney,
  loadRates,
  supportedCurrencies
} = require('./currency');

const DEFAULT_PORT = '7000';
const MAIN_PROTO_PATH = path.join(__dirname, 'proto/demo.proto');
const HEALTH_PROTO_PATH = path.join(__dirname, 'proto/grpc/health/v1/health.proto');
const CURRENCY_DATA_PATH = process.env.CURRENCY_DATA_PATH ||
  path.join(__dirname, 'data/currency_conversion.json');

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

function createHandlers (rates) {
  const currencyCodes = Object.freeze(supportedCurrencies(rates));

  return {
    getSupportedCurrencies (_call, callback) {
      callback(null, { currency_codes: currencyCodes });
    },

    convert (call, callback) {
      try {
        const result = convertMoney(call.request?.from, call.request?.to_code, rates);
        logger.debug({
          source_currency: call.request.from.currency_code,
          target_currency: call.request.to_code
        }, 'currency conversion completed');
        callback(null, result);
      } catch (error) {
        const isExpected = error instanceof CurrencyError;
        logger[isExpected ? 'warn' : 'error']({ err: error }, 'currency conversion failed');
        callback({
          code: isExpected ? grpc.status.INVALID_ARGUMENT : grpc.status.INTERNAL,
          details: isExpected ? error.message : 'currency conversion failed'
        });
      }
    },

    check (_call, callback) {
      callback(null, { status: 'SERVING' });
    }
  };
}

function createServer (rates) {
  const shopProto = loadProto(MAIN_PROTO_PATH).hipstershop;
  const healthProto = loadProto(HEALTH_PROTO_PATH).grpc.health.v1;
  const handlers = createHandlers(rates);
  const server = new grpc.Server({
    'grpc.max_receive_message_length': 64 * 1024,
    'grpc.max_send_message_length': 64 * 1024
  });

  server.addService(shopProto.CurrencyService.service, {
    getSupportedCurrencies: handlers.getSupportedCurrencies,
    convert: handlers.convert
  });
  server.addService(healthProto.Health.service, { check: handlers.check });
  return server;
}

async function shutdown (server, signal) {
  logger.info({ signal }, 'shutdown requested');
  const forceTimer = setTimeout(() => {
    logger.warn('graceful shutdown timed out; forcing gRPC server stop');
    server.forceShutdown();
  }, 10_000);
  forceTimer.unref();

  await new Promise((resolve) => server.tryShutdown(resolve));
  clearTimeout(forceTimer);

  try {
    await telemetry.shutdown();
  } catch (error) {
    logger.warn({ err: error }, 'failed to flush telemetry during shutdown');
  }
}

function main () {
  let rates;
  try {
    rates = loadRates(CURRENCY_DATA_PATH);
  } catch (error) {
    logger.fatal({ err: error, data_path: CURRENCY_DATA_PATH }, 'failed to load currency rates');
    process.exitCode = 1;
    return;
  }

  const port = process.env.PORT || DEFAULT_PORT;
  if (!/^[0-9]{1,5}$/.test(port) || Number(port) < 1 || Number(port) > 65535) {
    logger.fatal({ port }, 'PORT must be between 1 and 65535');
    process.exitCode = 1;
    return;
  }

  const server = createServer(rates);
  server.bindAsync(`[::]:${port}`, grpc.ServerCredentials.createInsecure(), (error, boundPort) => {
    if (error) {
      logger.fatal({ err: error }, 'failed to bind gRPC server');
      process.exitCode = 1;
      return;
    }
    logger.info({ port: boundPort, supported_currencies: supportedCurrencies(rates).length },
      'AVOS Currency Service listening');
  });

  let shuttingDown = false;
  for (const signal of ['SIGINT', 'SIGTERM']) {
    process.on(signal, async () => {
      if (shuttingDown) return;
      shuttingDown = true;
      await shutdown(server, signal);
    });
  }
}

if (require.main === module) {
  main();
}

module.exports = { createHandlers, createServer, main };
