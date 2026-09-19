// Copyright 2018 Google LLC
// Modifications copyright 2026 African Vibe Online Shop (AVOS)
// SPDX-License-Identifier: Apache-2.0

package main

import "fmt"

const (
	baseShippingCents    int64 = 499
	perItemShippingCents int64 = 125
	maxItemsPerShipment  int64 = 1000
)

// Quote represents an exact USD value without floating-point arithmetic.
type Quote struct {
	Dollars int64
	Cents   int64
}

func (q Quote) String() string {
	return fmt.Sprintf("$%d.%02d", q.Dollars, q.Cents)
}

// CreateQuoteFromCount returns zero for an empty cart and otherwise applies
// the AVOS baseline rate: $4.99 plus $1.25 per physical item.
func CreateQuoteFromCount(count int64) (Quote, error) {
	if count < 0 {
		return Quote{}, fmt.Errorf("item count cannot be negative")
	}
	if count > maxItemsPerShipment {
		return Quote{}, fmt.Errorf("item count exceeds the shipment limit of %d", maxItemsPerShipment)
	}
	if count == 0 {
		return Quote{}, nil
	}

	totalCents := baseShippingCents + (count * perItemShippingCents)
	return Quote{Dollars: totalCents / 100, Cents: totalCents % 100}, nil
}
