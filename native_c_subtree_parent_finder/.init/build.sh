#!/usr/bin/env bash
set -euo pipefail
WS="/home/kavia/workspace/code-generation/subtree-parent-finder-3384-3393/native_c_subtree_parent_finder"
cd "$WS"
# simple build using Makefile (Makefile expected in workspace)
if ! command -v make >/dev/null 2>&1; then
  echo "ERROR: make is required" >&2; exit 2
fi
make -s || { echo 'ERROR: build failed' >&2; exit 3; }
