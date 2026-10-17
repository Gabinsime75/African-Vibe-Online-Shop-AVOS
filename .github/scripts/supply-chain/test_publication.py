import hashlib
import json
from pathlib import Path
import runpy
import unittest

verified_digest = runpy.run_path(
    str(Path(__file__).with_name("publish-image.py"))
)["verified_digest"]


class PublicationTests(unittest.TestCase):
    image_id = "sha256:" + "a" * 64

    def response(self):
        raw = json.dumps({
            "schemaVersion": 2,
            "config": {"digest": self.image_id},
        })
        digest = "sha256:" + hashlib.sha256(raw.encode()).hexdigest()
        return {
            "images": [{
                "imageManifest": raw,
                "imageId": {"imageDigest": digest},
            }],
            "failures": [],
        }

    def test_matching_image_is_accepted(self):
        response = self.response()
        self.assertEqual(
            verified_digest(response, self.image_id),
            response["images"][0]["imageId"]["imageDigest"],
        )

    def test_different_image_is_rejected(self):
        with self.assertRaises(ValueError):
            verified_digest(self.response(), "sha256:" + "b" * 64)

    def test_incorrect_manifest_digest_is_rejected(self):
        response = self.response()
        response["images"][0]["imageId"]["imageDigest"] = "sha256:" + "c" * 64
        with self.assertRaises(ValueError):
            verified_digest(response, self.image_id)

    def test_missing_image_can_be_published(self):
        response = {
            "images": [],
            "failures": [{"failureCode": "ImageNotFound"}],
        }
        self.assertIsNone(verified_digest(response, self.image_id))

    def test_other_registry_failures_are_rejected(self):
        for code in ["KmsError", "ImageInaccessible"]:
            with self.subTest(code=code):
                with self.assertRaises(ValueError):
                    verified_digest({
                        "images": [],
                        "failures": [{"failureCode": code}],
                    }, self.image_id)


if __name__ == "__main__":
    unittest.main()
