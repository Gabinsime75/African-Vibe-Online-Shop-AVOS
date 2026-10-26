// Copyright 2026 African Vibe Online Shop (AVOS)
// SPDX-License-Identifier: Apache-2.0

package main

import (
	"google.golang.org/grpc"
	"google.golang.org/grpc/health"
	"time"
)

func stopCatalogServer(server *grpc.Server, status *health.Server, grace time.Duration) {
	status.Shutdown()
	stopped := make(chan struct{})
	go func() { server.GracefulStop(); close(stopped) }()
	timer := time.NewTimer(grace)
	defer timer.Stop()
	select {
	case <-stopped:
	case <-timer.C:
		server.Stop()
		<-stopped
	}
}
