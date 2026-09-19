// Copyright 2018 Google LLC
// Modifications copyright 2026 African Vibe Online Shop (AVOS)
// SPDX-License-Identifier: Apache-2.0

'use strict';

const { randomUUID } = require('node:crypto');

const NANO_SCALE = 1_000_000_000n;
const MAX_CHARGE_UNITS = 1_000_000_000n;
const CURRENCY_CODE_PATTERN = /^[A-Z]{3}$/;

class PaymentValidationError extends Error {
  constructor (message, kind = 'invalid') {
    super(message);
    this.name = 'PaymentValidationError';
    this.kind = kind;
  }
}

function charge (request, now = new Date()) {
  if (request === null || typeof request !== 'object') {
    throw new PaymentValidationError('charge request is required');
  }

  const amount = validateAmount(request.amount);
  const card = validateCard(request.credit_card, now);

  return {
    response: { transaction_id: randomUUID() },
    audit: {
      amount_currency: amount.currencyCode,
      amount_units: amount.units.toString(),
      card_type: card.type,
      card_last_four: card.lastFour
    }
  };
}

function validateAmount (amount) {
  if (amount === null || typeof amount !== 'object') {
    throw new PaymentValidationError('amount is required');
  }

  const currencyCode = typeof amount.currency_code === 'string'
    ? amount.currency_code.trim()
    : '';
  if (!CURRENCY_CODE_PATTERN.test(currencyCode)) {
    throw new PaymentValidationError('amount.currency_code must be a three-letter uppercase currency code');
  }

  let units;
  try {
    units = BigInt(amount.units ?? 0);
  } catch {
    throw new PaymentValidationError('amount.units must be a signed integer');
  }

  const nanos = Number(amount.nanos ?? 0);
  if (!Number.isInteger(nanos) || nanos < -999_999_999 || nanos > 999_999_999) {
    throw new PaymentValidationError('amount.nanos must be between -999999999 and 999999999');
  }
  if ((units > 0n && nanos < 0) || (units < 0n && nanos > 0)) {
    throw new PaymentValidationError('amount.units and amount.nanos must use compatible signs');
  }

  const totalNanos = (units * NANO_SCALE) + BigInt(nanos);
  if (totalNanos <= 0n) {
    throw new PaymentValidationError('charge amount must be greater than zero');
  }
  if (totalNanos > MAX_CHARGE_UNITS * NANO_SCALE) {
    throw new PaymentValidationError('charge amount exceeds the supported limit');
  }

  return { currencyCode, units, nanos };
}

function validateCard (creditCard, now) {
  if (creditCard === null || typeof creditCard !== 'object') {
    throw new PaymentValidationError('credit_card is required');
  }

  const number = String(creditCard.credit_card_number || '').replace(/[ -]/g, '');
  if (!/^\d{12,19}$/.test(number) || !passesLuhn(number)) {
    throw new PaymentValidationError('credit card information is invalid');
  }

  const type = detectAcceptedCardType(number);
  if (!type) {
    throw new PaymentValidationError('only Visa or Mastercard is accepted', 'unsupported_card');
  }

  const month = Number(creditCard.credit_card_expiration_month);
  const year = Number(creditCard.credit_card_expiration_year);
  const currentMonth = now.getUTCMonth() + 1;
  const currentYear = now.getUTCFullYear();
  if (!Number.isInteger(month) || month < 1 || month > 12) {
    throw new PaymentValidationError('credit card expiration month must be between 1 and 12');
  }
  if (!Number.isInteger(year) || year < currentYear || year > currentYear + 20) {
    throw new PaymentValidationError('credit card expiration year is invalid');
  }
  if ((year * 12 + month) < (currentYear * 12 + currentMonth)) {
    throw new PaymentValidationError(`credit card ending ${number.slice(-4)} is expired`, 'expired');
  }

  const cvv = Number(creditCard.credit_card_cvv);
  if (!Number.isInteger(cvv) || cvv < 100 || cvv > 999) {
    throw new PaymentValidationError('credit card CVV must be a three-digit number');
  }

  return { type, lastFour: number.slice(-4) };
}

function detectAcceptedCardType (number) {
  if ([13, 16, 19].includes(number.length) && number.startsWith('4')) return 'visa';
  if (number.length !== 16) return null;

  const firstTwo = Number(number.slice(0, 2));
  const firstFour = Number(number.slice(0, 4));
  if ((firstTwo >= 51 && firstTwo <= 55) || (firstFour >= 2221 && firstFour <= 2720)) {
    return 'mastercard';
  }
  return null;
}

function passesLuhn (number) {
  let sum = 0;
  let doubleDigit = false;
  for (let index = number.length - 1; index >= 0; index -= 1) {
    let digit = Number(number[index]);
    if (doubleDigit) {
      digit *= 2;
      if (digit > 9) digit -= 9;
    }
    sum += digit;
    doubleDigit = !doubleDigit;
  }
  return sum % 10 === 0;
}

module.exports = {
  PaymentValidationError,
  charge,
  detectAcceptedCardType,
  passesLuhn,
  validateAmount,
  validateCard
};
