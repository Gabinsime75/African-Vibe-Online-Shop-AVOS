// Copyright 2018 Google LLC
// Modifications copyright 2026 African Vibe Online Shop (AVOS)
// SPDX-License-Identifier: Apache-2.0

package main

import (
	"context"
	"regexp"
	"testing"

	pb "github.com/Gabinsime75/African-Vibe-Online-Shop-AVOS/src/shippingservice/genproto"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

func TestGetQuoteUsesTotalQuantity(t *testing.T) {
	service := &server{}
	response, err := service.GetQuote(context.Background(), &pb.GetQuoteRequest{Items: []*pb.CartItem{
		{ProductId: "avos-textile-01", Quantity: 1},
		{ProductId: "avos-art-02", Quantity: 3},
	}})
	if err != nil {
		t.Fatalf("GetQuote returned error: %v", err)
	}
	// $4.99 base + (4 × $1.25) = $9.99.
	if response.GetCostUsd().GetUnits() != 9 || response.GetCostUsd().GetNanos() != 990_000_000 {
		t.Fatalf("unexpected quote: %v", response.GetCostUsd())
	}
}

func TestGetQuoteAllowsEmptyCart(t *testing.T) {
	service := &server{}
	response, err := service.GetQuote(context.Background(), &pb.GetQuoteRequest{})
	if err != nil {
		t.Fatalf("GetQuote returned error: %v", err)
	}
	if response.GetCostUsd().GetUnits() != 0 || response.GetCostUsd().GetNanos() != 0 {
		t.Fatalf("empty-cart quote must be zero: %v", response.GetCostUsd())
	}
}

func TestGetQuoteRejectsInvalidQuantity(t *testing.T) {
	service := &server{}
	_, err := service.GetQuote(context.Background(), &pb.GetQuoteRequest{Items: []*pb.CartItem{
		{ProductId: "avos-textile-01", Quantity: 0},
	}})
	if status.Code(err) != codes.InvalidArgument {
		t.Fatalf("expected InvalidArgument, got %v", err)
	}
}

func TestShipOrderCreatesAVOSTrackingID(t *testing.T) {
	service := &server{}
	response, err := service.ShipOrder(context.Background(), &pb.ShipOrderRequest{
		Address: &pb.Address{
			StreetAddress: "100 Market Street",
			City:          "Oklahoma City",
			State:         "OK",
			Country:       "United States",
			ZipCode:       73179,
		},
		Items: []*pb.CartItem{{ProductId: "avos-textile-01", Quantity: 1}},
	})
	if err != nil {
		t.Fatalf("ShipOrder returned error: %v", err)
	}
	if !regexp.MustCompile(`^AV-[A-HJ-NP-Z2-9]{12}$`).MatchString(response.GetTrackingId()) {
		t.Fatalf("malformed tracking ID: %q", response.GetTrackingId())
	}
}

func TestShipOrderRejectsMissingAddress(t *testing.T) {
	service := &server{}
	_, err := service.ShipOrder(context.Background(), &pb.ShipOrderRequest{
		Items: []*pb.CartItem{{ProductId: "avos-textile-01", Quantity: 1}},
	})
	if status.Code(err) != codes.InvalidArgument {
		t.Fatalf("expected InvalidArgument, got %v", err)
	}
}

func TestCreateTrackingIDIsUnique(t *testing.T) {
	first, err := CreateTrackingID()
	if err != nil {
		t.Fatal(err)
	}
	second, err := CreateTrackingID()
	if err != nil {
		t.Fatal(err)
	}
	if first == second {
		t.Fatal("tracking IDs must be unique")
	}
}
