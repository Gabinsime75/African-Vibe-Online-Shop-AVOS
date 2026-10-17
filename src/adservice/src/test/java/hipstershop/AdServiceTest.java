package hipstershop;

import static org.junit.jupiter.api.Assertions.*;

import hipstershop.Demo.AdRequest;
import hipstershop.Demo.AdResponse;
import io.grpc.stub.StreamObserver;
import java.util.ArrayList;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;
import org.junit.jupiter.api.Test;

class AdServiceTest {

  @Test
  void footwearReturnsOnlyMatchingProducts() {
    AdResponse response = request("footwear");

    assertEquals(2, response.getAdsCount());
    assertEquals(Set.of("/product/66VCHSJNUP", "/product/L9ECAV7KIM"), urls(response));
  }

  @Test
  void categoryMatchingIsCaseInsensitive() {
    assertEquals(request("clothing").getAdsList(), request("CLOTHING").getAdsList());
  }

  @Test
  void emptyContextReturnsTwoDistinctCatalogAds() {
    assertValidFallback(request());
  }

  @Test
  void unknownCategoryFallsBackToCatalogAds() {
    assertValidFallback(request("unknown-category"));
  }

  private static AdResponse request(String... categories) {
    RecordingObserver observer = new RecordingObserver();

    new AdService.AdServiceImpl()
        .getAds(AdRequest.newBuilder().addAllContextKeys(List.of(categories)).build(), observer);

    assertNull(observer.error);
    assertTrue(observer.completed);
    assertEquals(1, observer.responses.size());
    return observer.responses.get(0);
  }

  private static Set<String> urls(AdResponse response) {
    return response.getAdsList().stream()
        .map(ad -> ad.getRedirectUrl())
        .collect(Collectors.toSet());
  }

  private static void assertValidFallback(AdResponse response) {
    Set<String> catalog =
        Set.of(
            "/product/2ZYFJ3GM2N",
            "/product/66VCHSJNUP",
            "/product/0PUK6V6EV0",
            "/product/9SIQT8TOJO",
            "/product/1YMWWN1N4O",
            "/product/6E92ZMYYFZ",
            "/product/L9ECAV7KIM");

    assertEquals(2, response.getAdsCount());
    assertEquals(2, urls(response).size());
    assertTrue(catalog.containsAll(urls(response)));
    assertTrue(response.getAdsList().stream().allMatch(ad -> !ad.getText().isBlank()));
  }

  private static class RecordingObserver implements StreamObserver<AdResponse> {
    final List<AdResponse> responses = new ArrayList<>();
    Throwable error;
    boolean completed;

    @Override
    public void onNext(AdResponse response) {
      responses.add(response);
    }

    @Override
    public void onError(Throwable failure) {
      error = failure;
    }

    @Override
    public void onCompleted() {
      completed = true;
    }
  }
}
