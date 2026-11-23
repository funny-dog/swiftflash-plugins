#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

mkdir -p releases

python3 - <<'PY'
import hashlib
import json
import os
import zipfile
from datetime import datetime, timezone

root = os.getcwd()
plugins_dir = os.path.join(root, "plugins")
releases_dir = os.path.join(root, "releases")

entries = []
for name in sorted(os.listdir(plugins_dir)):
    plugin_path = os.path.join(plugins_dir, name)
    manifest_path = os.path.join(plugin_path, "manifest.json")
    if not os.path.isdir(plugin_path) or not os.path.isfile(manifest_path):
        continue

    with open(manifest_path, "r", encoding="utf-8") as f:
        manifest = json.load(f)

    plugin_id = manifest["id"]
    version = manifest["version"]

    tmp_zip = os.path.join(releases_dir, f".tmp-{plugin_id}-{version}.zip")
    with zipfile.ZipFile(tmp_zip, "w", compression=zipfile.ZIP_DEFLATED) as zf:
        for dirpath, _, filenames in os.walk(plugin_path):
            for fname in sorted(filenames):
                if fname == ".DS_Store":
                    continue
                abs_file = os.path.join(dirpath, fname)
                rel_in_plugin = os.path.relpath(abs_file, plugin_path)
                zf.write(abs_file, arcname=rel_in_plugin)

    sha256 = hashlib.sha256(open(tmp_zip, "rb").read()).hexdigest()
    zip_name = f"{plugin_id}-{version}-{sha256[:8]}.zip"
    zip_rel = f"releases/{zip_name}"
    zip_abs = os.path.join(releases_dir, zip_name)
    os.replace(tmp_zip, zip_abs)
    loc = manifest.get("contributes", {}).get("localization", {})

    entries.append({
        "id": plugin_id,
        "name": manifest["name"],
        "englishName": manifest.get("englishName", manifest["name"]),
        "description": manifest.get("description", ""),
        "version": version,
        "author": manifest.get("author", "SwiftFlash"),
        "type": manifest["type"],
        "languageCode": loc.get("languageCode"),
        "nativeName": loc.get("nativeName"),
        "minAppVersion": manifest.get("minAppVersion", "1.0"),
        "archiveURL": zip_rel,
        "manifestURL": f"plugins/{plugin_id}/manifest.json",
        "sha256": sha256,
    })

index = {
    "schemaVersion": 1,
    "updatedAt": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
    "plugins": entries,
}

with open(os.path.join(root, "index.json"), "w", encoding="utf-8") as f:
    json.dump(index, f, ensure_ascii=False, indent=2)
    f.write("\n")

print(f"Packaged {len(entries)} plugin(s) into index.json")
PY
