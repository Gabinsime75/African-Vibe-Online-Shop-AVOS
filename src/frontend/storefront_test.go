// Copyright 2026 African Vibe Online Shop (AVOS)
// SPDX-License-Identifier: Apache-2.0

package main

import (
	"context"
	"io"
	"net/http"
	"net/http/httptest"
	"net/url"
	"strings"
	"testing"

	"github.com/google/uuid"
	"github.com/sirupsen/logrus"
)

func withStorefrontPrefix(t *testing.T, prefix string) {
	t.Helper()
	old := baseUrl
	baseUrl = prefix
	t.Cleanup(func() { baseUrl = old })
}

func TestStorefrontSessionIsolationAndCookieScope(t *testing.T) {
	withStorefrontPrefix(t, "/shop")
	t.Setenv("SESSION_COOKIE_SECURE", "false")
	t.Setenv("ENABLE_SINGLE_SHARED_SESSION", "true") // This legacy setting must not merge visitors.
	var observed []string
	handler := ensureSessionID(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) { observed = append(observed, sessionID(r)) }))
	issue := func(value string) *http.Cookie {
		request := httptest.NewRequest(http.MethodGet, "http://avos.example/shop/product/test", nil)
		if value != "" {
			request.AddCookie(&http.Cookie{Name: cookieSessionID, Value: value})
		}
		response := httptest.NewRecorder()
		handler.ServeHTTP(response, request)
		for _, cookie := range response.Result().Cookies() {
			if cookie.Name == cookieSessionID {
				if cookie.Name != "avos_session-id" || cookie.Path != "/shop/" || !cookie.HttpOnly || cookie.SameSite != http.SameSiteLaxMode || cookie.Secure || cookie.Domain != "" || cookie.MaxAge != cookieMaxAge {
					t.Fatalf("invalid cookie attributes: %+v", cookie)
				}
				return cookie
			}
		}
		t.Fatal("session cookie missing")
		return nil
	}
	first, second := issue(""), issue("")
	if first.Value == second.Value {
		t.Fatal("visitors share a session")
	}
	if issue(first.Value).Value != first.Value {
		t.Fatal("valid session was not retained")
	}
	for _, invalid := range []string{"legacy-session", uuid.Nil.String(), "12345678-1234-1234-1234-123456789123"} {
		got := issue(invalid).Value
		parsed, err := uuid.Parse(got)
		if err != nil || parsed.Version() != 4 || got == invalid {
			t.Fatalf("invalid session was not rotated: %q", got)
		}
	}
	if observed[0] != first.Value || observed[1] != second.Value {
		t.Fatal("request context lost session identity")
	}
}

func TestStorefrontSecureCookies(t *testing.T) {
	withStorefrontPrefix(t, "")
	for _, test := range []struct {
		target, forwarded, forced string
		secure                    bool
	}{
		{"http://avos.example/", "", "false", false},
		{"https://avos.example/", "", "false", true},
		{"http://avos.example/", "https", "false", true},
		{"http://avos.example/", "", "true", true},
	} {
		t.Setenv("SESSION_COOKIE_SECURE", test.forced)
		request := httptest.NewRequest(http.MethodGet, test.target, nil)
		request.Header.Set("X-Forwarded-Proto", test.forwarded)
		if got := storefrontCookie(request, cookieSessionID, "value", cookieMaxAge); got.Secure != test.secure || got.Path != "/" {
			t.Fatalf("cookie mismatch: %+v", got)
		}
	}
}

func TestNormalizeStorefrontBaseURL(t *testing.T) {
	for input, want := range map[string]string{"": "", "/": "", "/shop": "/shop", " /shop/v1/ ": "/shop/v1"} {
		got, err := normalizeBaseURL(input)
		if err != nil || got != want {
			t.Fatalf("normalize %q = %q, %v", input, got, err)
		}
	}
	for _, input := range []string{"https://other.example", "//other.example/shop", "shop", "/shop/../outside", "/shop//nested", "/shop?x=y", "/shop#fragment", "/shop%2fnested", "/shop\\outside"} {
		if got, err := normalizeBaseURL(input); err == nil {
			t.Fatalf("accepted invalid prefix %q as %q", input, got)
		}
	}
}

func TestCurrencyRedirectStaysInsideStorefront(t *testing.T) {
	withStorefrontPrefix(t, "/shop")
	logger := logrus.New()
	logger.SetOutput(io.Discard)
	for referer, want := range map[string]string{
		"":                                     "/shop/",
		"https://other.example/shop/cart":      "/shop/",
		"//other.example/shop/cart":            "/shop/",
		"https://avos.example/outside":         "/shop/",
		"https://avos.example/shop/../outside": "/shop/",
		"https://avos.example/shop/cart":       "/shop/cart",
		"/shop/product/test?from=cart":         "/shop/product/test?from=cart",
	} {
		form := url.Values{"currency_code": {"ZAR"}}
		request := httptest.NewRequest(http.MethodPost, "http://avos.example/shop/setCurrency", strings.NewReader(form.Encode()))
		request.Header.Set("Content-Type", "application/x-www-form-urlencoded")
		request.Header.Set("Referer", referer)
		request = request.WithContext(context.WithValue(request.Context(), ctxKeyLog{}, logrus.NewEntry(logger)))
		response := httptest.NewRecorder()
		(&frontendServer{}).setCurrencyHandler(response, request)
		if response.Code != http.StatusFound || response.Header().Get("Location") != want {
			t.Fatalf("referer %q: status %d, location %q", referer, response.Code, response.Header().Get("Location"))
		}
		cookies := response.Result().Cookies()
		if len(cookies) != 1 || cookies[0].Name != "avos_currency" || cookies[0].Value != "ZAR" || cookies[0].Path != "/shop/" || !cookies[0].HttpOnly {
			t.Fatalf("invalid currency cookie: %+v", cookies)
		}
	}
}

func TestLogoutExpiresOnlyAVOSCookies(t *testing.T) {
	withStorefrontPrefix(t, "/shop")
	logger := logrus.New()
	logger.SetOutput(io.Discard)
	request := httptest.NewRequest(http.MethodGet, "http://avos.example/shop/logout", nil)
	request.AddCookie(&http.Cookie{Name: "other_application", Value: "keep"})
	request = request.WithContext(context.WithValue(request.Context(), ctxKeyLog{}, logrus.NewEntry(logger)))
	response := httptest.NewRecorder()
	(&frontendServer{}).logoutHandler(response, request)
	cookies := response.Result().Cookies()
	if len(cookies) != 2 || response.Header().Get("Location") != "/shop/" {
		t.Fatalf("unexpected logout response: %+v", cookies)
	}
	for _, cookie := range cookies {
		if (cookie.Name != cookieSessionID && cookie.Name != cookieCurrency) || cookie.MaxAge != -1 || cookie.Path != "/shop/" || !cookie.HttpOnly {
			t.Fatalf("unexpected expired cookie: %+v", cookie)
		}
	}
}

func TestCurrencyCookieFallsBackWhenUnsupported(t *testing.T) {
	for _, value := range []string{"USD", "ZAR", "not-a-currency", "XCD"} {
		request := httptest.NewRequest(http.MethodGet, "http://avos.example/", nil)
		request.AddCookie(&http.Cookie{Name: cookieCurrency, Value: value})
		want := value
		if value != "USD" && value != "ZAR" {
			want = "USD"
		}
		if got := currentCurrency(request); got != want {
			t.Fatalf("currency %q: got %s, want %s", value, got, want)
		}
	}
}
