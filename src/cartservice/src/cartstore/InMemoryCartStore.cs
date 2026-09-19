// Copyright 2026 African Vibe Online Shop (AVOS)
// SPDX-License-Identifier: Apache-2.0

using System.Collections.Concurrent;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Hipstershop;

namespace cartservice.cartstore;

/// <summary>
/// Provides an isolated cart store for local development and automated tests.
/// Production environments must use Redis.
/// </summary>
public sealed class InMemoryCartStore : ICartStore
{
    private readonly ConcurrentDictionary<string, ConcurrentDictionary<string, int>> _carts = new();

    public Task AddItemAsync(
        string userId,
        string productId,
        int quantity,
        CancellationToken cancellationToken = default)
    {
        cancellationToken.ThrowIfCancellationRequested();
        var cart = _carts.GetOrAdd(userId, static _ => new ConcurrentDictionary<string, int>());
        cart.AddOrUpdate(productId, quantity, (_, current) => checked(current + quantity));
        return Task.CompletedTask;
    }

    public Task EmptyCartAsync(string userId, CancellationToken cancellationToken = default)
    {
        cancellationToken.ThrowIfCancellationRequested();
        _carts.TryRemove(userId, out _);
        return Task.CompletedTask;
    }

    public Task<Cart> GetCartAsync(string userId, CancellationToken cancellationToken = default)
    {
        cancellationToken.ThrowIfCancellationRequested();
        var response = new Cart();

        if (!_carts.TryGetValue(userId, out var storedCart) || storedCart.IsEmpty)
        {
            return Task.FromResult(response);
        }

        response.UserId = userId;
        response.Items.AddRange(
            storedCart
                .OrderBy(item => item.Key)
                .Select(item => new CartItem { ProductId = item.Key, Quantity = item.Value }));

        return Task.FromResult(response);
    }

    public Task<bool> PingAsync(CancellationToken cancellationToken = default)
    {
        cancellationToken.ThrowIfCancellationRequested();
        return Task.FromResult(true);
    }
}
