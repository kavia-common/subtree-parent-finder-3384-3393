#!/usr/bin/env bash
set -euo pipefail
WS="/home/kavia/workspace/code-generation/subtree-parent-finder-3384-3393/native_c_subtree_parent_finder"
mkdir -p "$WS"
missing=()
command -v gcc >/dev/null 2>&1 || missing+=(build-essential)
command -v make >/dev/null 2>&1 || missing+=(build-essential)
command -v python3 >/dev/null 2>&1 || missing+=(python3)
command -v timeout >/dev/null 2>&1 || missing+=(coreutils)
command -v realpath >/dev/null 2>&1 || missing+=(coreutils)
if [ "${VALGRIND_FORCE:-0}" = "1" ]; then
  command -v valgrind >/dev/null 2>&1 || missing+=(valgrind)
fi
if [ ${#missing[@]} -ne 0 ]; then
  sudo apt-get update -qq >> /tmp/apt_install.log 2>&1 || { echo "ERROR: apt-get update failed; see /tmp/apt_install.log" >&2; exit 11; }
  if ! sudo apt-get install -yq --no-install-recommends "${missing[@]}" >> /tmp/apt_install.log 2>&1; then
    echo "ERROR: apt-get install failed; see /tmp/apt_install.log" >&2
    exit 10
  fi
fi
# Validate critical tools
command -v gcc >/dev/null 2>&1 || { echo "ERROR: gcc missing" >&2; exit 2; }
command -v make >/dev/null 2>&1 || { echo "ERROR: make missing" >&2; exit 3; }
command -v python3 >/dev/null 2>&1 || { echo "ERROR: python3 missing" >&2; exit 4; }
# timeout/realpath are recommended; warn if missing
command -v timeout >/dev/null 2>&1 || echo "WARN: timeout missing; validation will use shell watchdog" >&2
command -v realpath >/dev/null 2>&1 || echo "WARN: realpath missing; some scripts may fail" >&2
exit 0
