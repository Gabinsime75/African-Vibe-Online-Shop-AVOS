// Copyright 2026 African Vibe Online Shop (AVOS)
// SPDX-License-Identifier: Apache-2.0

package main

import (
	"context"
	"net"
	"net/http"
	"net/http/httptest"
	"testing"
	"time"

	"go.opentelemetry.io/contrib/instrumentation/google.golang.org/grpc/otelgrpc"
	"go.opentelemetry.io/contrib/instrumentation/net/http/otelhttp"
	"go.opentelemetry.io/otel/baggage"
	"go.opentelemetry.io/otel/propagation"
	sdktrace "go.opentelemetry.io/otel/sdk/trace"
	"go.opentelemetry.io/otel/trace"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"
	healthpb "google.golang.org/grpc/health/grpc_health_v1"
)

type propagatedContext struct {
	traceID, spanID, baggage, state string
	sampled                         bool
}
type propagationHealthServer struct {
	healthpb.UnimplementedHealthServer
	observed chan propagatedContext
}

func (s *propagationHealthServer) Check(ctx context.Context, _ *healthpb.HealthCheckRequest) (*healthpb.HealthCheckResponse, error) {
	span := trace.SpanContextFromContext(ctx)
	s.observed <- propagatedContext{span.TraceID().String(), span.SpanID().String(), baggage.FromContext(ctx).Member("avos.test").Value(), span.TraceState().String(), span.IsSampled()}
	return &healthpb.HealthCheckResponse{Status: healthpb.HealthCheckResponse_SERVING}, nil
}

func TestHTTPToGRPCPreservesW3CContextAndIsolatesRequests(t *testing.T) {
	provider := sdktrace.NewTracerProvider(sdktrace.WithSampler(sdktrace.ParentBased(sdktrace.AlwaysSample())))
	defer provider.Shutdown(context.Background())
	propagator := propagation.NewCompositeTextMapPropagator(propagation.TraceContext{}, propagation.Baggage{})
	observed := make(chan propagatedContext, 1)
	listener, err := net.Listen("tcp", "127.0.0.1:0")
	if err != nil {
		t.Fatal(err)
	}
	server := grpc.NewServer(grpc.StatsHandler(otelgrpc.NewServerHandler(otelgrpc.WithTracerProvider(provider), otelgrpc.WithPropagators(propagator))))
	healthpb.RegisterHealthServer(server, &propagationHealthServer{observed: observed})
	go server.Serve(listener)
	defer server.Stop()
	connection, err := grpc.NewClient(listener.Addr().String(), grpc.WithTransportCredentials(insecure.NewCredentials()), grpc.WithStatsHandler(otelgrpc.NewClientHandler(otelgrpc.WithTracerProvider(provider), otelgrpc.WithPropagators(propagator))))
	if err != nil {
		t.Fatal(err)
	}
	defer connection.Close()
	client := healthpb.NewHealthClient(connection)
	handler := http.HandlerFunc(func(w http.ResponseWriter, request *http.Request) {
		ctx, cancel := context.WithTimeout(request.Context(), 3*time.Second)
		defer cancel()
		if _, err := client.Check(ctx, &healthpb.HealthCheckRequest{}); err != nil {
			http.Error(w, "backend failed", http.StatusBadGateway)
			return
		}
		w.WriteHeader(http.StatusOK)
	})
	frontend := httptest.NewServer(otelhttp.NewHandler(handler, "frontend", otelhttp.WithTracerProvider(provider), otelhttp.WithPropagators(propagator)))
	defer frontend.Close()
	upstream := "1234567890abcdef1234567890abcdef"
	for _, header := range []string{"00-" + upstream + "-1234567890abcdef-01", "00-" + upstream + "-1234567890abcdef-00", "", "malformed"} {
		request, _ := http.NewRequest(http.MethodGet, frontend.URL, nil)
		if header != "" {
			request.Header.Set("traceparent", header)
		}
		if len(header) == 55 {
			request.Header.Set("baggage", "avos.test=propagated")
			request.Header.Set("tracestate", "avos=test")
		}
		response, err := (&http.Client{Timeout: 5 * time.Second}).Do(request)
		if err != nil {
			t.Fatal(err)
		}
		response.Body.Close()
		if response.StatusCode != http.StatusOK {
			t.Fatalf("HTTP status %d", response.StatusCode)
		}
		actual := <-observed
		if len(header) == 55 {
			if actual.traceID != upstream || actual.baggage != "propagated" || actual.state != "avos=test" || actual.spanID == "1234567890abcdef" || actual.sampled != (header[54] == '1') {
				t.Fatalf("lost remote context: %+v", actual)
			}
		} else if actual.traceID == upstream || actual.baggage != "" || actual.state != "" {
			t.Fatalf("context leaked: %+v", actual)
		}
	}
}
