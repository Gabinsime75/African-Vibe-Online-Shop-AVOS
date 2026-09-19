// Copyright 2018 Google LLC
// Modifications copyright 2026 African Vibe Online Shop (AVOS)
// SPDX-License-Identifier: Apache-2.0

package money

import (
	"errors"

	pb "github.com/Gabinsime75/African-Vibe-Online-Shop-AVOS/src/checkoutservice/genproto"
)

const (
	nanosMin = -999999999
	nanosMax = +999999999
	nanosMod = 1000000000
)

var (
	ErrInvalidValue        = errors.New("one of the specified money values is invalid")
	ErrMismatchingCurrency = errors.New("mismatching currency codes")
)

func IsValid(value *pb.Money) bool {
	if value == nil {
		return false
	}
	return signMatches(value) && validNanos(value.GetNanos())
}

func signMatches(value *pb.Money) bool {
	return value.GetNanos() == 0 || value.GetUnits() == 0 ||
		(value.GetNanos() < 0) == (value.GetUnits() < 0)
}

func validNanos(nanos int32) bool { return nanosMin <= nanos && nanos <= nanosMax }

func IsZero(value *pb.Money) bool {
	if value == nil {
		return false
	}
	return value.GetUnits() == 0 && value.GetNanos() == 0
}

func IsPositive(value *pb.Money) bool {
	return IsValid(value) && (value.GetUnits() > 0 ||
		(value.GetUnits() == 0 && value.GetNanos() > 0))
}

func IsNegative(value *pb.Money) bool {
	return IsValid(value) && (value.GetUnits() < 0 ||
		(value.GetUnits() == 0 && value.GetNanos() < 0))
}

func AreSameCurrency(left, right *pb.Money) bool {
	if left == nil || right == nil {
		return false
	}
	return left.GetCurrencyCode() == right.GetCurrencyCode() && left.GetCurrencyCode() != ""
}

func AreEquals(left, right *pb.Money) bool {
	if left == nil || right == nil {
		return false
	}
	return left.GetCurrencyCode() == right.GetCurrencyCode() &&
		left.GetUnits() == right.GetUnits() &&
		left.GetNanos() == right.GetNanos()
}

func Negate(value *pb.Money) *pb.Money {
	if value == nil {
		return nil
	}
	return &pb.Money{
		Units:        -value.GetUnits(),
		Nanos:        -value.GetNanos(),
		CurrencyCode: value.GetCurrencyCode(),
	}
}

func Must(value *pb.Money, err error) *pb.Money {
	if err != nil {
		panic(err)
	}
	return value
}

func Sum(left, right *pb.Money) (*pb.Money, error) {
	if !IsValid(left) || !IsValid(right) {
		return nil, ErrInvalidValue
	}
	if left.GetCurrencyCode() != right.GetCurrencyCode() {
		return nil, ErrMismatchingCurrency
	}

	units := left.GetUnits() + right.GetUnits()
	nanos := left.GetNanos() + right.GetNanos()
	if (units == 0 && nanos == 0) || (units > 0 && nanos >= 0) || (units < 0 && nanos <= 0) {
		units += int64(nanos / nanosMod)
		nanos %= nanosMod
	} else if units > 0 {
		units--
		nanos += nanosMod
	} else {
		units++
		nanos -= nanosMod
	}

	return &pb.Money{
		Units:        units,
		Nanos:        nanos,
		CurrencyCode: left.GetCurrencyCode(),
	}, nil
}

// Multiply returns value multiplied by quantity. Checkout constrains quantities,
// so repeated addition keeps Money normalization and validation in one place.
func Multiply(value *pb.Money, quantity uint32) (*pb.Money, error) {
	if !IsValid(value) {
		return nil, ErrInvalidValue
	}

	result := &pb.Money{CurrencyCode: value.GetCurrencyCode()}
	var err error
	for index := uint32(0); index < quantity; index++ {
		result, err = Sum(result, value)
		if err != nil {
			return nil, err
		}
	}
	return result, nil
}

// MultiplySlow is retained for compatibility with callers using the original helper.
func MultiplySlow(value *pb.Money, quantity uint32) *pb.Money {
	return Must(Multiply(value, quantity))
}
