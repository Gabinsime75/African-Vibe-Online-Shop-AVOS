// Copyright 2018 Google LLC
// Modifications copyright 2026 African Vibe Online Shop (AVOS)
// SPDX-License-Identifier: Apache-2.0

package main

import (
	"context"
	"fmt"
	"net"
	"os"
	"os/signal"
	"strconv"
	"strings"
	"syscall"
	"time"

	"github.com/sirupsen/logrus"
	"go.opentelemetry.io/contrib/instrumentation/google.golang.org/grpc/otelgrpc"
	"go.opentelemetry.io/otel"
	"go.opentelemetry.io/otel/attribute"
	"go.opentelemetry.io/otel/exporters/otlp/otlptrace/otlptracegrpc"
	"go.opentelemetry.io/otel/propagation"
	"go.opentelemetry.io/otel/sdk/resource"
	sdktrace "go.opentelemetry.io/otel/sdk/trace"
	"google.golang.org/grpc"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/health"
	healthpb "google.golang.org/grpc/health/grpc_health_v1"
	"google.golang.org/grpc/reflection"
	"google.golang.org/grpc/status"

	pb "github.com/Gabinsime75/African-Vibe-Online-Shop-AVOS/src/shippingservice/genproto"
)

const (
	defaultPort      = "50051"
	maxMessageSize   = 64 * 1024
	shutdownDeadline = 10 * time.Second
)

var log = newLogger()

type server struct {
	pb.UnimplementedShippingServiceServer
}

func newLogger() *logrus.Logger {
	logger := logrus.New()
	logger.SetLevel(logrus.InfoLevel)
	logger.SetFormatter(&logrus.JSONFormatter{
		FieldMap: logrus.FieldMap{
			logrus.FieldKeyTime:  "timestamp",
			logrus.FieldKeyLevel: "severity",
			logrus.FieldKeyMsg:   "message",
		},
		TimestampFormat: time.RFC3339Nano,
	})
	logger.SetOutput(os.Stdout)
	return logger
}

func main() {
	if err := run(); err != nil {
		log.WithError(err).Fatal("shipping service stopped")
	}
}

func run() error {
	port, err := configuredPort()
	if err != nil {
		return err
	}

	ctx := context.Background()
	shutdownTelemetry, err := initTelemetry(ctx)
	if err != nil {
		return fmt.Errorf("initialize OpenTelemetry: %w", err)
	}
	defer func() {
		shutdownCtx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
		defer cancel()
		if err := shutdownTelemetry(shutdownCtx); err != nil {
			log.WithError(err).Warn("failed to flush telemetry")
		}
	}()

	listener, err := net.Listen("tcp", ":"+port)
	if err != nil {
		return fmt.Errorf("listen on port %s: %w", port, err)
	}

	otel.SetTextMapPropagator(propagation.NewCompositeTextMapPropagator(
		propagation.TraceContext{}, propagation.Baggage{}))
	grpcServer := grpc.NewServer(
		grpc.StatsHandler(otelgrpc.NewServerHandler()),
		grpc.MaxRecvMsgSize(maxMessageSize),
		grpc.MaxSendMsgSize(maxMessageSize),
	)
	pb.RegisterShippingServiceServer(grpcServer, &server{})

	healthServer := health.NewServer()
	healthServer.SetServingStatus("", healthpb.HealthCheckResponse_SERVING)
	healthpb.RegisterHealthServer(grpcServer, healthServer)
	if environmentFlag("ENABLE_GRPC_REFLECTION", false) {
		reflection.Register(grpcServer)
	}

	serveErrors := make(chan error, 1)
	go func() {
		log.WithFields(logrus.Fields{"port": port, "service": "shippingservice"}).Info("AVOS Shipping Service listening")
		serveErrors <- grpcServer.Serve(listener)
	}()

	signalCtx, stop := signal.NotifyContext(context.Background(), syscall.SIGINT, syscall.SIGTERM)
	defer stop()

	select {
	case err := <-serveErrors:
		return fmt.Errorf("serve gRPC: %w", err)
	case <-signalCtx.Done():
		log.Info("shutdown requested")
	}

	healthServer.SetServingStatus("", healthpb.HealthCheckResponse_NOT_SERVING)
	stopped := make(chan struct{})
	go func() {
		grpcServer.GracefulStop()
		close(stopped)
	}()

	select {
	case <-stopped:
		return nil
	case <-time.After(shutdownDeadline):
		log.Warn("graceful shutdown timed out; forcing gRPC server stop")
		grpcServer.Stop()
		return nil
	}
}

func (s *server) GetQuote(_ context.Context, request *pb.GetQuoteRequest) (*pb.GetQuoteResponse, error) {
	itemCount, err := validatedItemCount(request.GetItems())
	if err != nil {
		return nil, status.Error(codes.InvalidArgument, err.Error())
	}

	quote, err := CreateQuoteFromCount(itemCount)
	if err != nil {
		return nil, status.Error(codes.InvalidArgument, err.Error())
	}
	log.WithField("item_count", itemCount).Info("shipping quote calculated")

	return &pb.GetQuoteResponse{CostUsd: &pb.Money{
		CurrencyCode: "USD",
		Units:        quote.Dollars,
		Nanos:        int32(quote.Cents * 10_000_000),
	}}, nil
}

func (s *server) ShipOrder(_ context.Context, request *pb.ShipOrderRequest) (*pb.ShipOrderResponse, error) {
	if err := validateAddress(request.GetAddress()); err != nil {
		return nil, status.Error(codes.InvalidArgument, err.Error())
	}
	itemCount, err := validatedItemCount(request.GetItems())
	if err != nil {
		return nil, status.Error(codes.InvalidArgument, err.Error())
	}
	if itemCount == 0 {
		return nil, status.Error(codes.InvalidArgument, "at least one item is required to create a shipment")
	}

	trackingID, err := CreateTrackingID()
	if err != nil {
		log.WithError(err).Error("tracking ID generation failed")
		return nil, status.Error(codes.Internal, "shipment could not be created")
	}

	// Do not log the customer address or item identifiers.
	log.WithFields(logrus.Fields{"item_count": itemCount, "tracking_id": trackingID}).Info("simulated shipment created")
	return &pb.ShipOrderResponse{TrackingId: trackingID}, nil
}

func validatedItemCount(items []*pb.CartItem) (int64, error) {
	var count int64
	for index, item := range items {
		if item == nil {
			return 0, fmt.Errorf("items[%d] is required", index)
		}
		if strings.TrimSpace(item.GetProductId()) == "" {
			return 0, fmt.Errorf("items[%d].product_id is required", index)
		}
		if item.GetQuantity() <= 0 {
			return 0, fmt.Errorf("items[%d].quantity must be greater than zero", index)
		}
		count += int64(item.GetQuantity())
		if count > maxItemsPerShipment {
			return 0, fmt.Errorf("total item quantity exceeds the shipment limit of %d", maxItemsPerShipment)
		}
	}
	return count, nil
}

func validateAddress(address *pb.Address) error {
	if address == nil {
		return fmt.Errorf("shipping address is required")
	}
	fields := map[string]string{
		"street_address": address.GetStreetAddress(),
		"city":           address.GetCity(),
		"country":        address.GetCountry(),
	}
	for name, value := range fields {
		if strings.TrimSpace(value) == "" {
			return fmt.Errorf("shipping address %s is required", name)
		}
		if len(value) > 200 {
			return fmt.Errorf("shipping address %s is too long", name)
		}
	}
	if address.GetZipCode() <= 0 {
		return fmt.Errorf("shipping address zip_code must be greater than zero")
	}
	return nil
}

func configuredPort() (string, error) {
	port := os.Getenv("PORT")
	if port == "" {
		port = defaultPort
	}
	value, err := strconv.Atoi(port)
	if err != nil || value < 1 || value > 65535 {
		return "", fmt.Errorf("PORT must be between 1 and 65535")
	}
	return port, nil
}

func environmentFlag(name string, fallback bool) bool {
	value, exists := os.LookupEnv(name)
	if !exists || strings.TrimSpace(value) == "" {
		return fallback
	}
	switch strings.ToLower(strings.TrimSpace(value)) {
	case "1", "true", "yes":
		return true
	default:
		return false
	}
}

func initTelemetry(ctx context.Context) (func(context.Context) error, error) {
	if !environmentFlag("ENABLE_OTEL", true) {
		log.Info("OpenTelemetry disabled")
		return func(context.Context) error { return nil }, nil
	}

	exporter, err := otlptracegrpc.New(ctx)
	if err != nil {
		return nil, err
	}
	serviceResource, err := resource.New(ctx, resource.WithAttributes(
		attribute.String("service.name", "shippingservice"),
		attribute.String("service.namespace", "avos"),
		attribute.String("service.version", "1.0.0"),
	))
	if err != nil {
		return nil, err
	}

	provider := sdktrace.NewTracerProvider(
		sdktrace.WithBatcher(exporter),
		sdktrace.WithResource(serviceResource),
	)
	otel.SetTracerProvider(provider)
	log.Info("OpenTelemetry enabled")
	return provider.Shutdown, nil
}
