// Copyright 2026 African Vibe Online Shop (AVOS)
// SPDX-License-Identifier: Apache-2.0

'use strict';

const fs = require('node:fs');

const NANO_SCALE = 1_000_000_000n;
const MIN_INT64 = -9_223_372_036_854_775_808n;
const MAX_INT64 = 9_223_372_036_854_775_807n;
const CURRENCY_CODE_PATTERN = /^[A-Z]{3}$/;
const DECIMAL_PATTERN = /^(?:0|[1-9][0-9]*)(?:\.[0-9]{1,9})?$/;

class CurrencyError extends Error {
  constructor (message, kind = 'invalid') {
    super(message);
    this.name = 'CurrencyError';
    this.kind = kind;
  }
}

function loadRates (filePath) {
  const rawRates = JSON.parse(fs.readFileSync(filePath, 'utf8'));
  if (rawRates === null || Array.isArray(rawRates) || typeof rawRates !== 'object') {
    throw new Error('currency data must be a JSON object');
  }

  const rates = {};
  for (const [code, rawRate] of Object.entries(rawRates)) {
    if (!CURRENCY_CODE_PATTERN.test(code)) {
      throw new Error(`invalid currency code in rate data: ${code}`);
    }
    const rate = decimalToScaledInteger(String(rawRate));
    if (rate <= 0n) {
      throw new Error(`exchange rate must be positive: ${code}`);
    }
    rates[code] = rate;
  }

  if (rates.EUR !== NANO_SCALE) {
    throw new Error('EUR must be present with a rate of 1.0');
  }

  return Object.freeze(rates);
}

function supportedCurrencies (rates) {
  return Object.keys(rates).sort();
}

function convertMoney (money, targetCode, rates) {
  if (money === null || typeof money !== 'object') {
    throw new CurrencyError('from amount is required');
  }

  const sourceCode = normalizeCurrencyCode(money.currency_code, 'from.currency_code');
  const destinationCode = normalizeCurrencyCode(targetCode, 'to_code');
  if (rates[sourceCode] === undefined) {
    throw new CurrencyError(`unsupported source currency: ${sourceCode}`, 'unsupported');
  }
  if (rates[destinationCode] === undefined) {
    throw new CurrencyError(`unsupported target currency: ${destinationCode}`, 'unsupported');
  }

  const sourceNanos = moneyToNanoUnits(money);
  const convertedNanos = divideRounded(
    sourceNanos * rates[destinationCode],
    rates[sourceCode]
  );

  const units = convertedNanos / NANO_SCALE;
  const nanos = convertedNanos % NANO_SCALE;
  if (units < MIN_INT64 || units > MAX_INT64) {
    throw new CurrencyError('converted amount exceeds the supported range');
  }

  return {
    currency_code: destinationCode,
    units: units.toString(),
    nanos: Number(nanos)
  };
}

function normalizeCurrencyCode (value, fieldName) {
  const code = typeof value === 'string' ? value.trim() : '';
  if (!CURRENCY_CODE_PATTERN.test(code)) {
    throw new CurrencyError(`${fieldName} must be a three-letter uppercase currency code`);
  }
  return code;
}

function moneyToNanoUnits (money) {
  let units;
  try {
    units = BigInt(money.units ?? 0);
  } catch {
    throw new CurrencyError('from.units must be a signed integer');
  }

  const nanos = Number(money.nanos ?? 0);
  if (!Number.isInteger(nanos) || nanos < -999_999_999 || nanos > 999_999_999) {
    throw new CurrencyError('from.nanos must be between -999999999 and 999999999');
  }
  if ((units > 0n && nanos < 0) || (units < 0n && nanos > 0)) {
    throw new CurrencyError('from.units and from.nanos must use compatible signs');
  }
  if (units < MIN_INT64 || units > MAX_INT64) {
    throw new CurrencyError('from.units exceeds the supported range');
  }

  return (units * NANO_SCALE) + BigInt(nanos);
}

function decimalToScaledInteger (value) {
  if (!DECIMAL_PATTERN.test(value)) {
    throw new Error(`invalid decimal exchange rate: ${value}`);
  }
  const [whole, fraction = ''] = value.split('.');
  return (BigInt(whole) * NANO_SCALE) + BigInt(fraction.padEnd(9, '0'));
}

function divideRounded (numerator, denominator) {
  if (denominator <= 0n) {
    throw new Error('denominator must be positive');
  }
  const absoluteNumerator = numerator < 0n ? -numerator : numerator;
  const rounded = (absoluteNumerator + (denominator / 2n)) / denominator;
  return numerator < 0n ? -rounded : rounded;
}

module.exports = {
  CurrencyError,
  convertMoney,
  loadRates,
  supportedCurrencies
};
