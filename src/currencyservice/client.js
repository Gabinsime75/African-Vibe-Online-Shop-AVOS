// Copyright 2015 gRPC authors
// Modifications copyright 2026 African Vibe Online Shop (AVOS)
// SPDX-License-Identifier: Apache-2.0

'use strict';

const path = require('node:path');
const grpc = require('@grpc/grpc-js');
const protoLoader = require('@grpc/proto-loader');
const pino = require('pino');

const logger = pino({ name: 'avos-currencyservice-client' });
const protoPath = path.join(__dirname, 'proto/demo.proto');
const definition = protoLoader.loadSync(protoPath, {
  keepCase: true,
  longs: String,
  enums: String,
  defaults: true,
  oneofs: true
});
const shopProto = grpc.loadPackageDefinition(definition).hipstershop;
const address = process.env.CURRENCY_SERVICE_ADDR || 'localhost:7000';
const client = new shopProto.CurrencyService(address, grpc.credentials.createInsecure());

client.getSupportedCurrencies({}, (error, response) => {
  if (error) {
    logger.error({ err: error }, 'unable to list supported currencies');
    return;
  }
  logger.info({ currencies: response.currency_codes }, 'supported currencies');
});

client.convert({
  from: { currency_code: 'USD', units: '100', nanos: 0 },
  to_code: 'EUR'
}, (error, response) => {
  if (error) {
    logger.error({ err: error }, 'conversion failed');
    return;
  }
  logger.info({ result: response }, 'conversion completed');
});
