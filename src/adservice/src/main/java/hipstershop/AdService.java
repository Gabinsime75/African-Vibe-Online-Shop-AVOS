/*
 * Copyright 2018, Google LLC.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package hipstershop;

import com.google.common.collect.ImmutableListMultimap;
import hipstershop.Demo.Ad;
import hipstershop.Demo.AdRequest;
import hipstershop.Demo.AdResponse;
import io.grpc.Server;
import io.grpc.ServerBuilder;
import io.grpc.Status;
import io.grpc.health.v1.HealthCheckResponse.ServingStatus;
import io.grpc.services.HealthStatusManager;
import io.grpc.stub.StreamObserver;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Locale;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

public final class AdService {

  private static final Logger LOGGER = LogManager.getLogger(AdService.class);

  private static final int MAX_ADS_TO_SERVE = 2;

  private Server server;
  private HealthStatusManager healthMgr;

  private static final AdService SERVICE = new AdService();

  private void start() throws IOException {
    int port = Integer.parseInt(System.getenv().getOrDefault("PORT", "9555"));
    healthMgr = new HealthStatusManager();

    server =
        ServerBuilder.forPort(port)
            .addService(new AdServiceImpl())
            .addService(healthMgr.getHealthService())
            .build()
            .start();
    LOGGER.info("AVOS Ad Service started on gRPC port {}", port);
    Runtime.getRuntime()
        .addShutdownHook(
            new Thread(
                () -> {
                  // Use stderr here since the logger may have been reset by its JVM shutdown hook.
                  System.err.println("Shutting down the AVOS Ad Service gRPC server");
                  AdService.this.stop();
                  System.err.println("AVOS Ad Service stopped");
                }));
    healthMgr.setStatus("", ServingStatus.SERVING);
  }

  private void stop() {
    if (server != null) {
      healthMgr.clearStatus("");
      server.shutdown();
    }
  }

  private static class AdServiceImpl extends hipstershop.AdServiceGrpc.AdServiceImplBase {

    /**
     * Retrieves ads based on context provided in the request {@code AdRequest}.
     *
     * @param req the request containing context.
     * @param responseObserver the stream observer which gets notified with the value of {@code
     *     AdResponse}
     */
    @Override
    public void getAds(AdRequest req, StreamObserver<AdResponse> responseObserver) {
      AdService service = AdService.getInstance();
      try {
        List<Ad> allAds = new ArrayList<>();
        LOGGER.info("Received ad request with context keys {}", req.getContextKeysList());
        if (req.getContextKeysCount() > 0) {
          for (int i = 0; i < req.getContextKeysCount(); i++) {
            Collection<Ad> ads = service.getAdsByCategory(req.getContextKeys(i));
            allAds.addAll(ads);
          }
        } else {
          allAds = service.getRandomAds();
        }
        if (allAds.isEmpty()) {
          // Serve random ads.
          allAds = service.getRandomAds();
        }
        AdResponse reply = AdResponse.newBuilder().addAllAds(allAds).build();
        responseObserver.onNext(reply);
        responseObserver.onCompleted();
      } catch (RuntimeException e) {
        LOGGER.error("Unable to build an ad response", e);
        responseObserver.onError(
            Status.INTERNAL
                .withDescription("Unable to retrieve advertisements")
                .asRuntimeException());
      }
    }
  }

  private static final ImmutableListMultimap<String, Ad> adsMap = createAdsMap();

  private Collection<Ad> getAdsByCategory(String category) {
    return adsMap.get(category.toLowerCase(Locale.ROOT));
  }

  private List<Ad> getRandomAds() {
    List<Ad> ads = new ArrayList<>(new LinkedHashSet<>(adsMap.values()));
    Collections.shuffle(ads);
    return ads.subList(0, Math.min(MAX_ADS_TO_SERVE, ads.size()));
  }

  private static AdService getInstance() {
    return SERVICE;
  }

  /** Await termination on the main thread since the grpc library uses daemon threads. */
  private void blockUntilShutdown() throws InterruptedException {
    if (server != null) {
      server.awaitTermination();
    }
  }

  private static ImmutableListMultimap<String, Ad> createAdsMap() {
    Ad wearableWallet =
        Ad.newBuilder()
            .setRedirectUrl("/product/2ZYFJ3GM2N")
            .setText("Carry culture with confidence—discover the AVOS wearable leather wallet.")
            .build();
    Ad eldecksShoes =
        Ad.newBuilder()
            .setRedirectUrl("/product/66VCHSJNUP")
            .setText("Step into contemporary African style with Eldeck shoes.")
            .build();
    Ad goldTraditionalClothing =
        Ad.newBuilder()
            .setRedirectUrl("/product/0PUK6V6EV0")
            .setText("Make an entrance in the AVOS gold traditional clothing collection.")
            .build();
    Ad whiteTraditionalClothing =
        Ad.newBuilder()
            .setRedirectUrl("/product/9SIQT8TOJO")
            .setText("Celebrate timeless elegance with crisp white traditional attire.")
            .build();
    Ad kingsStaff =
        Ad.newBuilder()
            .setRedirectUrl("/product/1YMWWN1N4O")
            .setText("Complete a distinguished look with the AVOS King's Staff.")
            .build();
    Ad tieNecklace =
        Ad.newBuilder()
            .setRedirectUrl("/product/6E92ZMYYFZ")
            .setText("Add a bold finishing touch with a traditional tie necklace.")
            .build();
    Ad openSlatShoes =
        Ad.newBuilder()
            .setRedirectUrl("/product/L9ECAV7KIM")
            .setText("Move freely in AVOS open-slat slip-on shoes.")
            .build();
    return ImmutableListMultimap.<String, Ad>builder()
        .putAll("clothing", goldTraditionalClothing, whiteTraditionalClothing, tieNecklace)
        .putAll("accessories", wearableWallet, kingsStaff, tieNecklace)
        .putAll("footwear", eldecksShoes, openSlatShoes)
        .build();
  }

  private static void initStats() {
    if (System.getenv("DISABLE_STATS") != null) {
      LOGGER.info("Metrics collection disabled by DISABLE_STATS");
      return;
    }
    LOGGER.info("Metrics will be collected by the AVOS OpenTelemetry platform integration");
  }

  private static void initTracing() {
    if (System.getenv("DISABLE_TRACING") != null) {
      LOGGER.info("Tracing disabled by DISABLE_TRACING");
      return;
    }
    LOGGER.info("Tracing will be exported through the AVOS OpenTelemetry Collector");
  }

  /** Main launches the server from the command line. */
  public static void main(String[] args) throws IOException, InterruptedException {

    new Thread(
            () -> {
              initStats();
              initTracing();
            })
        .start();

    // Start the RPC server. You shouldn't see any output from gRPC before this.
    LOGGER.info("Starting AVOS Ad Service");
    final AdService service = AdService.getInstance();
    service.start();
    service.blockUntilShutdown();
  }
}
