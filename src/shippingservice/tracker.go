// Copyright 2018 Google LLC
// Modifications copyright 2026 African Vibe Online Shop (AVOS)
// SPDX-License-Identifier: Apache-2.0

package main

import (
	"crypto/rand"
	"fmt"
)

const trackingAlphabet = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"

// CreateTrackingID creates a non-sequential identifier without including
// customer address data or relying on process-global pseudo-random state.
func CreateTrackingID() (string, error) {
	randomBytes := make([]byte, 12)
	if _, err := rand.Read(randomBytes); err != nil {
		return "", fmt.Errorf("generate tracking ID: %w", err)
	}

	id := make([]byte, len(randomBytes))
	for index, value := range randomBytes {
		id[index] = trackingAlphabet[int(value)%len(trackingAlphabet)]
	}
	return "AV-" + string(id), nil
}
