// Copyright 2026 African Vibe Online Shop (AVOS)
// SPDX-License-Identifier: Apache-2.0

'use strict';

const pino = require('pino');

module.exports = pino({
  name: 'paymentservice',
  messageKey: 'message',
  base: { service: 'paymentservice', service_namespace: 'avos' },
  redact: {
    paths: [
      '*.credit_card_number',
      '*.credit_card_cvv',
      'credit_card_number',
      'credit_card_cvv',
      'req.credit_card.credit_card_number',
      'req.credit_card.credit_card_cvv'
    ],
    censor: '[REDACTED]'
  },
  formatters: {
    level (label) {
      return { severity: label };
    }
  }
});
