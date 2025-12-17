#!/usr/bin/env bash
set -euo pipefail
WS="/home/kavia/workspace/code-generation/subtree-parent-finder-3384-3393/native_c_subtree_parent_finder"
cd "$WS"
TIMEOUT_SECS=${TIMEOUT_SECS:-5}
STDOUT_EVID=${STDOUT_EVID:-"$(mktemp)"}
STDERR_EVID=${STDERR_EVID:-"$(mktemp)"}
# Ensure start.sh exists and is executable
if [ ! -x "$WS/start.sh" ]; then
  chmod +x "$WS/start.sh" 2>/dev/null || true
fi
if [ ! -f "$WS/start.sh" ]; then
  echo "ERROR: start.sh missing" >&2; exit 4
fi
# Prefer GNU timeout, else shell watchdog will be used by validation wrapper
if command -v timeout >/dev/null 2>&1; then
  timeout "$TIMEOUT_SECS" bash "$WS/start.sh" >"$STDOUT_EVID" 2>"$STDERR_EVID" || exit 6
else
  bash "$WS/start.sh" >"$STDOUT_EVID" 2>"$STDERR_EVID" &
  echo "$!" >"$WS/.init/start.pid"
fi
# print evidence file paths for caller
echo "$STDOUT_EVID"; echo "$STDERR_EVID"
