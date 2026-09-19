// Copyright 2026 African Vibe Online Shop (AVOS)
// SPDX-License-Identifier: Apache-2.0

package main

import (
	"context"
	"errors"
	"fmt"
	"net"
	"net/mail"
	"os"
	"os/signal"
	"regexp"
	"strings"
	"syscall"
	"time"

	"github.com/google/uuid"
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
	"google.golang.org/grpc/credentials/insecure"
	"google.golang.org/grpc/health"
	healthpb "google.golang.org/grpc/health/grpc_health_v1"
	"google.golang.org/grpc/status"

	pb "github.com/Gabinsime75/African-Vibe-Online-Shop-AVOS/src/checkoutservice/genproto"
	"github.com/Gabinsime75/African-Vibe-Online-Shop-AVOS/src/checkoutservice/money"
)

const (
	defaultListenPort        = "5050"
	defaultDownstreamTimeout = 3 * time.Second
	defaultCheckoutTimeout   = 20 * time.Second
	maximumIdentifierLength  = 128
)

var (
	log          = newLogger()
	currencyCode = regexp.MustCompile(`^[A-Z]{3}$`)
	cardDigits   = regexp.MustCompile(`^[0-9]{12,19}$`)
)

type serviceConfig struct {
	port                  string
	productCatalogSvcAddr string
	cartSvcAddr           string
	currencySvcAddr       string
	shippingSvcAddr       string
	emailSvcAddr          string
	paymentSvcAddr        string
	downstreamTimeout     time.Duration
	checkoutTimeout       time.Duration
	enableOpenTelemetry   bool
}

type checkoutService struct {
	pb.UnimplementedCheckoutServiceServer

	productCatalogSvcConn *grpc.ClientConn
	cartSvcConn           *grpc.ClientConn
	currencySvcConn       *grpc.ClientConn
	shippingSvcConn       *grpc.ClientConn
	emailSvcConn          *grpc.ClientConn
	paymentSvcConn        *grpc.ClientConn

	downstreamTimeout time.Duration
	checkoutTimeout   time.Duration
}

func main() {
	cfg, err := loadConfig()
	if err != nil {
		log.WithError(err).Fatal("invalid service configuration")
	}

	shutdownTelemetry := func(context.Context) error { return nil }
	if cfg.enableOpenTelemetry {
		shutdownTelemetry, err = initTelemetry(context.Background())
		if err != nil {
			log.WithError(err).Fatal("failed to initialize OpenTelemetry")
		}
		log.Info("OpenTelemetry enabled")
	} else {
		log.Info("OpenTelemetry disabled")
	}

	svc, connections, err := newCheckoutService(cfg)
	if err != nil {
		log.WithError(err).Fatal("failed to configure downstream gRPC clients")
	}
	defer closeConnections(connections)

	listener, err := net.Listen("tcp", ":"+cfg.port)
	if err != nil {
		log.WithError(err).Fatal("failed to open checkout service listener")
	}

	server := grpc.NewServer(
		grpc.StatsHandler(otelgrpc.NewServerHandler()),
		grpc.MaxRecvMsgSize(64*1024),
	)
	pb.RegisterCheckoutServiceServer(server, svc)

	healthServer := health.NewServer()
	healthpb.RegisterHealthServer(server, healthServer)
	healthServer.SetServingStatus("", healthpb.HealthCheckResponse_SERVING)

	serveErrors := make(chan error, 1)
	go func() {
		log.WithField("address", listener.Addr().String()).Info("AVOS Checkout Service listening")
		serveErrors <- server.Serve(listener)
	}()

	signals := make(chan os.Signal, 1)
	signal.Notify(signals, syscall.SIGINT, syscall.SIGTERM)

	select {
	case receivedSignal := <-signals:
		log.WithField("signal", receivedSignal.String()).Info("shutdown requested")
	case serveErr := <-serveErrors:
		if serveErr != nil && !errors.Is(serveErr, grpc.ErrServerStopped) {
			log.WithError(serveErr).Error("gRPC server stopped unexpectedly")
		}
	}

	healthServer.SetServingStatus("", healthpb.HealthCheckResponse_NOT_SERVING)
	gracefulStop(server, 10*time.Second)

	shutdownContext, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()
	if err := shutdownTelemetry(shutdownContext); err != nil {
		log.WithError(err).Warn("failed to flush telemetry during shutdown")
	}
}

func newLogger() *logrus.Logger {
	logger := logrus.New()
	logger.SetOutput(os.Stdout)
	logger.SetLevel(logrus.InfoLevel)
	logger.SetFormatter(&logrus.JSONFormatter{
		FieldMap: logrus.FieldMap{
			logrus.FieldKeyTime:  "timestamp",
			logrus.FieldKeyLevel: "severity",
			logrus.FieldKeyMsg:   "message",
		},
		TimestampFormat: time.RFC3339Nano,
	})
	logger.AddHook(serviceFieldHook{})
	return logger
}

type serviceFieldHook struct{}

func (serviceFieldHook) Levels() []logrus.Level { return logrus.AllLevels }
func (serviceFieldHook) Fire(entry *logrus.Entry) error {
	entry.Data["service"] = "checkoutservice"
	return nil
}

func loadConfig() (serviceConfig, error) {
	cfg := serviceConfig{
		port:                envOrDefault("PORT", defaultListenPort),
		downstreamTimeout:   defaultDownstreamTimeout,
		checkoutTimeout:     defaultCheckoutTimeout,
		enableOpenTelemetry: envBool("ENABLE_OTEL", true),
	}

	required := map[string]*string{
		"PRODUCT_CATALOG_SERVICE_ADDR": &cfg.productCatalogSvcAddr,
		"CART_SERVICE_ADDR":            &cfg.cartSvcAddr,
		"CURRENCY_SERVICE_ADDR":        &cfg.currencySvcAddr,
		"SHIPPING_SERVICE_ADDR":        &cfg.shippingSvcAddr,
		"EMAIL_SERVICE_ADDR":           &cfg.emailSvcAddr,
		"PAYMENT_SERVICE_ADDR":         &cfg.paymentSvcAddr,
	}
	for key, destination := range required {
		value := strings.TrimSpace(os.Getenv(key))
		if value == "" {
			return serviceConfig{}, fmt.Errorf("%s is required", key)
		}
		*destination = value
	}

	var err error
	if cfg.downstreamTimeout, err = envDuration("DOWNSTREAM_TIMEOUT", defaultDownstreamTimeout); err != nil {
		return serviceConfig{}, err
	}
	if cfg.checkoutTimeout, err = envDuration("CHECKOUT_TIMEOUT", defaultCheckoutTimeout); err != nil {
		return serviceConfig{}, err
	}
	if cfg.checkoutTimeout <= cfg.downstreamTimeout {
		return serviceConfig{}, errors.New("CHECKOUT_TIMEOUT must be greater than DOWNSTREAM_TIMEOUT")
	}

	return cfg, nil
}

func envOrDefault(key, fallback string) string {
	if value := strings.TrimSpace(os.Getenv(key)); value != "" {
		return value
	}
	return fallback
}

func envBool(key string, fallback bool) bool {
	value := strings.ToLower(strings.TrimSpace(os.Getenv(key)))
	if value == "" {
		return fallback
	}
	return value == "1" || value == "true" || value == "yes"
}

func envDuration(key string, fallback time.Duration) (time.Duration, error) {
	value := strings.TrimSpace(os.Getenv(key))
	if value == "" {
		return fallback, nil
	}
	duration, err := time.ParseDuration(value)
	if err != nil || duration <= 0 {
		return 0, fmt.Errorf("%s must be a positive Go duration", key)
	}
	return duration, nil
}

func initTelemetry(ctx context.Context) (func(context.Context) error, error) {
	setupContext, cancel := context.WithTimeout(ctx, 5*time.Second)
	defer cancel()

	exporter, err := otlptracegrpc.New(setupContext)
	if err != nil {
		return nil, err
	}

	serviceResource := resource.NewWithAttributes(
		"",
		attribute.String("service.name", "checkoutservice"),
		attribute.String("service.namespace", "avos"),
	)
	provider := sdktrace.NewTracerProvider(
		sdktrace.WithResource(serviceResource),
		sdktrace.WithBatcher(exporter),
		sdktrace.WithSampler(sdktrace.ParentBased(sdktrace.TraceIDRatioBased(0.25))),
	)
	otel.SetTracerProvider(provider)
	otel.SetTextMapPropagator(propagation.NewCompositeTextMapPropagator(
		propagation.TraceContext{},
		propagation.Baggage{},
	))

	return provider.Shutdown, nil
}

func newCheckoutService(cfg serviceConfig) (*checkoutService, []*grpc.ClientConn, error) {
	addresses := []string{
		cfg.productCatalogSvcAddr,
		cfg.cartSvcAddr,
		cfg.currencySvcAddr,
		cfg.shippingSvcAddr,
		cfg.emailSvcAddr,
		cfg.paymentSvcAddr,
	}
	connections := make([]*grpc.ClientConn, 0, len(addresses))

	for _, address := range addresses {
		connection, err := grpc.NewClient(
			address,
			grpc.WithTransportCredentials(insecure.NewCredentials()),
			grpc.WithStatsHandler(otelgrpc.NewClientHandler()),
		)
		if err != nil {
			closeConnections(connections)
			return nil, nil, fmt.Errorf("create gRPC client for %s: %w", address, err)
		}
		connections = append(connections, connection)
	}

	return &checkoutService{
		productCatalogSvcConn: connections[0],
		cartSvcConn:           connections[1],
		currencySvcConn:       connections[2],
		shippingSvcConn:       connections[3],
		emailSvcConn:          connections[4],
		paymentSvcConn:        connections[5],
		downstreamTimeout:     cfg.downstreamTimeout,
		checkoutTimeout:       cfg.checkoutTimeout,
	}, connections, nil
}

func closeConnections(connections []*grpc.ClientConn) {
	for _, connection := range connections {
		if err := connection.Close(); err != nil {
			log.WithError(err).Warn("failed to close downstream gRPC connection")
		}
	}
}

func gracefulStop(server *grpc.Server, timeout time.Duration) {
	stopped := make(chan struct{})
	go func() {
		server.GracefulStop()
		close(stopped)
	}()

	select {
	case <-stopped:
		log.Info("gRPC server stopped gracefully")
	case <-time.After(timeout):
		log.Warn("graceful shutdown timed out; forcing server stop")
		server.Stop()
	}
}

func (cs *checkoutService) PlaceOrder(ctx context.Context, request *pb.PlaceOrderRequest) (*pb.PlaceOrderResponse, error) {
	if err := validatePlaceOrderRequest(request, time.Now().UTC()); err != nil {
		return nil, status.Error(codes.InvalidArgument, err.Error())
	}

	checkoutContext, cancel := context.WithTimeout(ctx, cs.checkoutTimeout)
	defer cancel()

	orderID := uuid.NewString()
	logger := log.WithField("order_id", orderID)
	logger.Info("checkout started")

	prepared, err := cs.prepareOrderItemsAndShippingQuoteFromCart(
		checkoutContext,
		request.GetUserId(),
		request.GetUserCurrency(),
		request.GetAddress(),
	)
	if err != nil {
		logger.WithError(err).Error("order preparation failed")
		return nil, publicDownstreamError(err)
	}

	total := &pb.Money{CurrencyCode: request.GetUserCurrency()}
	total, err = money.Sum(total, prepared.shippingCostLocalized)
	if err != nil {
		logger.WithError(err).Error("shipping total calculation failed")
		return nil, status.Error(codes.Internal, "unable to calculate the order total")
	}
	for _, item := range prepared.orderItems {
		itemTotal, multiplyErr := money.Multiply(item.GetCost(), uint32(item.GetItem().GetQuantity()))
		if multiplyErr != nil {
			logger.WithError(multiplyErr).Error("item total calculation failed")
			return nil, status.Error(codes.Internal, "unable to calculate the order total")
		}
		total, err = money.Sum(total, itemTotal)
		if err != nil {
			logger.WithError(err).Error("order total calculation failed")
			return nil, status.Error(codes.Internal, "unable to calculate the order total")
		}
	}

	transactionID, err := cs.chargeCard(checkoutContext, total, request.GetCreditCard())
	if err != nil {
		logger.WithError(err).Error("payment failed")
		return nil, publicPaymentError(err)
	}
	logger.WithField("transaction_id", transactionID).Info("payment completed")

	trackingID, err := cs.shipOrder(checkoutContext, request.GetAddress(), prepared.cartItems)
	if err != nil {
		logger.WithError(err).WithField("incident_required", true).Error("shipment creation failed after payment")
		return nil, status.Error(codes.Unavailable, "payment completed but shipment creation failed; support intervention is required")
	}

	order := &pb.OrderResult{
		OrderId:            orderID,
		ShippingTrackingId: trackingID,
		ShippingCost:       prepared.shippingCostLocalized,
		ShippingAddress:    request.GetAddress(),
		Items:              prepared.orderItems,
	}

	if err := cs.emptyUserCart(checkoutContext, request.GetUserId()); err != nil {
		logger.WithError(err).Warn("order completed but the cart could not be emptied")
	}
	if err := cs.sendOrderConfirmation(checkoutContext, request.GetEmail(), order); err != nil {
		logger.WithError(err).Warn("order completed but confirmation email delivery failed")
	}

	logger.WithField("tracking_id", trackingID).Info("checkout completed")
	return &pb.PlaceOrderResponse{Order: order}, nil
}

type orderPrep struct {
	orderItems            []*pb.OrderItem
	cartItems             []*pb.CartItem
	shippingCostLocalized *pb.Money
}

func (cs *checkoutService) prepareOrderItemsAndShippingQuoteFromCart(
	ctx context.Context,
	userID string,
	userCurrency string,
	address *pb.Address,
) (orderPrep, error) {
	var output orderPrep
	cartItems, err := cs.getUserCart(ctx, userID)
	if err != nil {
		return output, fmt.Errorf("cart service: %w", err)
	}
	if len(cartItems) == 0 {
		return output, status.Error(codes.FailedPrecondition, "the cart is empty")
	}

	orderItems, err := cs.prepareOrderItems(ctx, cartItems, userCurrency)
	if err != nil {
		return output, err
	}
	shippingUSD, err := cs.quoteShipping(ctx, address, cartItems)
	if err != nil {
		return output, fmt.Errorf("shipping service: %w", err)
	}
	shippingPrice, err := cs.convertCurrency(ctx, shippingUSD, userCurrency)
	if err != nil {
		return output, fmt.Errorf("currency service: %w", err)
	}

	output.shippingCostLocalized = shippingPrice
	output.cartItems = cartItems
	output.orderItems = orderItems
	return output, nil
}

func (cs *checkoutService) getUserCart(ctx context.Context, userID string) ([]*pb.CartItem, error) {
	callContext, cancel := context.WithTimeout(ctx, cs.downstreamTimeout)
	defer cancel()
	cart, err := pb.NewCartServiceClient(cs.cartSvcConn).GetCart(callContext, &pb.GetCartRequest{UserId: userID})
	if err != nil {
		return nil, err
	}
	return cart.GetItems(), nil
}

func (cs *checkoutService) emptyUserCart(ctx context.Context, userID string) error {
	callContext, cancel := context.WithTimeout(ctx, cs.downstreamTimeout)
	defer cancel()
	_, err := pb.NewCartServiceClient(cs.cartSvcConn).EmptyCart(callContext, &pb.EmptyCartRequest{UserId: userID})
	return err
}

func (cs *checkoutService) prepareOrderItems(ctx context.Context, items []*pb.CartItem, currency string) ([]*pb.OrderItem, error) {
	output := make([]*pb.OrderItem, len(items))
	client := pb.NewProductCatalogServiceClient(cs.productCatalogSvcConn)

	for index, item := range items {
		if item.GetQuantity() <= 0 {
			return nil, status.Error(codes.FailedPrecondition, "the cart contains an invalid item quantity")
		}
		callContext, cancel := context.WithTimeout(ctx, cs.downstreamTimeout)
		product, err := client.GetProduct(callContext, &pb.GetProductRequest{Id: item.GetProductId()})
		cancel()
		if err != nil {
			return nil, fmt.Errorf("product catalog service: %w", err)
		}
		price, err := cs.convertCurrency(ctx, product.GetPriceUsd(), currency)
		if err != nil {
			return nil, fmt.Errorf("currency service: %w", err)
		}
		output[index] = &pb.OrderItem{Item: item, Cost: price}
	}
	return output, nil
}

func (cs *checkoutService) quoteShipping(ctx context.Context, address *pb.Address, items []*pb.CartItem) (*pb.Money, error) {
	callContext, cancel := context.WithTimeout(ctx, cs.downstreamTimeout)
	defer cancel()
	response, err := pb.NewShippingServiceClient(cs.shippingSvcConn).GetQuote(callContext, &pb.GetQuoteRequest{
		Address: address,
		Items:   items,
	})
	if err != nil {
		return nil, err
	}
	if response.GetCostUsd() == nil {
		return nil, errors.New("shipping quote did not include a cost")
	}
	return response.GetCostUsd(), nil
}

func (cs *checkoutService) convertCurrency(ctx context.Context, from *pb.Money, targetCurrency string) (*pb.Money, error) {
	if from == nil {
		return nil, errors.New("source amount is missing")
	}
	callContext, cancel := context.WithTimeout(ctx, cs.downstreamTimeout)
	defer cancel()
	return pb.NewCurrencyServiceClient(cs.currencySvcConn).Convert(callContext, &pb.CurrencyConversionRequest{
		From:   from,
		ToCode: targetCurrency,
	})
}

func (cs *checkoutService) chargeCard(ctx context.Context, amount *pb.Money, card *pb.CreditCardInfo) (string, error) {
	callContext, cancel := context.WithTimeout(ctx, cs.downstreamTimeout)
	defer cancel()
	response, err := pb.NewPaymentServiceClient(cs.paymentSvcConn).Charge(callContext, &pb.ChargeRequest{
		Amount:     amount,
		CreditCard: card,
	})
	if err != nil {
		return "", err
	}
	if response.GetTransactionId() == "" {
		return "", errors.New("payment response did not include a transaction ID")
	}
	return response.GetTransactionId(), nil
}

func (cs *checkoutService) shipOrder(ctx context.Context, address *pb.Address, items []*pb.CartItem) (string, error) {
	callContext, cancel := context.WithTimeout(ctx, cs.downstreamTimeout)
	defer cancel()
	response, err := pb.NewShippingServiceClient(cs.shippingSvcConn).ShipOrder(callContext, &pb.ShipOrderRequest{
		Address: address,
		Items:   items,
	})
	if err != nil {
		return "", err
	}
	if response.GetTrackingId() == "" {
		return "", errors.New("shipping response did not include a tracking ID")
	}
	return response.GetTrackingId(), nil
}

func (cs *checkoutService) sendOrderConfirmation(ctx context.Context, email string, order *pb.OrderResult) error {
	callContext, cancel := context.WithTimeout(ctx, cs.downstreamTimeout)
	defer cancel()
	_, err := pb.NewEmailServiceClient(cs.emailSvcConn).SendOrderConfirmation(
		callContext,
		&pb.SendOrderConfirmationRequest{Email: email, Order: order},
	)
	return err
}

func validatePlaceOrderRequest(request *pb.PlaceOrderRequest, now time.Time) error {
	if request == nil {
		return errors.New("request is required")
	}
	if err := validateText(request.GetUserId(), "user_id", maximumIdentifierLength); err != nil {
		return err
	}
	if !currencyCode.MatchString(request.GetUserCurrency()) {
		return errors.New("user_currency must be a three-letter uppercase currency code")
	}
	if _, err := mail.ParseAddress(request.GetEmail()); err != nil {
		return errors.New("email must be a valid address")
	}

	address := request.GetAddress()
	if address == nil {
		return errors.New("address is required")
	}
	for field, value := range map[string]string{
		"address.street_address": address.GetStreetAddress(),
		"address.city":           address.GetCity(),
		"address.country":        address.GetCountry(),
	} {
		if err := validateText(value, field, 200); err != nil {
			return err
		}
	}
	if address.GetZipCode() <= 0 {
		return errors.New("address.zip_code must be greater than zero")
	}

	card := request.GetCreditCard()
	if card == nil {
		return errors.New("credit_card is required")
	}
	cardNumber := strings.ReplaceAll(strings.ReplaceAll(card.GetCreditCardNumber(), " ", ""), "-", "")
	if !cardDigits.MatchString(cardNumber) {
		return errors.New("credit_card number must contain between 12 and 19 digits")
	}
	if card.GetCreditCardCvv() < 100 || card.GetCreditCardCvv() > 9999 {
		return errors.New("credit_card CVV is invalid")
	}
	if card.GetCreditCardExpirationMonth() < 1 || card.GetCreditCardExpirationMonth() > 12 {
		return errors.New("credit_card expiration month is invalid")
	}
	if card.GetCreditCardExpirationYear() < int32(now.Year()) ||
		(card.GetCreditCardExpirationYear() == int32(now.Year()) && card.GetCreditCardExpirationMonth() < int32(now.Month())) {
		return errors.New("credit_card is expired")
	}
	return nil
}

func validateText(value, field string, maximumLength int) error {
	trimmed := strings.TrimSpace(value)
	if trimmed == "" {
		return fmt.Errorf("%s is required", field)
	}
	if len(trimmed) > maximumLength {
		return fmt.Errorf("%s must not exceed %d characters", field, maximumLength)
	}
	return nil
}

func publicDownstreamError(err error) error {
	code := status.Code(err)
	switch code {
	case codes.FailedPrecondition:
		return status.Error(codes.FailedPrecondition, status.Convert(err).Message())
	case codes.DeadlineExceeded:
		return status.Error(codes.DeadlineExceeded, "checkout dependency timed out")
	case codes.Canceled:
		return status.Error(codes.Canceled, "checkout request was canceled")
	default:
		return status.Error(codes.Unavailable, "a checkout dependency is temporarily unavailable")
	}
}

func publicPaymentError(err error) error {
	if status.Code(err) == codes.InvalidArgument || status.Code(err) == codes.FailedPrecondition {
		return status.Error(codes.FailedPrecondition, "payment was declined or the payment information is invalid")
	}
	if status.Code(err) == codes.DeadlineExceeded {
		return status.Error(codes.DeadlineExceeded, "payment processing timed out")
	}
	return status.Error(codes.Unavailable, "payment processing is temporarily unavailable")
}
