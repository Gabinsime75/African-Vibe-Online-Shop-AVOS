// Copyright 2026 African Vibe Online Shop (AVOS)
// SPDX-License-Identifier: Apache-2.0

using System;
using System.Linq;
using System.Threading.Tasks;
using cartservice.cartstore;
using Grpc.Core;
using Grpc.Net.Client;
using Hipstershop;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.TestHost;
using Microsoft.Extensions.Hosting;
using Xunit;
using static Hipstershop.CartService;

namespace cartservice.tests;

public sealed class CartServiceTests
{
    private readonly IHostBuilder _host = new HostBuilder().ConfigureWebHost(webBuilder =>
    {
        webBuilder
            .UseEnvironment("Testing")
            .UseStartup<Startup>()
            .UseTestServer();
    });

    [Fact]
    public async Task GetCart_BeforeAddingItems_ReturnsEmptyCart()
    {
        using var server = await _host.StartAsync();
        var client = CreateClient(server);

        var cart = await client.GetCartAsync(new GetCartRequest { UserId = Guid.NewGuid().ToString() });

        Assert.Equal(new Cart(), cart);
    }

    [Fact]
    public async Task AddItem_WhenProductAlreadyExists_IncrementsQuantity()
    {
        using var server = await _host.StartAsync();
        var client = CreateClient(server);
        var userId = Guid.NewGuid().ToString();
        var request = new AddItemRequest
        {
            UserId = userId,
            Item = new CartItem { ProductId = "african-print-bag", Quantity = 1 }
        };

        await client.AddItemAsync(request);
        await client.AddItemAsync(request);
        var cart = await client.GetCartAsync(new GetCartRequest { UserId = userId });

        Assert.Equal(userId, cart.UserId);
        Assert.Single(cart.Items);
        Assert.Equal(2, cart.Items[0].Quantity);
    }

    [Fact]
    public async Task EmptyCart_AfterAddingItem_RemovesCart()
    {
        using var server = await _host.StartAsync();
        var client = CreateClient(server);
        var userId = Guid.NewGuid().ToString();

        await client.AddItemAsync(new AddItemRequest
        {
            UserId = userId,
            Item = new CartItem { ProductId = "woven-basket", Quantity = 1 }
        });
        await client.EmptyCartAsync(new EmptyCartRequest { UserId = userId });
        var cart = await client.GetCartAsync(new GetCartRequest { UserId = userId });

        Assert.Empty(cart.Items);
    }

    [Fact]
    public async Task AddItem_WithInvalidQuantity_ReturnsInvalidArgument()
    {
        using var server = await _host.StartAsync();
        var client = CreateClient(server);

        var exception = await Assert.ThrowsAsync<RpcException>(async () =>
            await client.AddItemAsync(new AddItemRequest
            {
                UserId = "session-1",
                Item = new CartItem { ProductId = "woven-basket", Quantity = 0 }
            }));

        Assert.Equal(StatusCode.InvalidArgument, exception.StatusCode);
    }

    [Fact]
    public async Task GetCart_WithBlankUserId_ReturnsInvalidArgument()
    {
        using var server = await _host.StartAsync();
        var client = CreateClient(server);

        var exception = await Assert.ThrowsAsync<RpcException>(async () =>
            await client.GetCartAsync(new GetCartRequest { UserId = " " }));

        Assert.Equal(StatusCode.InvalidArgument, exception.StatusCode);
    }

    [Fact]
    public async Task InMemoryStore_ConcurrentAdds_AreAtomic()
    {
        var store = new InMemoryCartStore();
        var updates = Enumerable.Range(0, 50)
            .Select(_ => store.AddItemAsync("session-atomic", "beaded-necklace", 1));

        await Task.WhenAll(updates);
        var cart = await store.GetCartAsync("session-atomic");

        Assert.Equal(50, cart.Items.Single().Quantity);
    }

    private static CartServiceClient CreateClient(IHost server)
    {
        var httpClient = server.GetTestClient();
        var channel = GrpcChannel.ForAddress(httpClient.BaseAddress!, new GrpcChannelOptions
        {
            HttpClient = httpClient
        });

        return new CartServiceClient(channel);
    }
}
