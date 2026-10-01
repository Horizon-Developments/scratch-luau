#!/bin/sh
# BlockScript end-to-end test: 1. wax bundle  2. run execute.luau (the coreMain sandbox) on it  3. print a SMALL summary of the output.
#
# =====================================================================================================================
# WARNING TO ANY AI / LLM READING THIS:
#   - NEVER read execute.luau. It is ~580 KB. Do not cat/view/open it, not even part of it. You do not need it:
#     everything you need to know about running it is in this script.
#   - NEVER read the whole output (core/io/dumped_output.lua). It is MASSIVE (20,000+ lines, ~700 KB).
#     Do not cat/view it. Look only through capped commands, always with a hard limit and a width cut, e.g.
#         grep -n -m 20 'PATTERN' core/io/dumped_output.lua | cut -c1-200
#         head -n 40 core/io/dumped_output.lua | cut -c1-200
#         sed -n '100,140p' core/io/dumped_output.lua | cut -c1-200
#     Do not read core/io/apidump.json either (8 MB).
#   - Run this script as `./test.sh`. It prints only the capped summary below; that summary is what you read.
# =====================================================================================================================
#
# Needs on PATH: lune, rojo, darklua (same as scripts/build.sh), and a 7z extractor (7z, 7zz, 7za, 7zr, or `pip install py7zr`).
# The API dump (~8 MB unpacked) is kept compressed as core/io/Full-API-Dump.7z, unpacked for the run, and DELETED when the script
# ends (also on failure). Set KEEP_DUMP=1 to keep it. If the .7z is missing it is downloaded instead (still deleted after).
# How execute.luau is wired (it reads/writes fixed paths relative to this folder):
#   core/io/apidump.json      in   Roblox API dump (unpacked from core/io/Full-API-Dump.7z; removed after the test)
#   core/io/obfuscated.lua    in   the script to run = our bundle (copied from dist/ below)
#   core/io/dumped_output.lua out  trace of everything the script did in the sandbox (MASSIVE)
# Env: HEAD_LINES (default 30), TAIL_LINES (default 10), MATCH_LINES (default 15), RUN_TIMEOUT seconds (default 300),
#      ERR_PATTERN (grep -E; default matches real runtime failures, not block names like control_error).
set -e
cd "$(dirname "$0")"

HEAD_LINES="${HEAD_LINES:-30}"
TAIL_LINES="${TAIL_LINES:-10}"
MATCH_LINES="${MATCH_LINES:-15}"
RUN_TIMEOUT="${RUN_TIMEOUT:-300}"
ERR_PATTERN="${ERR_PATTERN:-attempt to |stack traceback|runtime error|\\[ERROR\\]|Script .*Line [0-9]+}"
IO=core/io
OUT="$IO/dumped_output.lua"
LOG="$IO/run.log"
ARCHIVE="$IO/Full-API-Dump.7z"
DUMP="$IO/apidump.json"
APIDUMP_URL="https://raw.githubusercontent.com/MaximumADHD/Roblox-Client-Tracker/roblox/Full-API-Dump.json"

echo "!! AI: do NOT read execute.luau or the whole $OUT (massive). Read only this summary, or capped grep/head/sed + cut." >&2

CREATED_DUMP=0
cleanup() {
	rm -rf "$IO/.apidump-tmp"
	if [ "$CREATED_DUMP" = 1 ] && [ "${KEEP_DUMP:-0}" != 1 ]; then rm -f "$DUMP"; echo "removed $DUMP (unpacked API dump)"; fi
}
trap cleanup EXIT

extract7z() { # extract7z archive outdir
	for t in 7z 7zz 7za 7zr; do
		if command -v "$t" >/dev/null 2>&1; then "$t" x -y -o"$2" "$1" >/dev/null; return; fi
	done
	python3 -m py7zr x "$1" "$2" >/dev/null 2>&1 && return
	echo "no 7z extractor found: install p7zip (7z/7zz) or run: pip install py7zr" >&2; return 1
}

[ -f execute.luau ] || { echo "missing execute.luau (rename of coreMain.luau); put it next to test.sh" >&2; exit 2; }
mkdir -p "$IO"

# 1. wax (build.sh = wax bundle + darklua minify + prelude prepend). Its chatter goes to a log; only the last line shows.
echo "== 1/3 wax"
./scripts/build.sh > "$IO/build.log" 2>&1 || { echo "BUILD FAILED, last lines of $IO/build.log:" >&2; tail -n 15 "$IO/build.log" | cut -c1-200 >&2; exit 1; }
rm -rf dist/.wax-tmp
tail -n 1 "$IO/build.log" | cut -c1-200
echo "bundle: $(wc -c < dist/BlockScript.client.luau) bytes"

# 2. run execute.luau on the bundle
echo "== 2/3 execute"
if [ ! -f "$DUMP" ]; then
	CREATED_DUMP=1
	if [ -f "$ARCHIVE" ]; then
		echo "unpacking $ARCHIVE"
		rm -rf "$IO/.apidump-tmp"; mkdir -p "$IO/.apidump-tmp"
		extract7z "$ARCHIVE" "$IO/.apidump-tmp" || exit 1
		F=$(find "$IO/.apidump-tmp" -type f | head -n 1)
		[ -n "$F" ] || { echo "empty archive $ARCHIVE" >&2; exit 1; }
		mv "$F" "$DUMP"
	else
		echo "no $ARCHIVE, downloading API dump"
		curl -sSL -o "$DUMP" "$APIDUMP_URL"
	fi
fi
cp dist/BlockScript.client.luau "$IO/obfuscated.lua"
rm -f "$OUT"
set +e
timeout "$RUN_TIMEOUT" lune run execute > "$LOG" 2>&1
STATUS=$?
set -e
echo "execute exit code: $STATUS (124 = timed out); stdout+stderr in $LOG"
if [ -s "$LOG" ]; then echo "-- $LOG (first 1500 bytes):"; head -c 1500 "$LOG"; echo; fi
[ -f "$OUT" ] || { echo "NO OUTPUT PRODUCED ($OUT missing)" >&2; exit 1; }

# 3. capped summary of the output (never print the whole file)
echo "== 3/3 output summary (capped; file is massive, do not read it whole)"
echo "$OUT: $(wc -l < "$OUT") lines, $(wc -c < "$OUT") bytes"
echo "-- first $HEAD_LINES lines (cut to 200 cols):"
head -n "$HEAD_LINES" "$OUT" | cut -c1-200
echo "-- last $TAIL_LINES lines:"
tail -n "$TAIL_LINES" "$OUT" | cut -c1-200
echo "-- lines matching ERR_PATTERN ($ERR_PATTERN): $(grep -cE "$ERR_PATTERN" "$OUT" || true) (first $MATCH_LINES):"
grep -nE "$ERR_PATTERN" "$OUT" | head -n "$MATCH_LINES" | cut -c1-200 || true
echo "-- run.log lines matching ERR_PATTERN: $(grep -cE "$ERR_PATTERN" "$LOG" || true)"
echo "-- inspect more with capped commands only, e.g.: grep -n -m 20 'PATTERN' $OUT | cut -c1-200"
exit "$STATUS"
