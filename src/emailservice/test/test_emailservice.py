# Copyright 2026 African Vibe Online Shop (AVOS)
# SPDX-License-Identifier: Apache-2.0

import unittest

import grpc

import demo_pb2
from email_server import (
    EmailService,
    format_money,
    render_confirmation,
    validate_confirmation_request,
    validate_email_address,
)


def valid_request():
    return demo_pb2.SendOrderConfirmationRequest(
        email="customer@example.com",
        order=demo_pb2.OrderResult(
            order_id="AVOS-ORDER-1001",
            shipping_tracking_id="AV-ABCDEFGH2345",
            shipping_cost=demo_pb2.Money(currency_code="USD", units=9, nanos=990_000_000),
            shipping_address=demo_pb2.Address(
                street_address="100 Market Street",
                city="Oklahoma City",
                state="OK",
                country="United States",
                zip_code=73179,
            ),
            items=[
                demo_pb2.OrderItem(
                    item=demo_pb2.CartItem(product_id="avos-textile-01", quantity=2),
                    cost=demo_pb2.Money(currency_code="USD", units=49, nanos=990_000_000),
                )
            ],
        ),
    )


class AbortError(Exception):
    def __init__(self, code, details):
        super().__init__(details)
        self.code = code


class FakeContext:
    def abort(self, code, details):
        raise AbortError(code, details)


class EmailServiceTest(unittest.TestCase):
    def test_validates_email_address(self):
        self.assertEqual(validate_email_address("customer@example.com"), "customer@example.com")
        with self.assertRaises(ValueError):
            validate_email_address("not-an-email")

    def test_requires_order(self):
        request = demo_pb2.SendOrderConfirmationRequest(email="customer@example.com")
        with self.assertRaisesRegex(ValueError, "order is required"):
            validate_confirmation_request(request)

    def test_formats_money(self):
        money = demo_pb2.Money(currency_code="USD", units=49, nanos=990_000_000)
        self.assertEqual(format_money(money), "49.99 USD")

    def test_renders_avos_confirmation_with_real_address_fields(self):
        content = render_confirmation(valid_request().order)
        self.assertIn("African Vibe Online Shop", content)
        self.assertIn("100 Market Street", content)
        self.assertIn("49.99 USD", content)
        self.assertNotIn("street_address_1", content)

    def test_service_accepts_valid_confirmation(self):
        response = EmailService().SendOrderConfirmation(valid_request(), FakeContext())
        self.assertIsInstance(response, demo_pb2.Empty)

    def test_service_returns_invalid_argument(self):
        request = valid_request()
        request.email = "invalid"
        with self.assertRaises(AbortError) as raised:
            EmailService().SendOrderConfirmation(request, FakeContext())
        self.assertEqual(raised.exception.code, grpc.StatusCode.INVALID_ARGUMENT)


if __name__ == "__main__":
    unittest.main()
