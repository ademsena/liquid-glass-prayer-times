#!/usr/bin/env bash
# macos-prayer-times — builds the distributable .plasmoid package.
# Usage: ./package.sh  →  dist/macos-prayer-times-<version>.plasmoid
# zip aracına bağımlılığı yok: python3 zipfile kullanır.
set -euo pipefail
cd "$(dirname "$0")"

VERSION=$(sed -n 's/.*"Version": "\([^"]*\)".*/\1/p' metadata.json)
OUT="dist/macos-prayer-times-${VERSION}.plasmoid"

mkdir -p dist
rm -f "${OUT}"

# Plasma paketi: metadata.json + contents/ zip kökünde olmak zorunda.
python3 - "$OUT" <<'PY'
import os, sys, zipfile
out = sys.argv[1]
files = ["metadata.json"]
if os.path.exists("LICENSE"):
    files.append("LICENSE")
skip = {"packages", "dist", "build"}
skip_files = {"package.sh", "install.sh", "README.md", ".gitignore"}
for root, dirs, names in os.walk("contents"):
    for n in names:
        p = os.path.join(root, n)
        if n in skip_files or "places.js" in n:
            continue
        files.append(p)
with zipfile.ZipFile(out, "w", zipfile.ZIP_DEFLATED) as z:
    for p in files:
        z.write(p, p)
print(f"Paket: {out} ({len(files)} dosya)")
PY

python3 - <<PY
import zipfile
z = zipfile.ZipFile("${OUT}")
for n in z.namelist()[:6]:
    print(" ", n)
print("  ... toplam", len(z.namelist()), "girdi")
bad = z.testzip()
print("  bütünlük:", "Tamam" if bad is None else f"HATA: {bad}")
PY
