// Copyright 2026 African Vibe Online Shop (AVOS)
// SPDX-License-Identifier: Apache-2.0

using System.Threading;
using System.Threading.Tasks;

namespace cartservice.cartstore;

public interface ICartStore
{
    Task AddItemAsync(
        string userId,
        string productId,
        int quantity,
        CancellationToken cancellationToken = default);

    Task EmptyCartAsync(string userId, CancellationToken cancellationToken = default);

    Task<Hipstershop.Cart> GetCartAsync(
        string userId,
        CancellationToken cancellationToken = default);

    Task<bool> PingAsync(CancellationToken cancellationToken = default);
}
