#!/usr/bin/env bash
set -euo pipefail
WS="/home/kavia/workspace/code-generation/subtree-parent-finder-3384-3393/native_c_subtree_parent_finder"
cd "$WS"
# Ensure minimal tools
for tool in gcc make python3 realpath; do
  command -v "$tool" >/dev/null 2>&1 || { echo "ERROR: required '$tool' not found" >&2; exit 2; }
done
mkdir -p .init
# Build
if ! make -s; then echo 'ERROR: build failed' >&2; exit 3; fi
# prepare evidence files
STDOUT_EVID=$(mktemp)
STDERR_EVID=$(mktemp)
TIMEOUT_SECS=5
# run with preferred timeout if available
if command -v timeout >/dev/null 2>&1; then
  if ! timeout "$TIMEOUT_SECS" bash ./start.sh >"$STDOUT_EVID" 2>"$STDERR_EVID"; then
    head -c 10000 "$STDOUT_EVID" >&2 || true
    head -c 10000 "$STDERR_EVID" >&2 || true
    echo "RAN_BINARY_STDOUT:<truncated>"; echo "RAN_BINARY_STDERR:<truncated>"
    rm -f "$STDOUT_EVID" "$STDERR_EVID"
    echo 'ERROR: binary run failed or timed out' >&2
    exit 6
  fi
else
  bash ./start.sh >"$STDOUT_EVID" 2>"$STDERR_EVID" &
  pid=$!
  (sleep "$TIMEOUT_SECS" && kill -TERM "$pid" >/dev/null 2>&1 && sleep 1 && kill -KILL "$pid" >/dev/null 2>&1) &
  wd=$!
  wait "$pid" || true
  kill -9 "$wd" >/dev/null 2>&1 || true
fi
# Emit limited evidence
echo -n "RAN_BINARY_STDOUT:"; head -c 10000 "$STDOUT_EVID" | tr '\n' ' ' || true; echo
echo -n "RAN_BINARY_STDERR:"; head -c 10000 "$STDERR_EVID" | tr '\n' ' ' || true; echo
rm -f "$STDOUT_EVID" "$STDERR_EVID"
# Run tests
WS="$WS" python3 "$WS/tests/run_tests.py" || { echo 'TESTS_FAILED' >&2; make clean >/dev/null || true; exit 5; }
# Clean up
make clean >/dev/null || true
echo 'VALIDATION_OK'
