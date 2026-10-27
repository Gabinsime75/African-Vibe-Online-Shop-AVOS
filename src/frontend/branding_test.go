// Copyright 2026 African Vibe Online Shop (AVOS)
// SPDX-License-Identifier: Apache-2.0

package main

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"net/http/httptest"
	"os"
	"path"
	"path/filepath"
	"regexp"
	"strings"
	"testing"
	"time"

	pb "github.com/Gabinsime75/African-Vibe-Online-Shop-AVOS/src/frontend/genproto"
	"github.com/sirupsen/logrus"
)

func TestCatalogAssetsAndStorefrontLinks(t *testing.T) {
	data, err := os.ReadFile(filepath.Join("..", "productcatalogservice", "products.json"))
	if err != nil {
		t.Fatal(err)
	}
	var catalog struct {
		Products []struct{ ID, Name, Description, Picture string }
	}
	if err := json.Unmarshal(data, &catalog); err != nil {
		t.Fatal(err)
	}
	if len(catalog.Products) == 0 {
		t.Fatal("empty AVOS catalog")
	}
	ids := map[string]bool{}
	for _, product := range catalog.Products {
		if product.ID == "" || ids[product.ID] || product.Name == "" || product.Description == "" {
			t.Fatalf("invalid catalog product: %+v", product)
		}
		ids[product.ID] = true
		if !strings.HasPrefix(product.Picture, "/static/img/products/") || path.Clean(product.Picture) != product.Picture {
			t.Fatalf("invalid image URL %q", product.Picture)
		}
		info, err := os.Stat(strings.TrimPrefix(product.Picture, "/"))
		if err != nil || info.IsDir() || info.Size() == 0 {
			t.Fatalf("missing product image: %s", product.Picture)
		}
	}
	for _, name := range []string{"static/icons/AVOS_Logo.svg", "static/favicon.svg", "static/images/AVOS_HeroPattern.svg"} {
		info, err := os.Stat(name)
		if err != nil || info.IsDir() || info.Size() == 0 {
			t.Fatalf("missing AVOS identity asset: %s", name)
		}
	}
	assetURL := regexp.MustCompile(`/static/[A-Za-z0-9_./-]+`)
	templateFiles, err := filepath.Glob("templates/*.html")
	if err != nil {
		t.Fatal(err)
	}
	for _, name := range templateFiles {
		content, err := os.ReadFile(name)
		if err != nil {
			t.Fatal(err)
		}
		for _, asset := range assetURL.FindAllString(string(content), -1) {
			if _, err := os.Stat(strings.TrimPrefix(asset, "/")); err != nil {
				t.Fatalf("%s references missing asset %s", name, asset)
			}
		}
	}
	css, err := os.ReadFile("static/styles/avos-theme.css")
	if err != nil {
		t.Fatal(err)
	}
	if strings.Contains(string(css), "url(/static/") || !strings.Contains(string(css), "url(../images/AVOS_HeroPattern.svg)") {
		t.Fatal("hero image does not support prefixed routes")
	}
	if !whitelistedCurrencies["ZAR"] || renderMoney(&pb.Money{CurrencyCode: "ZAR", Units: 19, Nanos: 990000000}) != "R19.99" {
		t.Fatal("ZAR is missing or displayed with the wrong currency symbol")
	}
}

func TestAVOSPagesRenderOnceAndHonorURLPrefix(t *testing.T) {
	withStorefrontPrefix(t, "/shop")
	product := &pb.Product{Id: "OLJCESPC7Z", Name: "AVOS Aviator Sunglasses", Description: "AVOS accessories", Picture: "/static/img/products/sunglasses.avif", PriceUsd: &pb.Money{CurrencyCode: "USD", Units: 19, Nanos: 990000000}}
	view := map[string]interface{}{"Item": product, "Price": product.PriceUsd, "Quantity": 1}
	request := httptest.NewRequest(http.MethodGet, "http://avos.example/shop/", nil)
	request = request.WithContext(context.WithValue(request.Context(), ctxKeySessionID{}, "must-not-be-rendered-session"))
	links := regexp.MustCompile(`(?:href|src|action)="(/[^\"]*)"`)
	for _, name := range []string{"home", "product", "cart", "order", "error", "assistant"} {
		t.Run(name, func(t *testing.T) {
			data := injectCommonTemplateData(request, map[string]interface{}{
				"products": []map[string]interface{}{view}, "product": view, "items": []map[string]interface{}{view},
				"currencies": []string{"USD", "ZAR"}, "show_currency": true, "shipping_cost": product.PriceUsd,
				"total_cost": product.PriceUsd, "total_paid": product.PriceUsd, "expiration_years": []int{2030, 2031},
				"order":       &pb.OrderResult{OrderId: "AVOS-TEST", ShippingTrackingId: "DEMO-TEST"},
				"status_code": 500, "status": "Internal Server Error", "error": "private-backend-error",
			})
			var body bytes.Buffer
			if err := templates.ExecuteTemplate(&body, name, data); err != nil {
				t.Fatal(err)
			}
			html := body.String()
			for _, part := range []string{"<!DOCTYPE html>", "<footer", "</html>"} {
				if strings.Count(html, part) != 1 {
					t.Fatalf("%s: expected exactly one %s", name, part)
				}
			}
			for _, forbidden := range []string{"must-not-be-rendered-session", "session-id:", "Cluster:", "Pod:", "private-backend-error", "Amphitheatre", "Mountain View", "Online Boutique", "Hipster Shop", "CloudHustler"} {
				if strings.Contains(html, forbidden) {
					t.Fatalf("%s exposes obsolete or internal text %q", name, forbidden)
				}
			}
			if !strings.Contains(html, "African Vibe Online Shop") || !strings.Contains(html, fmt.Sprint(time.Now().Year())) {
				t.Fatalf("%s lacks current AVOS identity", name)
			}
			for _, match := range links.FindAllStringSubmatch(html, -1) {
				if !strings.HasPrefix(match[1], "/shop/") {
					t.Fatalf("%s escaped URL prefix: %s", name, match[1])
				}
			}
			if name == "cart" && (!strings.Contains(html, "do not enter real card information") || !strings.Contains(html, `value="12">December`)) {
				t.Fatal("checkout lacks simulated-payment guidance or correct month label")
			}
		})
	}
}

func TestCustomerErrorRetainsSupportReferenceWithoutBackendDetails(t *testing.T) {
	withStorefrontPrefix(t, "")
	logger := logrus.New()
	var logs bytes.Buffer
	logger.SetOutput(&logs)
	request := httptest.NewRequest(http.MethodGet, "http://avos.example/", nil)
	request = request.WithContext(context.WithValue(request.Context(), ctxKeyRequestID{}, "AVOS-support-reference"))
	response := httptest.NewRecorder()
	renderHTTPError(logger, request, response, fmt.Errorf("internal-database-host: connection failed"), http.StatusInternalServerError)
	if response.Code != 500 || !strings.Contains(response.Body.String(), "AVOS-support-reference") || strings.Contains(response.Body.String(), "internal-database-host") {
		t.Fatal("customer error leaked diagnostics or lost support reference")
	}
	if !strings.Contains(logs.String(), "internal-database-host") {
		t.Fatal("server diagnostics were lost")
	}
}

func TestRequestLoggingDoesNotExposeAnonymousSession(t *testing.T) {
	logger := logrus.New()
	var output bytes.Buffer
	logger.SetOutput(&output)
	logger.SetLevel(logrus.DebugLevel)
	request := httptest.NewRequest(http.MethodGet, "http://avos.example/", nil)
	request = request.WithContext(context.WithValue(request.Context(), ctxKeySessionID{}, "private-shopping-session"))
	handler := &logHandler{log: logger, next: http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) { _, _ = io.WriteString(w, "ok") })}
	handler.ServeHTTP(httptest.NewRecorder(), request)
	if strings.Contains(output.String(), "private-shopping-session") {
		t.Fatal("session ID was logged")
	}
}
