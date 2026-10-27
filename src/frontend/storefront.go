// Copyright 2026 African Vibe Online Shop (AVOS)
// SPDX-License-Identifier: Apache-2.0

package main

import (
	"fmt"
	"net/http"
	"net/url"
	"os"
	"path"
	"strings"
)

// BASE_URL is an optional local route prefix, never an external origin.
func normalizeBaseURL(value string) (string, error) {
	value = strings.TrimRight(strings.TrimSpace(value), "/")
	if value == "" {
		return "", nil
	}
	parsed, err := url.Parse(value)
	if err != nil || !strings.HasPrefix(value, "/") || strings.HasPrefix(value, "//") || strings.ContainsAny(value, "\\\r\n\t;") {
		return "", fmt.Errorf("BASE_URL must be an absolute local path prefix")
	}
	if parsed.Scheme != "" || parsed.Host != "" || parsed.User != nil || parsed.RawQuery != "" || parsed.ForceQuery || parsed.Fragment != "" || parsed.Path != value || path.Clean(value) != value {
		return "", fmt.Errorf("BASE_URL must contain only a normalized local path prefix")
	}
	return value, nil
}

func storefrontCookie(r *http.Request, name, value string, maxAge int) *http.Cookie {
	return &http.Cookie{
		Name: name, Value: value, Path: baseUrl + "/", MaxAge: maxAge,
		HttpOnly: true, SameSite: http.SameSiteLaxMode,
		// X-Forwarded-Proto is supplied by the approved ingress proxy.
		Secure: r.TLS != nil || strings.EqualFold(r.Header.Get("X-Forwarded-Proto"), "https") || strings.EqualFold(os.Getenv("SESSION_COOKIE_SECURE"), "true"),
	}
}

// Return a local storefront URL even if the Referer is absent or untrusted.
func storefrontReturnPath(r *http.Request) string {
	fallback := baseUrl + "/"
	target, err := url.Parse(r.Referer())
	if err != nil || target == nil || target.Opaque != "" || target.User != nil || target.RawPath != "" || strings.ContainsAny(target.Path, "\\\r\n") {
		return fallback
	}
	if target.Host != "" && !strings.EqualFold(target.Host, r.Host) {
		return fallback
	}
	if target.Scheme != "" && target.Scheme != "http" && target.Scheme != "https" {
		return fallback
	}
	clean := path.Clean(target.Path)
	if strings.HasSuffix(target.Path, "/") && clean != "/" {
		clean += "/"
	}
	if !strings.HasPrefix(clean, baseUrl+"/") {
		return fallback
	}
	if target.RawQuery != "" {
		clean += "?" + target.RawQuery
	}
	return clean
}
