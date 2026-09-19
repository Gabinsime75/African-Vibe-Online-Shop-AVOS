// Copyright 2018 Google LLC
// Modifications copyright 2026 African Vibe Online Shop (AVOS)
// SPDX-License-Identifier: Apache-2.0

package money

import (
	"errors"
	"testing"

	pb "github.com/Gabinsime75/African-Vibe-Online-Shop-AVOS/src/checkoutservice/genproto"
)

func amount(units int64, nanos int32, currency string) *pb.Money {
	return &pb.Money{Units: units, Nanos: nanos, CurrencyCode: currency}
}

func TestIsValid(t *testing.T) {
	tests := []struct {
		name  string
		value *pb.Money
		want  bool
	}{
		{name: "positive", value: amount(10, 250000000, "USD"), want: true},
		{name: "negative", value: amount(-10, -250000000, "USD"), want: true},
		{name: "mixed signs", value: amount(-10, 250000000, "USD"), want: false},
		{name: "nanos overflow", value: amount(1, 1000000000, "USD"), want: false},
	}

	for _, test := range tests {
		t.Run(test.name, func(t *testing.T) {
			if got := IsValid(test.value); got != test.want {
				t.Fatalf("IsValid() = %v, want %v", got, test.want)
			}
		})
	}
}

func TestSum(t *testing.T) {
	tests := []struct {
		name    string
		left    *pb.Money
		right   *pb.Money
		want    *pb.Money
		wantErr error
	}{
		{
			name:  "normalizes nanos",
			left:  amount(2, 750000000, "USD"),
			right: amount(1, 500000000, "USD"),
			want:  amount(4, 250000000, "USD"),
		},
		{
			name:    "rejects mismatched currencies",
			left:    amount(1, 0, "USD"),
			right:   amount(1, 0, "XAF"),
			wantErr: ErrMismatchingCurrency,
		},
	}

	for _, test := range tests {
		t.Run(test.name, func(t *testing.T) {
			got, err := Sum(test.left, test.right)
			if !errors.Is(err, test.wantErr) {
				t.Fatalf("Sum() error = %v, want %v", err, test.wantErr)
			}
			if err == nil && !AreEquals(got, test.want) {
				t.Fatalf("Sum() = %v, want %v", got, test.want)
			}
		})
	}
}

func TestMultiply(t *testing.T) {
	tests := []struct {
		name     string
		quantity uint32
		want     *pb.Money
	}{
		{name: "zero", quantity: 0, want: amount(0, 0, "USD")},
		{name: "one", quantity: 1, want: amount(2, 500000000, "USD")},
		{name: "four", quantity: 4, want: amount(10, 0, "USD")},
	}

	for _, test := range tests {
		t.Run(test.name, func(t *testing.T) {
			got, err := Multiply(amount(2, 500000000, "USD"), test.quantity)
			if err != nil {
				t.Fatalf("Multiply() error = %v", err)
			}
			if !AreEquals(got, test.want) {
				t.Fatalf("Multiply() = %v, want %v", got, test.want)
			}
		})
	}
}
