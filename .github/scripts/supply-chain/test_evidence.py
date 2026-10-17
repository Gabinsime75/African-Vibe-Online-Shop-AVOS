import copy
from pathlib import Path
import runpy
import unittest

validate = runpy.run_path(
    str(Path(__file__).with_name("create-evidence.py"))
)["validate"]


class EvidenceTests(unittest.TestCase):
    def fixture(self):
        image_id = "sha256:" + "a" * 64
        source_sha = "b" * 40
        return [
            {
                "containerimage.config.digest": image_id,
                "buildx.build.provenance": {
                    "buildType": "https://mobyproject.org/buildkit@v1",
                    "materials": [{"uri": "base-image"}],
                },
            },
            {
                "bomFormat": "CycloneDX",
                "specVersion": "1.6",
                "components": [{"name": "example"}],
            },
            {
                "Id": image_id,
                "Os": "linux",
                "Architecture": "amd64",
                "Config": {
                    "Labels": {
                        "org.opencontainers.image.revision": source_sha,
                    },
                },
            },
            {"Metadata": {"ImageID": image_id}},
            source_sha,
        ]

    def test_consistent_evidence_is_accepted(self):
        self.assertTrue(validate(*self.fixture()))

    def test_inconsistent_or_missing_evidence_is_rejected(self):
        changes = [
            (0, "containerimage.config.digest", "wrong"),
            (0, "buildx.build.provenance", {}),
            (1, "components", []),
            (1, "bomFormat", "wrong"),
            (2, "Architecture", "arm64"),
            (3, "Metadata", {}),
            (2, "Config", {"Labels": {}}),
        ]
        for index, field, value in changes:
            with self.subTest(field=field, value=value):
                data = copy.deepcopy(self.fixture())
                data[index][field] = value
                with self.assertRaises(ValueError):
                    validate(*data)


if __name__ == "__main__":
    unittest.main()
