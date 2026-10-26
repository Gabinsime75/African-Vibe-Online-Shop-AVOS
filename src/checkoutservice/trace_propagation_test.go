// Copyright 2026 African Vibe Online Shop (AVOS)
// SPDX-License-Identifier: Apache-2.0
package main

import (
	"context"
	"net"
	"testing"
	"time"

	"go.opentelemetry.io/contrib/instrumentation/google.golang.org/grpc/otelgrpc"
	"go.opentelemetry.io/otel"
	"go.opentelemetry.io/otel/baggage"
	"go.opentelemetry.io/otel/trace"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"
	healthpb "google.golang.org/grpc/health/grpc_health_v1"
	"google.golang.org/grpc/metadata"
)

type traceHealthServer struct {
	healthpb.UnimplementedHealthServer
	downstream healthpb.HealthClient
	observed   chan string
}

func (s *traceHealthServer) Check(ctx context.Context, req *healthpb.HealthCheckRequest) (*healthpb.HealthCheckResponse, error) {
	if s.downstream != nil {
		return s.downstream.Check(ctx, req)
	}
	span := trace.SpanContextFromContext(ctx)
	s.observed <- span.TraceID().String() + ":" + baggage.FromContext(ctx).Member("avos.test").Value()
	return &healthpb.HealthCheckResponse{Status: healthpb.HealthCheckResponse_SERVING}, nil
}

func TestGRPCForwardsContextWithoutCollectorExport(t *testing.T) {
	old := otel.GetTextMapPropagator()
	defer otel.SetTextMapPropagator(old)
	configureTracePropagation()
	observed := make(chan string, 1)
	start := func(svc *traceHealthServer) (*grpc.Server, *grpc.ClientConn) {
		t.Helper()
		listener, err := net.Listen("tcp", "127.0.0.1:0")
		if err != nil {
			t.Fatal(err)
		}
		server := grpc.NewServer(grpc.StatsHandler(otelgrpc.NewServerHandler()))
		healthpb.RegisterHealthServer(server, svc)
		go server.Serve(listener)
		connection, err := grpc.NewClient(listener.Addr().String(), grpc.WithTransportCredentials(insecure.NewCredentials()), grpc.WithStatsHandler(otelgrpc.NewClientHandler()))
		if err != nil {
			server.Stop()
			t.Fatal(err)
		}
		return server, connection
	}
	backend, backConn := start(&traceHealthServer{observed: observed})
	defer backend.Stop()
	defer backConn.Close()
	entry, entryConn := start(&traceHealthServer{downstream: healthpb.NewHealthClient(backConn)})
	defer entry.Stop()
	defer entryConn.Close()
	client := healthpb.NewHealthClient(entryConn)
	traceID := "1234567890abcdef1234567890abcdef"
	for _, remote := range []bool{true, false} {
		ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
		if remote {
			ctx = metadata.NewOutgoingContext(ctx, metadata.Pairs("traceparent", "00-"+traceID+"-1234567890abcdef-01", "baggage", "avos.test=propagated"))
		}
		_, err := client.Check(ctx, &healthpb.HealthCheckRequest{})
		cancel()
		if err != nil {
			t.Fatal(err)
		}
		got := <-observed
		if remote && got != traceID+":propagated" {
			t.Fatalf("context lost: %s", got)
		}
		if !remote && got == traceID+":propagated" {
			t.Fatalf("context leaked: %s", got)
		}
	}
}
