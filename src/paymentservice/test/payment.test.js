// Copyright 2026 African Vibe Online Shop (AVOS)
// SPDX-License-Identifier: Apache-2.0

'use strict';

const test = require('node:test');
const assert = require('node:assert/strict');
const {
  PaymentValidationError,
  charge,
  detectAcceptedCardType,
  passesLuhn,
  validateAmount
} = require('../charge');

const NOW = new Date('2026-09-19T12:00:00Z');

function validRequest () {
  return {
    amount: { currency_code: 'USD', units: '49', nanos: 990_000_000 },
    credit_card: {
      credit_card_number: '4111 1111 1111 1111',
      credit_card_cvv: 123,
      credit_card_expiration_year: 2028,
      credit_card_expiration_month: 12
    }
  };
}

test('processes a valid simulated Visa charge', () => {
  const result = charge(validRequest(), NOW);
  assert.match(result.response.transaction_id, /^[0-9a-f-]{36}$/);
  assert.deepEqual(result.audit, {
    amount_currency: 'USD',
    amount_units: '49',
    card_type: 'visa',
    card_last_four: '1111'
  });
  assert.equal(Object.hasOwn(result.audit, 'credit_card_number'), false);
  assert.equal(Object.hasOwn(result.audit, 'credit_card_cvv'), false);
});

test('recognizes accepted card ranges', () => {
  assert.equal(detectAcceptedCardType('4111111111111111'), 'visa');
  assert.equal(detectAcceptedCardType('5555555555554444'), 'mastercard');
  assert.equal(detectAcceptedCardType('378282246310005'), null);
});

test('validates card numbers with the Luhn algorithm', () => {
  assert.equal(passesLuhn('4111111111111111'), true);
  assert.equal(passesLuhn('4111111111111112'), false);
});

test('rejects expired cards', () => {
  const request = validRequest();
  request.credit_card.credit_card_expiration_year = 2026;
  request.credit_card.credit_card_expiration_month = 8;
  assert.throws(() => charge(request, NOW), PaymentValidationError);
});

test('rejects malformed CVV values', () => {
  const request = validRequest();
  request.credit_card.credit_card_cvv = 12;
  assert.throws(() => charge(request, NOW), /CVV/);
});

test('rejects zero and negative charges', () => {
  assert.throws(() => validateAmount({ currency_code: 'USD', units: '0', nanos: 0 }), /greater than zero/);
  assert.throws(() => validateAmount({ currency_code: 'USD', units: '-1', nanos: 0 }), /greater than zero/);
});

test('rejects invalid Money sign combinations', () => {
  assert.throws(
    () => validateAmount({ currency_code: 'USD', units: '1', nanos: -1 }),
    /compatible signs/
  );
});
