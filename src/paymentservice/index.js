// Copyright 2018 Google LLC
// Modifications copyright 2026 African Vibe Online Shop (AVOS)
// SPDX-License-Identifier: Apache-2.0

'use strict';

const logger = require('./logger');
const { startTelemetry } = require('./telemetry');

// Telemetry starts before server.js loads grpc-js so instrumentation can patch it.
const telemetry = startTelemetry(logger);
const grpc = require('@grpc/grpc-js');
const { createServer } = require('./server');

const DEFAULT_PORT = '50051';

async function stopTelemetry () {
  try {
    await telemetry.shutdown();
  } catch (error) {
    logger.warn({ error_type: error.name }, 'failed to flush telemetry');
  }
}

function main () {
  const port = process.env.PORT || DEFAULT_PORT;
  if (!/^[0-9]{1,5}$/.test(port) || Number(port) < 1 || Number(port) > 65535) {
    logger.fatal({ port }, 'PORT must be between 1 and 65535');
    stopTelemetry().finally(() => { process.exitCode = 1; });
    return;
  }

  const server = createServer();
  server.bindAsync(`[::]:${port}`, grpc.ServerCredentials.createInsecure(), (error, boundPort) => {
    if (error) {
      logger.fatal({ error_type: error.name }, 'failed to bind gRPC server');
      stopTelemetry().finally(() => { process.exitCode = 1; });
      return;
    }
    logger.info({ port: boundPort }, 'AVOS Payment Service listening');
  });

  let shuttingDown = false;
  for (const signal of ['SIGINT', 'SIGTERM']) {
    process.on(signal, () => {
      if (shuttingDown) return;
      shuttingDown = true;
      logger.info({ signal }, 'shutdown requested');

      const forceTimer = setTimeout(() => {
        logger.warn('graceful shutdown timed out; forcing gRPC server stop');
        server.forceShutdown();
      }, 10_000);
      forceTimer.unref();

      server.tryShutdown(async () => {
        clearTimeout(forceTimer);
        await stopTelemetry();
      });
    });
  }
}

if (require.main === module) main();

module.exports = { main };
