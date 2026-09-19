// Copyright 2026 African Vibe Online Shop (AVOS)
// SPDX-License-Identifier: Apache-2.0

package main

import (
	"strings"
	"testing"
	"time"

	pb "github.com/Gabinsime75/African-Vibe-Online-Shop-AVOS/src/checkoutservice/genproto"
)

func validRequest() *pb.PlaceOrderRequest {
	return &pb.PlaceOrderRequest{
		UserId:       "session-1",
		UserCurrency: "USD",
		Email:        "customer@example.com",
		Address: &pb.Address{
			StreetAddress: "100 AVOS Way",
			City:          "Oklahoma City",
			State:         "OK",
			Country:       "United States",
			ZipCode:       73179,
		},
		CreditCard: &pb.CreditCardInfo{
			CreditCardNumber:          "4111111111111111",
			CreditCardCvv:             123,
			CreditCardExpirationMonth: 12,
			CreditCardExpirationYear:  2030,
		},
	}
}

func TestValidatePlaceOrderRequest(t *testing.T) {
	now := time.Date(2026, time.September, 19, 0, 0, 0, 0, time.UTC)
	tests := []struct {
		name        string
		change      func(*pb.PlaceOrderRequest)
		wantMessage string
	}{
		{name: "valid", change: func(*pb.PlaceOrderRequest) {}},
		{
			name:        "missing user",
			change:      func(request *pb.PlaceOrderRequest) { request.UserId = "" },
			wantMessage: "user_id is required",
		},
		{
			name:        "invalid currency",
			change:      func(request *pb.PlaceOrderRequest) { request.UserCurrency = "usd" },
			wantMessage: "three-letter uppercase",
		},
		{
			name:        "missing address",
			change:      func(request *pb.PlaceOrderRequest) { request.Address = nil },
			wantMessage: "address is required",
		},
		{
			name: "expired card",
			change: func(request *pb.PlaceOrderRequest) {
				request.CreditCard.CreditCardExpirationYear = 2025
			},
			wantMessage: "expired",
		},
	}

	for _, test := range tests {
		t.Run(test.name, func(t *testing.T) {
			request := validRequest()
			test.change(request)
			err := validatePlaceOrderRequest(request, now)
			if test.wantMessage == "" && err != nil {
				t.Fatalf("validatePlaceOrderRequest() error = %v", err)
			}
			if test.wantMessage != "" && (err == nil || !strings.Contains(err.Error(), test.wantMessage)) {
				t.Fatalf("validatePlaceOrderRequest() error = %v, want text %q", err, test.wantMessage)
			}
		})
	}
}

func TestEnvDurationRejectsInvalidValue(t *testing.T) {
	t.Setenv("TEST_DURATION", "not-a-duration")
	if _, err := envDuration("TEST_DURATION", time.Second); err == nil {
		t.Fatal("envDuration() expected an error")
	}
}
