#!/usr/bin/env bash
set -euo pipefail
WS="/home/kavia/workspace/code-generation/subtree-parent-finder-3384-3393/native_c_subtree_parent_finder"
cd "$WS"
if ! command -v python3 >/dev/null 2>&1; then
  echo "ERROR: python3 required" >&2; exit 2
fi
python3 "$WS/tests/run_tests.py"
