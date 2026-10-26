// Copyright 2026 African Vibe Online Shop (AVOS)
// SPDX-License-Identifier: Apache-2.0

package main

import (
	"context"
	"io"
	"net"
	"net/http"
	"net/http/httptest"
	"testing"
	"time"
)

func TestFrontendHealthDuringDrain(t *testing.T) {
	lifecycle := &frontendLifecycle{}
	for _, draining := range []bool{false, true} {
		lifecycle.draining.Store(draining)
		response := httptest.NewRecorder()
		lifecycle.health(response, httptest.NewRequest(http.MethodGet, "/_healthz", nil))
		expected := http.StatusOK
		if draining {
			expected = http.StatusServiceUnavailable
		}
		if response.Code != expected {
			t.Fatalf("draining=%v: status=%d", draining, response.Code)
		}
	}
}

func TestFrontendGracefulDrainCompletesActiveRequest(t *testing.T) {
	testFrontendDrain(t, false)
}

func TestFrontendDrainDeadlineClosesStuckRequest(t *testing.T) {
	testFrontendDrain(t, true)
}

func testFrontendDrain(t *testing.T, stuck bool) {
	t.Helper()
	listener, err := net.Listen("tcp", "127.0.0.1:0")
	if err != nil {
		t.Fatal(err)
	}
	defer listener.Close()
	started := make(chan struct{})
	release := make(chan struct{})
	exited := make(chan struct{})
	server := &http.Server{Handler: http.HandlerFunc(func(w http.ResponseWriter, request *http.Request) {
		defer close(exited)
		close(started)
		select {
		case <-release:
			_, _ = w.Write([]byte("completed"))
		case <-request.Context().Done():
		}
	})}
	defer server.Close()
	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()
	lifecycle := &frontendLifecycle{}
	grace := 2 * time.Second
	if stuck {
		grace = 30 * time.Millisecond
	}
	stopped := make(chan error, 1)
	go func() { stopped <- serveFrontend(ctx, server, listener, lifecycle, grace) }()
	response := make(chan error, 1)
	go func() {
		client := &http.Client{Timeout: 3 * time.Second}
		result, err := client.Get("http://" + listener.Addr().String())
		if err == nil {
			defer result.Body.Close()
			body, readErr := io.ReadAll(result.Body)
			if readErr != nil {
				err = readErr
			} else if string(body) != "completed" {
				err = io.ErrUnexpectedEOF
			}
		}
		response <- err
	}()
	select {
	case <-started:
	case <-time.After(3 * time.Second):
		t.Fatal("request never started")
	}
	cancel()
	deadline := time.Now().Add(time.Second)
	for !lifecycle.draining.Load() {
		if time.Now().After(deadline) {
			t.Fatal("readiness was not withdrawn")
		}
		time.Sleep(time.Millisecond)
	}
	if !stuck {
		close(release)
	}
	select {
	case err := <-stopped:
		if stuck && err == nil {
			t.Fatal("stuck request must exhaust the drain deadline")
		}
		if !stuck && err != nil {
			t.Fatal(err)
		}
	case <-time.After(3 * time.Second):
		t.Fatal("shutdown exceeded its bound")
	}
	if err := <-response; !stuck && err != nil {
		t.Fatalf("in-flight request failed: %v", err)
	}
	select {
	case <-exited:
	case <-time.After(time.Second):
		t.Fatal("handler was not released")
	}
}
