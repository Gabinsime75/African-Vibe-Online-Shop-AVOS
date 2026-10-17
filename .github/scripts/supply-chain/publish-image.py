"""Publish an already validated AVOS image and verify its ECR identity."""

import hashlib
import json
import os
from pathlib import Path
import re
import runpy
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[3]
helpers = runpy.run_path(str(Path(__file__).with_name("create-evidence.py")))

REGION = "us-east-2"
REGISTRY = "396913735153.dkr.ecr.us-east-2.amazonaws.com"


def aws_json(*args):
    return json.loads(helpers["command"](
        "aws", "ecr", *args,
        "--region", REGION,
        "--output", "json",
        "--no-cli-pager",
    ))


def verified_digest(response, image_id):
    images = response.get("images", [])
    failures = response.get("failures", [])

    if (
        not images and len(failures) == 1
        and failures[0].get("failureCode") == "ImageNotFound"
    ):
        return None

    if len(images) != 1 or failures:
        raise ValueError("ECR did not return exactly one accessible image")

    image = images[0]
    raw = image["imageManifest"]
    manifest = json.loads(raw)

    if (
        manifest.get("schemaVersion") != 2
        or manifest.get("config", {}).get("digest") != image_id
    ):
        raise ValueError(
            "Immutable SHA tag identifies a different image configuration"
        )

    digest = "sha256:" + hashlib.sha256(raw.encode("utf-8")).hexdigest()
    if image["imageId"]["imageDigest"] != digest:
        raise ValueError("ECR manifest digest verification failed")

    return digest


def remote_image(repository, tag):
    return aws_json(
        "batch-get-image",
        "--repository-name", repository,
        "--image-ids", f"imageTag={tag}",
        "--accepted-media-types",
        "application/vnd.docker.distribution.manifest.v2+json",
        "application/vnd.oci.image.manifest.v1+json",
    )


def main():
    if (
        os.environ.get("GITHUB_REPOSITORY")
        != "Gabinsime75/African-Vibe-Online-Shop-AVOS"
        or os.environ.get("GITHUB_REF") != "refs/heads/main"
        or os.environ.get("GITHUB_EVENT_NAME")
        not in {"push", "workflow_dispatch"}
    ):
        raise ValueError("Publication requires an eligible AVOS main run")

    service = os.environ["SERVICE_NAME"]
    source_sha = os.environ["SOURCE_SHA"]
    repository = os.environ["ECR_REPOSITORY"]
    image_id = os.environ["IMAGE_ID"]
    local_image = os.environ["LOCAL_IMAGE"]

    if not re.fullmatch(r"[0-9a-f]{40}", source_sha):
        raise ValueError("Publication requires a full source SHA")
    if helpers["command"]("git", "rev-parse", "HEAD") != source_sha:
        raise ValueError("Source SHA does not match checkout")
    if repository != f"avos/dev/{service}":
        raise ValueError("Unexpected service repository")
    if local_image != f"avos/{service}:{source_sha}":
        raise ValueError("Unexpected local image reference")

    temporary = Path(os.environ["RUNNER_TEMP"])
    evidence = temporary / "avos-supply-chain" / service
    security = temporary / "avos-security" / service
    manifest = helpers["read_json"](evidence / "evidence-manifest.json")

    if (
        manifest["source_sha"] != source_sha
        or manifest["image"]["local_config_digest"] != image_id
    ):
        raise ValueError("Evidence manifest does not match publication inputs")

    for name, digest in manifest["files_sha256"].items():
        if Path(name).name != name:
            raise ValueError("Unexpected evidence filename")
        if helpers["sha256"](evidence / name) != digest:
            raise ValueError("Supply-chain evidence checksum mismatch")

    for name in ["filesystem.json", "image.json"]:
        expected = manifest["security_evidence"]["sha256"][name]
        if helpers["sha256"](security / name) != expected:
            raise ValueError("Security evidence checksum mismatch")

    image = json.loads(
        helpers["command"]("docker", "image", "inspect", local_image)
    )[0]
    if image["Id"] != image_id:
        raise ValueError("Local image identity changed")

    helpers["validate"](
        helpers["read_json"](evidence / "build-metadata.json"),
        helpers["read_json"](evidence / "sbom.cdx.json"),
        image,
        helpers["read_json"](security / "image.json"),
        source_sha,
    )

    repo = aws_json(
        "describe-repositories", "--repository-names", repository
    )["repositories"][0]

    if (
        repo["repositoryUri"] != f"{REGISTRY}/{repository}"
        or repo["imageTagMutability"] != "IMMUTABLE"
        or repo["encryptionConfiguration"]["encryptionType"] != "KMS"
        or not repo["imageScanningConfiguration"]["scanOnPush"]
    ):
        raise ValueError("ECR repository does not meet publication requirements")

    destination = f"{REGISTRY}/{repository}:{source_sha}"
    digest = verified_digest(remote_image(repository, source_sha), image_id)
    status = "already-present"

    if digest is None:
        with tempfile.TemporaryDirectory(
            prefix="avos-ecr-login-", dir=temporary
        ) as config:
            environment = dict(os.environ, DOCKER_CONFIG=config)
            password = helpers["command"](
                "aws", "ecr", "get-login-password", "--region", REGION
            )
            try:
                subprocess.run(
                    [
                        "docker", "login", "--username", "AWS",
                        "--password-stdin", REGISTRY,
                    ],
                    input=password + "\n",
                    text=True,
                    env=environment,
                    check=True,
                )
                subprocess.run(
                    ["docker", "image", "tag", image_id, destination],
                    check=True,
                )
                subprocess.run(
                    ["docker", "image", "push", destination],
                    env=environment,
                    check=True,
                )
            finally:
                subprocess.run(
                    ["docker", "logout", REGISTRY],
                    env=environment,
                    stdout=subprocess.DEVNULL,
                    stderr=subprocess.DEVNULL,
                    check=False,
                )

        digest = verified_digest(remote_image(repository, source_sha), image_id)
        if digest is None:
            raise ValueError("Published image was not found in ECR")
        status = "pushed"

    output = temporary / "avos-publication" / service
    output.mkdir(parents=True, exist_ok=True)
    receipt = {
        "service": service,
        "source_sha": source_sha,
        "image_uri": destination,
        "image_digest": digest,
        "digest_reference": f"{REGISTRY}/{repository}@{digest}",
        "local_config_digest": image_id,
        "status": status,
        "supply_chain_manifest_sha256": helpers["sha256"](
            evidence / "evidence-manifest.json"
        ),
        "workflow_run_id": os.environ["GITHUB_RUN_ID"],
        "workflow_run_attempt": os.environ["GITHUB_RUN_ATTEMPT"],
    }
    helpers["write_json"](output / "publication.json", receipt)

    with open(os.environ["GITHUB_OUTPUT"], "a", encoding="utf-8") as result:
        result.write(f"image-uri={destination}\n")
        result.write(f"image-digest={digest}\n")

    print(f"PASS: {service}: {status}")
    print(receipt["digest_reference"])


if __name__ == "__main__":
    main()
