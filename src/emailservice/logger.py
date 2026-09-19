#!/usr/bin/env python3
# Copyright 2026 African Vibe Online Shop (AVOS)
# SPDX-License-Identifier: Apache-2.0

"""Structured logging configuration for the AVOS Email Service."""

import logging
import sys

from pythonjsonlogger import jsonlogger


class AVOSJSONFormatter(jsonlogger.JsonFormatter):
    """Adds consistent AVOS service metadata to every log record."""

    def add_fields(self, log_record, record, message_dict):
        super().add_fields(log_record, record, message_dict)
        if not log_record.get("timestamp"):
            log_record["timestamp"] = self.formatTime(record, "%Y-%m-%dT%H:%M:%S%z")
        log_record["severity"] = record.levelname
        if not log_record.get("service"):
            log_record["service"] = "emailservice"
        log_record.setdefault("service_namespace", "avos")


def get_json_logger(name):
    """Returns one JSON logger without adding duplicate handlers."""
    logger = logging.getLogger(name)
    logger.handlers.clear()
    handler = logging.StreamHandler(sys.stdout)
    handler.setFormatter(
        AVOSJSONFormatter("%(timestamp)s %(severity)s %(service)s %(message)s")
    )
    logger.addHandler(handler)
    logger.setLevel(logging.INFO)
    logger.propagate = False
    return logger


# Backward-compatible alias for any local tooling that still imports it.
getJSONLogger = get_json_logger
