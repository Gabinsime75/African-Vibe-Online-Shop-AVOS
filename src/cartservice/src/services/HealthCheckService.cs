// Copyright 2026 African Vibe Online Shop (AVOS)
// SPDX-License-Identifier: Apache-2.0

using System.Threading.Tasks;
using cartservice.cartstore;
using Grpc.Core;
using Grpc.Health.V1;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;

namespace cartservice.services;

public sealed class HealthCheckService : Health.HealthBase
{
    private readonly ICartStore _cartStore;
    private readonly ILogger<HealthCheckService> _logger;
    private readonly IHostApplicationLifetime _lifetime;

    public HealthCheckService(
        ICartStore cartStore,
        ILogger<HealthCheckService> logger,
        IHostApplicationLifetime lifetime)
    {
        _cartStore = cartStore;
        _logger = logger;
        _lifetime = lifetime;
    }

    public override async Task<HealthCheckResponse> Check(
        HealthCheckRequest request,
        ServerCallContext context)
    {
        if (request.Service != "" && request.Service != "readiness"
            && request.Service != "liveness" && request.Service != "hipstershop.CartService")
        {
            throw new RpcException(new Status(StatusCode.NotFound, "Unknown health service"));
        }

        var healthy = !_lifetime.ApplicationStopping.IsCancellationRequested
            && (request.Service == "liveness"
                || await _cartStore.PingAsync(context.CancellationToken));
        if (!healthy)
        {
            _logger.LogWarning("Cart health check reported NOT_SERVING");
        }

        return new HealthCheckResponse
        {
            Status = healthy
                ? HealthCheckResponse.Types.ServingStatus.Serving
                : HealthCheckResponse.Types.ServingStatus.NotServing
        };
    }
}
