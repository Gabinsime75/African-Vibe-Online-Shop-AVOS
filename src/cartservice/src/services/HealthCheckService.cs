// Copyright 2026 African Vibe Online Shop (AVOS)
// SPDX-License-Identifier: Apache-2.0

using System.Threading.Tasks;
using cartservice.cartstore;
using Grpc.Core;
using Grpc.Health.V1;
using Microsoft.Extensions.Logging;

namespace cartservice.services;

public sealed class HealthCheckService : Health.HealthBase
{
    private readonly ICartStore _cartStore;
    private readonly ILogger<HealthCheckService> _logger;

    public HealthCheckService(ICartStore cartStore, ILogger<HealthCheckService> logger)
    {
        _cartStore = cartStore;
        _logger = logger;
    }

    public override async Task<HealthCheckResponse> Check(
        HealthCheckRequest request,
        ServerCallContext context)
    {
        var healthy = await _cartStore.PingAsync(context.CancellationToken);
        if (!healthy)
        {
            _logger.LogWarning("Cart storage health check reported NOT_SERVING");
        }

        return new HealthCheckResponse
        {
            Status = healthy
                ? HealthCheckResponse.Types.ServingStatus.Serving
                : HealthCheckResponse.Types.ServingStatus.NotServing
        };
    }
}
