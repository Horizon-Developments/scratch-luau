#!/bin/sh
# Bundle the whole project into ONE LocalScript source with wax (+ darklua minify).
# Needs on PATH: lune, rojo, darklua. Verified with lune 0.10.5, rojo 7.7.0, darklua 0.19.0, wax 0.4.2.
# Wax options are key=value (no "--", no bare flags): minify=true, not "minify".
set -e
[ -f wax.luau ] || curl -L https://github.com/latte-soft/wax/releases/latest/download/wax.luau -o wax.luau
mkdir -p dist
lune run wax bundle input=bundle.project.json output=dist/BlockScript.client.luau minify=true darklua-config-path=.darklua.json
# Prepend scripts/prelude.luau (defines loadasset) to the finished bundle. After darklua on purpose: no renaming.
cat scripts/prelude.luau dist/BlockScript.client.luau > dist/.with-prelude && mv dist/.with-prelude dist/BlockScript.client.luau
echo "built dist/BlockScript.client.luau -> paste into a LocalScript (StarterPlayerScripts)"
