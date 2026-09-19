// Copyright 2026 African Vibe Online Shop (AVOS)
// SPDX-License-Identifier: Apache-2.0

using System;
using System.Threading.Tasks;
using cartservice.cartstore;
using Google.Protobuf.WellKnownTypes;
using Grpc.Core;
using Hipstershop;
using Microsoft.Extensions.Logging;

namespace cartservice.services;

public sealed class CartService : Hipstershop.CartService.CartServiceBase
{
    private const int MaximumIdentifierLength = 128;
    private const int MaximumItemQuantity = 100;

    private readonly ICartStore _cartStore;
    private readonly ILogger<CartService> _logger;

    public CartService(ICartStore cartStore, ILogger<CartService> logger)
    {
        _cartStore = cartStore;
        _logger = logger;
    }

    public override async Task<Empty> AddItem(AddItemRequest request, ServerCallContext context)
    {
        ValidateIdentifier(request.UserId, "user_id");

        if (request.Item is null)
        {
            throw InvalidArgument("item is required");
        }

        ValidateIdentifier(request.Item.ProductId, "product_id");
        if (request.Item.Quantity is < 1 or > MaximumItemQuantity)
        {
            throw InvalidArgument($"quantity must be between 1 and {MaximumItemQuantity}");
        }

        try
        {
            await _cartStore.AddItemAsync(
                request.UserId,
                request.Item.ProductId,
                request.Item.Quantity,
                context.CancellationToken);
            _logger.LogInformation(
                "Added product {ProductId} to cart for user {UserId}",
                request.Item.ProductId,
                request.UserId);
            return new Empty();
        }
        catch (OperationCanceledException) when (context.CancellationToken.IsCancellationRequested)
        {
            throw;
        }
        catch (Exception exception)
        {
            _logger.LogError(exception, "Unable to update cart for user {UserId}", request.UserId);
            throw Unavailable();
        }
    }

    public override async Task<Empty> EmptyCart(EmptyCartRequest request, ServerCallContext context)
    {
        ValidateIdentifier(request.UserId, "user_id");

        try
        {
            await _cartStore.EmptyCartAsync(request.UserId, context.CancellationToken);
            _logger.LogInformation("Emptied cart for user {UserId}", request.UserId);
            return new Empty();
        }
        catch (OperationCanceledException) when (context.CancellationToken.IsCancellationRequested)
        {
            throw;
        }
        catch (Exception exception)
        {
            _logger.LogError(exception, "Unable to empty cart for user {UserId}", request.UserId);
            throw Unavailable();
        }
    }

    public override async Task<Cart> GetCart(GetCartRequest request, ServerCallContext context)
    {
        ValidateIdentifier(request.UserId, "user_id");

        try
        {
            return await _cartStore.GetCartAsync(request.UserId, context.CancellationToken);
        }
        catch (OperationCanceledException) when (context.CancellationToken.IsCancellationRequested)
        {
            throw;
        }
        catch (Exception exception)
        {
            _logger.LogError(exception, "Unable to read cart for user {UserId}", request.UserId);
            throw Unavailable();
        }
    }

    private static void ValidateIdentifier(string value, string fieldName)
    {
        if (string.IsNullOrWhiteSpace(value))
        {
            throw InvalidArgument($"{fieldName} is required");
        }

        if (value.Length > MaximumIdentifierLength)
        {
            throw InvalidArgument($"{fieldName} must not exceed {MaximumIdentifierLength} characters");
        }
    }

    private static RpcException InvalidArgument(string message) =>
        new(new Status(StatusCode.InvalidArgument, message));

    private static RpcException Unavailable() =>
        new(new Status(StatusCode.Unavailable, "cart storage is temporarily unavailable"));
}
