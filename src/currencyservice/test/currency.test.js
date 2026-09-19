// Copyright 2026 African Vibe Online Shop (AVOS)
// SPDX-License-Identifier: Apache-2.0

'use strict';

const assert = require('node:assert/strict');
const path = require('node:path');
const test = require('node:test');
const {
  CurrencyError,
  convertMoney,
  loadRates,
  supportedCurrencies
} = require('../currency');

const rates = loadRates(path.join(__dirname, '../data/currency_conversion.json'));

test('loads and sorts supported currencies once', () => {
  const currencies = supportedCurrencies(rates);
  assert.ok(currencies.includes('EUR'));
  assert.ok(currencies.includes('USD'));
  assert.deepEqual(currencies, [...currencies].sort());
});

test('converts USD to EUR with integer nano-unit precision', () => {
  const result = convertMoney({
    currency_code: 'USD',
    units: '1',
    nanos: 130_500_000
  }, 'EUR', rates);

  assert.deepEqual(result, {
    currency_code: 'EUR',
    units: '1',
    nanos: 0
  });
});

test('converts EUR to JPY and preserves fractional money', () => {
  const result = convertMoney({
    currency_code: 'EUR',
    units: '1',
    nanos: 0
  }, 'JPY', rates);

  assert.deepEqual(result, {
    currency_code: 'JPY',
    units: '126',
    nanos: 400_000_000
  });
});

test('preserves negative values with compatible signs', () => {
  const result = convertMoney({
    currency_code: 'EUR',
    units: '-2',
    nanos: -500_000_000
  }, 'USD', rates);

  assert.deepEqual(result, {
    currency_code: 'USD',
    units: '-2',
    nanos: -826_250_000
  });
});

test('rejects unsupported currencies', () => {
  assert.throws(
    () => convertMoney({ currency_code: 'EUR', units: '1', nanos: 0 }, 'AAA', rates),
    (error) => error instanceof CurrencyError && error.kind === 'unsupported'
  );
});

test('rejects invalid Money sign combinations', () => {
  assert.throws(
    () => convertMoney({ currency_code: 'EUR', units: '1', nanos: -1 }, 'USD', rates),
    /compatible signs/
  );
});
