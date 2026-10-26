// Copyright 2026 African Vibe Online Shop (AVOS)
// SPDX-License-Identifier: Apache-2.0

using cartservice.cartstore;
using Grpc.Core;
using Grpc.Health.V1;
using Grpc.Net.Client;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.TestHost;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.DependencyInjection.Extensions;
using Microsoft.Extensions.Hosting;
using Xunit;

namespace cartservice.tests;

public sealed class HealthCheckTests
{
    [Fact]
    public async Task StorageFailure_FailsReadinessWithoutFailingLiveness()
    {
        var store = new UnavailableCartStore();
        using var host = await CreateHost(store).StartAsync();
        using var http = host.GetTestClient();
        using var channel = GrpcChannel.ForAddress(http.BaseAddress!, new GrpcChannelOptions
        {
            HttpClient = http
        });
        var client = new Health.HealthClient(channel);

        var live = await client.CheckAsync(new HealthCheckRequest { Service = "liveness" });
        Assert.Equal(HealthCheckResponse.Types.ServingStatus.Serving, live.Status);
        Assert.Equal(0, store.PingCount);

        var ready = await client.CheckAsync(new HealthCheckRequest { Service = "readiness" });
        Assert.Equal(HealthCheckResponse.Types.ServingStatus.NotServing, ready.Status);
        Assert.Equal(1, store.PingCount);

        var overall = await client.CheckAsync(new HealthCheckRequest());
        Assert.Equal(HealthCheckResponse.Types.ServingStatus.NotServing, overall.Status);
    }

    [Fact]
    public async Task UnknownHealthService_ReturnsNotFound()
    {
        var store = new UnavailableCartStore();
        using var host = await CreateHost(store).StartAsync();
        using var http = host.GetTestClient();
        using var channel = GrpcChannel.ForAddress(http.BaseAddress!, new GrpcChannelOptions
        {
            HttpClient = http
        });
        var client = new Health.HealthClient(channel);
        var error = await Assert.ThrowsAsync<RpcException>(async () =>
            await client.CheckAsync(new HealthCheckRequest { Service = "unknown" }));
        Assert.Equal(StatusCode.NotFound, error.StatusCode);
        Assert.Equal(0, store.PingCount);
    }

    [Fact]
    public async Task StoppingHost_WithdrawsHealthWithoutQueryingStorage()
    {
        using var lifetime = new TestLifetime();
        var store = new UnavailableCartStore();
        var service = new services.HealthCheckService(
            store,
            Microsoft.Extensions.Logging.Abstractions.NullLogger<services.HealthCheckService>.Instance,
            lifetime);
        lifetime.StopApplication();
        foreach (var name in new[] { "", "readiness", "liveness", "hipstershop.CartService" })
        {
            var result = await service.Check(new HealthCheckRequest { Service = name }, null!);
            Assert.Equal(HealthCheckResponse.Types.ServingStatus.NotServing, result.Status);
        }
        Assert.Equal(0, store.PingCount);
    }

    private static IHostBuilder CreateHost(ICartStore store) =>
        new HostBuilder().ConfigureWebHost(web => web
            .UseEnvironment("Testing")
            .UseStartup<Startup>()
            .UseTestServer()
            .ConfigureTestServices(services =>
            {
                services.RemoveAll<ICartStore>();
                services.AddSingleton(store);
            }));

    private sealed class TestLifetime : IHostApplicationLifetime, IDisposable
    {
        private readonly CancellationTokenSource _stopping = new();
        public CancellationToken ApplicationStarted => CancellationToken.None;
        public CancellationToken ApplicationStopping => _stopping.Token;
        public CancellationToken ApplicationStopped => CancellationToken.None;
        public void StopApplication() => _stopping.Cancel();
        public void Dispose() => _stopping.Dispose();
    }

    private sealed class UnavailableCartStore : ICartStore
    {
        public int PingCount { get; private set; }
        public Task<bool> PingAsync(CancellationToken cancellationToken = default)
        {
            PingCount++;
            return Task.FromResult(false);
        }
        public Task AddItemAsync(string userId, string productId, int quantity,
            CancellationToken cancellationToken = default) => throw new NotSupportedException();
        public Task EmptyCartAsync(string userId,
            CancellationToken cancellationToken = default) => throw new NotSupportedException();
        public Task<Hipstershop.Cart> GetCartAsync(string userId,
            CancellationToken cancellationToken = default) => throw new NotSupportedException();
    }
}
