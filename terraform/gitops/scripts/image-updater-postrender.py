"""Remove redundant leader-election RBAC from the pinned AVOS updater chart."""

import re
import sys

targets = {
    ("Role", "argocd-image-updater-leader-election-role"),
    ("RoleBinding", "argocd-image-updater-leader-election-rolebinding"),
}
removed = set()
kept = []

for document in re.split(r"(?m)^---[ \t]*$", sys.stdin.read()):
    kind = re.search(r"(?m)^kind: *(\S+) *$", document)
    metadata = re.search(
        r"(?m)^metadata:\n((?:[ \t]+[^\n]*\n|[ \t]*\n)*)",
        document + "\n",
    )
    fields = {}
    if metadata:
        for key in ("name", "namespace"):
            match = re.search(
                rf"(?m)^  {key}: *([^\n]+)$", metadata.group(1)
            )
            if match:
                fields[key] = match.group(1).strip().strip("\"'")

    identity = (
        kind.group(1) if kind else None,
        fields.get("name"),
    )
    if identity in targets:
        if fields.get("namespace") != "argocd" or identity in removed:
            raise SystemExit("STOP: Unexpected leader-election RBAC identity.")
        removed.add(identity)
    elif document.strip():
        kept.append(document.strip())

if removed != targets:
    raise SystemExit("STOP: Expected exactly two leader-election RBAC objects.")

sys.stdout.write("---\n" + "\n---\n".join(kept) + "\n")
