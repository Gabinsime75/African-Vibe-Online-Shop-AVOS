// Copyright 2026 African Vibe Online Shop (AVOS)
// SPDX-License-Identifier: Apache-2.0
package hipstershop;

import static org.junit.jupiter.api.Assertions.*;

import hipstershop.Demo.AdRequest;
import io.grpc.ManagedChannel;
import io.grpc.ManagedChannelBuilder;
import io.grpc.Metadata;
import io.grpc.Server;
import io.grpc.ServerBuilder;
import io.grpc.stub.MetadataUtils;
import io.opentelemetry.api.baggage.propagation.W3CBaggagePropagator;
import io.opentelemetry.api.trace.SpanKind;
import io.opentelemetry.api.trace.propagation.W3CTraceContextPropagator;
import io.opentelemetry.context.propagation.ContextPropagators;
import io.opentelemetry.context.propagation.TextMapPropagator;
import io.opentelemetry.instrumentation.grpc.v1_6.GrpcTelemetry;
import io.opentelemetry.sdk.OpenTelemetrySdk;
import io.opentelemetry.sdk.testing.exporter.InMemorySpanExporter;
import io.opentelemetry.sdk.trace.SdkTracerProvider;
import io.opentelemetry.sdk.trace.export.SimpleSpanProcessor;
import java.util.concurrent.TimeUnit;
import org.junit.jupiter.api.Test;

class TracePropagationTest {
  @Test
  void grpcContinuesRemoteTraceAndDoesNotReuseItForNextRequest() throws Exception {
    InMemorySpanExporter exporter = InMemorySpanExporter.create();
    try (SdkTracerProvider provider =
        SdkTracerProvider.builder()
            .addSpanProcessor(SimpleSpanProcessor.create(exporter))
            .build()) {
      OpenTelemetrySdk telemetry =
          OpenTelemetrySdk.builder()
              .setTracerProvider(provider)
              .setPropagators(
                  ContextPropagators.create(
                      TextMapPropagator.composite(
                          W3CTraceContextPropagator.getInstance(),
                          W3CBaggagePropagator.getInstance())))
              .build();
      Server server =
          ServerBuilder.forPort(0)
              .intercept(GrpcTelemetry.create(telemetry).newServerInterceptor())
              .addService(new AdService.AdServiceImpl())
              .build()
              .start();
      ManagedChannel channel =
          ManagedChannelBuilder.forAddress("127.0.0.1", server.getPort()).usePlaintext().build();
      try {
        String traceId = "1234567890abcdef1234567890abcdef";
        Metadata headers = new Metadata();
        headers.put(
            Metadata.Key.of("traceparent", Metadata.ASCII_STRING_MARSHALLER),
            "00-" + traceId + "-1234567890abcdef-01");
        AdServiceGrpc.newBlockingStub(channel)
            .withInterceptors(MetadataUtils.newAttachHeadersInterceptor(headers))
            .withDeadlineAfter(3, TimeUnit.SECONDS)
            .getAds(AdRequest.getDefaultInstance());
        AdServiceGrpc.newBlockingStub(channel)
            .withDeadlineAfter(3, TimeUnit.SECONDS)
            .getAds(AdRequest.getDefaultInstance());
        provider.forceFlush().join(3, TimeUnit.SECONDS);
        long deadline = System.nanoTime() + TimeUnit.SECONDS.toNanos(3);
        while (exporter.getFinishedSpanItems().size() < 2 && System.nanoTime() < deadline) {
          Thread.sleep(10);
        }
        var spans = exporter.getFinishedSpanItems();
        assertEquals(2, spans.size());
        assertEquals(SpanKind.SERVER, spans.get(0).getKind());
        assertEquals(traceId, spans.get(0).getTraceId());
        assertEquals("1234567890abcdef", spans.get(0).getParentSpanId());
        assertNotEquals(traceId, spans.get(1).getTraceId());
        assertFalse(spans.get(1).getParentSpanContext().isValid());
      } finally {
        channel.shutdownNow().awaitTermination(3, TimeUnit.SECONDS);
        server.shutdownNow().awaitTermination(3, TimeUnit.SECONDS);
      }
    }
  }
}
