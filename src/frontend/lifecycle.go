// Copyright 2026 African Vibe Online Shop (AVOS)
// SPDX-License-Identifier: Apache-2.0

package main

import (
	"context"
	"errors"
	"net"
	"net/http"
	"sync/atomic"
	"time"
)

type frontendLifecycle struct{ draining atomic.Bool }

func (l *frontendLifecycle) health(w http.ResponseWriter, _ *http.Request) {
	if l.draining.Load() {
		http.Error(w, "draining", http.StatusServiceUnavailable)
		return
	}
	w.WriteHeader(http.StatusOK)
	_, _ = w.Write([]byte("ok"))
}

// Drain active requests without cancelling their request contexts on SIGTERM.
func serveFrontend(ctx context.Context, server *http.Server, listener net.Listener,
	lifecycle *frontendLifecycle, grace time.Duration) error {
	stopped := make(chan error, 1)
	go func() { stopped <- server.Serve(listener) }()
	select {
	case err := <-stopped:
		if errors.Is(err, http.ErrServerClosed) {
			return nil
		}
		return err
	case <-ctx.Done():
		lifecycle.draining.Store(true)
		drainCtx, cancel := context.WithTimeout(context.Background(), grace)
		defer cancel()
		err := server.Shutdown(drainCtx)
		if err != nil {
			_ = server.Close()
		}
		<-stopped
		return err
	}
}
