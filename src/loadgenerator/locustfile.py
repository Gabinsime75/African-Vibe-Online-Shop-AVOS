#!/usr/bin/env python3
# Copyright 2018 Google LLC
# Modifications copyright 2026 African Vibe Online Shop (AVOS)
# SPDX-License-Identifier: Apache-2.0

"""Realistic browser traffic for the AVOS storefront."""

from datetime import UTC, datetime
import os
import random

from faker import Faker
from locust import FastHttpUser, between, task


DEFAULT_PRODUCTS = (
    "OLJCESPC7Z",
    "66VCHSJNUP",
    "1YMWWN1N4O",
    "L9ECAV7KIM",
    "2ZYFJ3GM2N",
    "0PUK6V6EV0",
    "LS4PSXUNUM",
    "9SIQT8TOJO",
    "6E92ZMYYFZ",
)
SUPPORTED_CURRENCIES = ("USD", "EUR", "GBP", "CAD", "JPY", "ZAR")


def configured_products():
    raw_value = os.getenv("AVOS_PRODUCT_IDS", "")
    if not raw_value.strip():
        return DEFAULT_PRODUCTS
    products = tuple(value.strip() for value in raw_value.split(",") if value.strip())
    if not products:
        raise ValueError("AVOS_PRODUCT_IDS must contain at least one product ID")
    return products


def configured_wait_time():
    minimum = float(os.getenv("MIN_WAIT_SECONDS", "1"))
    maximum = float(os.getenv("MAX_WAIT_SECONDS", "5"))
    if minimum < 0 or maximum < minimum:
        raise ValueError("wait time must satisfy 0 <= MIN_WAIT_SECONDS <= MAX_WAIT_SECONDS")
    return minimum, maximum


PRODUCTS = configured_products()
MIN_WAIT_SECONDS, MAX_WAIT_SECONDS = configured_wait_time()

seed = os.getenv("LOCUST_RANDOM_SEED")
if seed:
    random.seed(seed)

fake = Faker("en_US")
if seed:
    fake.seed_instance(seed)


class AVOSShopper(FastHttpUser):
    """Models a customer browsing products, managing a cart, and checking out."""

    wait_time = between(MIN_WAIT_SECONDS, MAX_WAIT_SECONDS)

    def on_start(self):
        self.client.headers.update({"User-Agent": "AVOS-LoadGenerator/1.0"})
        self.client.get("/", name="GET /")

    def open_product(self, product_id=None):
        selected_product = product_id or random.choice(PRODUCTS)
        return self.client.get(
            f"/product/{selected_product}",
            name="GET /product/[id]",
        )

    def add_product_to_cart(self, product_id=None, quantity=None):
        selected_product = product_id or random.choice(PRODUCTS)
        selected_quantity = quantity or random.randint(1, 3)
        self.open_product(selected_product)
        return self.client.post(
            "/cart",
            {"product_id": selected_product, "quantity": selected_quantity},
            name="POST /cart",
        )

    @task(2)
    def home(self):
        self.client.get("/", name="GET /")

    @task(2)
    def set_currency(self):
        self.client.post(
            "/setCurrency",
            {"currency_code": random.choice(SUPPORTED_CURRENCIES)},
            name="POST /setCurrency",
        )

    @task(10)
    def browse_product(self):
        self.open_product()

    @task(3)
    def view_cart(self):
        self.client.get("/cart", name="GET /cart")

    @task(3)
    def add_to_cart(self):
        self.add_product_to_cart()

    @task(1)
    def empty_cart(self):
        self.client.post("/cart/empty", name="POST /cart/empty")

    @task(1)
    def checkout(self):
        self.add_product_to_cart(quantity=random.randint(1, 2))
        current_year = datetime.now(UTC).year
        self.client.post(
            "/cart/checkout",
            {
                "email": fake.email(),
                "street_address": fake.street_address(),
                "zip_code": str(random.randint(10000, 99999)),
                "city": fake.city(),
                "state": fake.state_abbr(),
                "country": "United States",
                "credit_card_number": fake.credit_card_number(card_type="visa"),
                "credit_card_expiration_month": random.randint(1, 12),
                "credit_card_expiration_year": random.randint(current_year + 1, current_year + 5),
                "credit_card_cvv": str(random.randint(100, 999)),
            },
            name="POST /cart/checkout",
        )
