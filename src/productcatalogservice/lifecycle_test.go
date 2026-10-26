// Copyright 2026 African Vibe Online Shop (AVOS)
// SPDX-License-Identifier: Apache-2.0

package main

import (
	"context"
	"net"
	"testing"
	"time"

	pb "github.com/Gabinsime75/African-Vibe-Online-Shop-AVOS/src/productcatalogservice/genproto"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"
	"google.golang.org/grpc/health"
	healthpb "google.golang.org/grpc/health/grpc_health_v1"
)

type drainingCatalog struct {
	pb.UnimplementedProductCatalogServiceServer
	started chan struct{}
	release chan struct{}
}

func (s *drainingCatalog) ListProducts(ctx context.Context, _ *pb.Empty) (*pb.ListProductsResponse, error) {
	close(s.started)
	select {
	case <-s.release:
		return &pb.ListProductsResponse{}, nil
	case <-ctx.Done():
		return nil, ctx.Err()
	}
}

func TestCatalogShutdownDrainsActiveRPC(t *testing.T) { testCatalogShutdown(t, false) }
func TestCatalogShutdownForcesStuckRPC(t *testing.T)  { testCatalogShutdown(t, true) }

func testCatalogShutdown(t *testing.T, stuck bool) {
	t.Helper()
	listener, err := net.Listen("tcp", "127.0.0.1:0")
	if err != nil {
		t.Fatal(err)
	}
	defer listener.Close()
	server := grpc.NewServer()
	defer server.Stop()
	service := &drainingCatalog{started: make(chan struct{}), release: make(chan struct{})}
	pb.RegisterProductCatalogServiceServer(server, service)
	healthcheck := health.NewServer()
	healthcheck.SetServingStatus("hipstershop.ProductCatalogService", healthpb.HealthCheckResponse_SERVING)
	healthpb.RegisterHealthServer(server, healthcheck)
	go server.Serve(listener)
	connection, err := grpc.NewClient(listener.Addr().String(), grpc.WithTransportCredentials(insecure.NewCredentials()))
	if err != nil {
		t.Fatal(err)
	}
	defer connection.Close()
	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()
	response := make(chan error, 1)
	go func() {
		_, err := pb.NewProductCatalogServiceClient(connection).ListProducts(ctx, &pb.Empty{})
		response <- err
	}()
	select {
	case <-service.started:
	case <-ctx.Done():
		t.Fatal("RPC never started")
	}
	grace := 2 * time.Second
	if stuck {
		grace = 30 * time.Millisecond
	}
	stopped := make(chan struct{})
	go func() { stopCatalogServer(server, healthcheck, grace); close(stopped) }()
	deadline := time.Now().Add(time.Second)
	for {
		check, err := healthcheck.Check(context.Background(), &healthpb.HealthCheckRequest{Service: "hipstershop.ProductCatalogService"})
		if err != nil {
			t.Fatal(err)
		}
		if check.Status == healthpb.HealthCheckResponse_NOT_SERVING {
			break
		}
		if time.Now().After(deadline) {
			t.Fatal("health remained SERVING during shutdown")
		}
		time.Sleep(time.Millisecond)
	}
	if !stuck {
		close(service.release)
	}
	select {
	case <-stopped:
	case <-ctx.Done():
		t.Fatal("shutdown exceeded its bound")
	}
	if err := <-response; !stuck && err != nil {
		t.Fatalf("active RPC was interrupted: %v", err)
	}
}
