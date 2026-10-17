"""Generate and validate AVOS image supply-chain evidence."""

import hashlib
import json
import os
from pathlib import Path
import re
import subprocess

ROOT = Path(__file__).resolve().parents[3]


def command(*args):
    return subprocess.check_output(args, cwd=ROOT, text=True).strip()


def read_json(path):
    return json.loads(path.read_text(encoding="utf-8"))


def write_json(path, value):
    path.write_text(
        json.dumps(value, indent=2, sort_keys=True) + "\n",
        encoding="utf-8",
    )


def sha256(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def validate(metadata, sbom, image, scan, source_sha):
    image_id = image.get("Id", "")
    if not re.fullmatch(r"sha256:[0-9a-f]{64}", image_id):
        raise ValueError("Invalid local image ID")
    if metadata.get("containerimage.config.digest") != image_id:
        raise ValueError("Build metadata does not match the local image")
    if scan.get("Metadata", {}).get("ImageID") != image_id:
        raise ValueError("Security report does not match the local image")

    labels = image.get("Config", {}).get("Labels") or {}
    if labels.get("org.opencontainers.image.revision") != source_sha:
        raise ValueError("Image revision does not match the source commit")
    if (image.get("Os"), image.get("Architecture")) != ("linux", "amd64"):
        raise ValueError("Unexpected image platform")

    provenance = metadata.get("buildx.build.provenance")
    if not isinstance(provenance, dict) or not provenance.get("buildType"):
        raise ValueError("BuildKit provenance is missing or incomplete")
    if not provenance.get("materials"):
        raise ValueError("BuildKit provenance has no material inventory")

    if sbom.get("bomFormat") != "CycloneDX" or not sbom.get("specVersion"):
        raise ValueError("Invalid CycloneDX document")
    components = sbom.get("components")
    if not isinstance(components, list) or not components:
        raise ValueError("SBOM has no component inventory")
    return provenance


def main():
    service = os.environ["SERVICE_NAME"]
    source_sha = os.environ["SOURCE_SHA"]
    if command("git", "rev-parse", "HEAD") != source_sha:
        raise ValueError("Checked-out commit does not match SOURCE_SHA")

    directory = Path(os.environ["RUNNER_TEMP"]) / "avos-supply-chain" / service
    security = Path(os.environ["RUNNER_TEMP"]) / "avos-security" / service
    metadata = read_json(directory / "build-metadata.json")

    tag = f"avos/{service}:{source_sha}"
    image = json.loads(command("docker", "image", "inspect", tag))[0]
    image_id = image["Id"]
    sbom_path = directory / "sbom.cdx.json"

    subprocess.run(
        [
            "trivy", "image",
            "--config", "",
            "--ignorefile", "",
            "--image-src", "docker",
            "--timeout", "10m",
            "--format", "cyclonedx",
            "--output", str(sbom_path),
            image_id,
        ],
        cwd=ROOT,
        check=True,
    )

    sbom = read_json(sbom_path)
    provenance = validate(
        metadata, sbom, image,
        read_json(security / "image.json"),
        source_sha,
    )
    write_json(directory / "provenance.json", provenance)

    evidence_files = [
        "build-metadata.json",
        "buildx-version.txt",
        "provenance.json",
        "sbom.cdx.json",
    ]
    manifest = {
        "schema_version": 1,
        "service": service,
        "runtime": os.environ["SERVICE_RUNTIME"],
        "source_sha": source_sha,
        "source_repository": (
            os.environ["GITHUB_SERVER_URL"] + "/" +
            os.environ["GITHUB_REPOSITORY"]
        ),
        "workflow_run_url": (
            os.environ["GITHUB_SERVER_URL"] + "/" +
            os.environ["GITHUB_REPOSITORY"] + "/actions/runs/" +
            os.environ["GITHUB_RUN_ID"]
        ),
        "workflow_run_attempt": os.environ["GITHUB_RUN_ATTEMPT"],
        "image": {
            "local_tag": tag,
            "local_config_digest": image_id,
            "build_manifest_digest": metadata.get("containerimage.digest"),
            "platform": "linux/amd64",
            "intended_ecr_repository": os.environ["ECR_REPOSITORY"],
            "published": False,
        },
        "dockerfile": {
            "path": os.environ["DOCKERFILE"],
            "sha256": sha256(ROOT / os.environ["DOCKERFILE"]),
        },
        "component_count": len(sbom["components"]),
        "trivy_version": command("trivy", "--version").splitlines()[0],
        "provenance_signed": False,
        "security_evidence": {
            "artifact": f"avos-security-{service}",
            "sha256": {
                name: sha256(security / name)
                for name in ["filesystem.json", "image.json"]
            },
        },
        "files_sha256": {
            name: sha256(directory / name) for name in evidence_files
        },
    }
    write_json(directory / "evidence-manifest.json", manifest)

    names = sorted(evidence_files + ["evidence-manifest.json"])
    (directory / "SHA256SUMS").write_text(
        "".join(f"{sha256(directory / name)}  {name}\n" for name in names),
        encoding="utf-8",
    )
    print(f"PASS: {service}: {len(sbom['components'])} SBOM components")
    print(f"Validated local image: {image_id}")


if __name__ == "__main__":
    main()
