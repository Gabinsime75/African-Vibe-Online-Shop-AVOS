// Copyright 2026 African Vibe Online Shop (AVOS)
// SPDX-License-Identifier: Apache-2.0

using System;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Hipstershop;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using StackExchange.Redis;

namespace cartservice.cartstore;

/// <summary>
/// Persists each AVOS cart as a Redis hash so item quantity updates are atomic.
/// </summary>
public sealed class RedisCartStore : ICartStore
{
    private const string DefaultKeyPrefix = "avos:cart";
    private const int DefaultCartTtlHours = 168;

    private readonly IDatabase _database;
    private readonly ILogger<RedisCartStore> _logger;
    private readonly string _keyPrefix;
    private readonly TimeSpan _cartTtl;

    public RedisCartStore(
        IConnectionMultiplexer connection,
        IConfiguration configuration,
        ILogger<RedisCartStore> logger)
    {
        _database = connection.GetDatabase();
        _logger = logger;
        _keyPrefix = configuration["REDIS_KEY_PREFIX"] ?? DefaultKeyPrefix;

        var ttlHours = configuration.GetValue("CART_TTL_HOURS", DefaultCartTtlHours);
        if (ttlHours <= 0)
        {
            throw new InvalidOperationException("CART_TTL_HOURS must be greater than zero.");
        }

        _cartTtl = TimeSpan.FromHours(ttlHours);
    }

    public async Task AddItemAsync(
        string userId,
        string productId,
        int quantity,
        CancellationToken cancellationToken = default)
    {
        cancellationToken.ThrowIfCancellationRequested();
        var key = GetCartKey(userId);

        await _database.HashIncrementAsync(key, productId, quantity).WaitAsync(cancellationToken);
        await _database.KeyExpireAsync(key, _cartTtl).WaitAsync(cancellationToken);

        _logger.LogDebug("Updated cart for user {UserId}", userId);
    }

    public async Task EmptyCartAsync(string userId, CancellationToken cancellationToken = default)
    {
        cancellationToken.ThrowIfCancellationRequested();
        await _database.KeyDeleteAsync(GetCartKey(userId)).WaitAsync(cancellationToken);
        _logger.LogDebug("Emptied cart for user {UserId}", userId);
    }

    public async Task<Cart> GetCartAsync(string userId, CancellationToken cancellationToken = default)
    {
        cancellationToken.ThrowIfCancellationRequested();
        var values = await _database.HashGetAllAsync(GetCartKey(userId)).WaitAsync(cancellationToken);
        var response = new Cart();

        if (values.Length == 0)
        {
            return response;
        }

        response.UserId = userId;
        response.Items.AddRange(
            values
                .OrderBy(entry => entry.Name.ToString(), StringComparer.Ordinal)
                .Select(entry => new CartItem
                {
                    ProductId = entry.Name.ToString(),
                    Quantity = (int)entry.Value
                }));

        return response;
    }

    public async Task<bool> PingAsync(CancellationToken cancellationToken = default)
    {
        try
        {
            await _database.PingAsync().WaitAsync(cancellationToken);
            return true;
        }
        catch (OperationCanceledException) when (cancellationToken.IsCancellationRequested)
        {
            throw;
        }
        catch (Exception exception)
        {
            _logger.LogWarning(exception, "Redis health check failed");
            return false;
        }
    }

    private string GetCartKey(string userId) => $"{_keyPrefix}:{userId}";
}
