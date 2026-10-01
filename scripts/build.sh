#!/usr/bin/env bash
# Needs python3 and darklua on PATH. Output: dist/BlockScript.client.luau
set -euo pipefail
cd "$(dirname "$0")/.."
python3 scripts/bundle.py build/bundle.luau
darklua process build/bundle.luau build/min.luau -c .darklua.json
mkdir -p dist
cat scripts/prelude.luau build/min.luau > dist/BlockScript.client.luau
echo "built dist/BlockScript.client.luau"
