// Copyright 2026 African Vibe Online Shop (AVOS)
// SPDX-License-Identifier: Apache-2.0

using System;
using cartservice.cartstore;
using cartservice.services;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using OpenTelemetry.Metrics;
using OpenTelemetry.Resources;
using OpenTelemetry.Trace;
using StackExchange.Redis;

namespace cartservice;

public sealed class Startup
{
    private readonly IWebHostEnvironment _environment;

    public Startup(IConfiguration configuration, IWebHostEnvironment environment)
    {
        Configuration = configuration;
        _environment = environment;
    }

    public IConfiguration Configuration { get; }

    public void ConfigureServices(IServiceCollection services)
    {
        var storeMode = Configuration["CART_STORE"]
            ?? (_environment.IsDevelopment() || _environment.IsEnvironment("Testing") ? "memory" : "redis");

        if (string.Equals(storeMode, "memory", StringComparison.OrdinalIgnoreCase))
        {
            if (!_environment.IsDevelopment() && !_environment.IsEnvironment("Testing"))
            {
                throw new InvalidOperationException("CART_STORE=memory is permitted only in Development or Testing.");
            }

            services.AddSingleton<ICartStore, InMemoryCartStore>();
        }
        else if (string.Equals(storeMode, "redis", StringComparison.OrdinalIgnoreCase))
        {
            var redisAddress = Configuration["REDIS_ADDR"];
            if (string.IsNullOrWhiteSpace(redisAddress))
            {
                throw new InvalidOperationException("REDIS_ADDR is required when CART_STORE=redis.");
            }

            var redisOptions = ConfigurationOptions.Parse(redisAddress);
            redisOptions.AbortOnConnectFail = false;
            redisOptions.ConnectRetry = 3;
            redisOptions.ConnectTimeout = Configuration.GetValue("REDIS_CONNECT_TIMEOUT_MS", 5000);
            redisOptions.Ssl = Configuration.GetValue("REDIS_TLS", !_environment.IsDevelopment());

            var redisUsername = Configuration["REDIS_USERNAME"];
            var redisPassword = Configuration["REDIS_PASSWORD"];
            if (!string.IsNullOrWhiteSpace(redisUsername))
            {
                redisOptions.User = redisUsername;
            }

            if (!string.IsNullOrWhiteSpace(redisPassword))
            {
                redisOptions.Password = redisPassword;
            }

            services.AddSingleton<IConnectionMultiplexer>(_ => ConnectionMultiplexer.Connect(redisOptions));
            services.AddSingleton<ICartStore, RedisCartStore>();
        }
        else
        {
            throw new InvalidOperationException("CART_STORE must be either 'redis' or 'memory'.");
        }

        services.AddGrpc(options =>
        {
            options.EnableDetailedErrors = _environment.IsDevelopment();
            options.MaxReceiveMessageSize = 64 * 1024;
        });

        if (Configuration.GetValue("ENABLE_OTEL", true))
        {
            services
                .AddOpenTelemetry()
                .ConfigureResource(resource => resource.AddService("cartservice"))
                .WithTracing(tracing => tracing
                    .AddAspNetCoreInstrumentation()
                    .AddOtlpExporter())
                .WithMetrics(metrics => metrics
                    .AddAspNetCoreInstrumentation()
                    .AddRuntimeInstrumentation()
                    .AddOtlpExporter());
        }
    }

    public void Configure(IApplicationBuilder app, IWebHostEnvironment environment)
    {
        if (environment.IsDevelopment())
        {
            app.UseDeveloperExceptionPage();
        }

        app.UseRouting();
        app.UseEndpoints(endpoints =>
        {
            endpoints.MapGrpcService<CartService>();
            endpoints.MapGrpcService<HealthCheckService>();
            endpoints.MapGet("/", async context =>
                await context.Response.WriteAsync("AVOS Cart Service is running. Use a gRPC client to connect."));
        });
    }
}
