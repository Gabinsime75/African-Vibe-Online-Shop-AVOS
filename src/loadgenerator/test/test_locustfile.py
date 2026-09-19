# Copyright 2026 African Vibe Online Shop (AVOS)
# SPDX-License-Identifier: Apache-2.0

from datetime import UTC, datetime
import os
import unittest
from unittest.mock import patch

import locustfile


class FakeResponse:
    status_code = 200


class FakeClient:
    def __init__(self):
        self.calls = []
        self.headers = {}

    def get(self, path, **kwargs):
        self.calls.append(("GET", path, None, kwargs))
        return FakeResponse()

    def post(self, path, data=None, **kwargs):
        self.calls.append(("POST", path, data, kwargs))
        return FakeResponse()


class AVOSShopperTest(unittest.TestCase):
    def make_user(self):
        user = object.__new__(locustfile.AVOSShopper)
        user.client = FakeClient()
        return user

    def test_default_catalog_matches_avos_baseline(self):
        self.assertEqual(len(locustfile.DEFAULT_PRODUCTS), 9)
        self.assertIn("0PUK6V6EV0", locustfile.DEFAULT_PRODUCTS)

    def test_configured_products_supports_override(self):
        with patch.dict(os.environ, {"AVOS_PRODUCT_IDS": "avos-1, avos-2"}):
            self.assertEqual(locustfile.configured_products(), ("avos-1", "avos-2"))

    def test_open_product_uses_aggregated_metric_name(self):
        user = self.make_user()
        user.open_product("0PUK6V6EV0")
        method, path, _, options = user.client.calls[-1]
        self.assertEqual((method, path), ("GET", "/product/0PUK6V6EV0"))
        self.assertEqual(options["name"], "GET /product/[id]")

    def test_add_to_cart_limits_quantity(self):
        user = self.make_user()
        user.add_product_to_cart("0PUK6V6EV0", 3)
        _, path, data, _ = user.client.calls[-1]
        self.assertEqual(path, "/cart")
        self.assertEqual(data["quantity"], 3)

    def test_checkout_generates_payment_compatible_data(self):
        user = self.make_user()
        user.checkout()
        _, path, data, options = user.client.calls[-1]
        current_year = datetime.now(UTC).year
        self.assertEqual(path, "/cart/checkout")
        self.assertEqual(options["name"], "POST /cart/checkout")
        self.assertRegex(data["zip_code"], r"^\d{5}$")
        self.assertGreaterEqual(data["credit_card_expiration_year"], current_year + 1)
        self.assertLessEqual(data["credit_card_expiration_year"], current_year + 5)

    def test_wait_time_validation(self):
        with patch.dict(
            os.environ,
            {"MIN_WAIT_SECONDS": "5", "MAX_WAIT_SECONDS": "1"},
        ):
            with self.assertRaises(ValueError):
                locustfile.configured_wait_time()


if __name__ == "__main__":
    unittest.main()
