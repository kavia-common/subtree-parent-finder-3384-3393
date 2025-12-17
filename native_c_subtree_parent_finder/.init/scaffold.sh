#!/usr/bin/env bash
set -euo pipefail
# idempotent scaffolding for workspace
WS="/home/kavia/workspace/code-generation/subtree-parent-finder-3384-3393/native_c_subtree_parent_finder"
# validate required utilities (gcc, make, realpath)
for cmd in gcc make realpath printf; do
  command -v "$cmd" >/dev/null 2>&1 || { echo "ERROR: required tool '$cmd' not found on PATH" >&2; exit 2; }
done
mkdir -p "$WS/src" "$WS/tests" "$WS/bin"
# sample C files
cat > "$WS/src/subtree_parent_finder.c" <<'C_SRC'
#include <stdio.h>
int find_parent_stub(void){ return 42; }
C_SRC
cat > "$WS/src/main.c" <<'C_MAIN'
#include <stdio.h>
int find_parent_stub(void);
int main(void){ printf("%d\n", find_parent_stub()); return 0; }
C_MAIN
# Detect ASAN support
tmpc=$(mktemp --suffix=.c)
cat > "$tmpc" <<'C'
int main(){return 0;}
C
ASAN_OK=0
if gcc -fsanitize=address -g -O0 "$tmpc" -o /dev/null >/dev/null 2>&1; then ASAN_OK=1; fi
rm -f "$tmpc"
USE_ASAN=0
if [ "${VALGRIND_FORCE:-0}" != "1" ] && [ "$ASAN_OK" -eq 1 ]; then
  USE_ASAN=1
fi
if [ "$USE_ASAN" -eq 1 ]; then
  CFLAGS='-O2 -Wall -fsanitize=address -g'
  LDFLAGS='-fsanitize=address'
else
  CFLAGS='-O2 -Wall'
  LDFLAGS=''
fi
# Write Makefile ensuring real TAB characters in recipes using printf
OUT="$WS/Makefile"
printf '%s
' "CC ?= gcc" "CFLAGS ?= ${CFLAGS}" "LDFLAGS ?= ${LDFLAGS}" "SRC=src/main.c src/subtree_parent_finder.c" "OUT_BIN=bin/subtree_parent_finder" > "$OUT"
# targets with real tabs
printf 'all: $(OUT_BIN)\n' >> "$OUT"
printf $'\tmkdir -p bin\n' >> "$OUT"
printf $'\t$(CC) $(CFLAGS) $(SRC) -o $(OUT_BIN) $(LDFLAGS)\n' >> "$OUT"
printf 'clean:\n' >> "$OUT"
# use a real tab for the rm recipe line
printf $'\trm -rf bin\n' >> "$OUT"
printf '.PHONY: all clean\n' >> "$OUT"
# start launcher that discovers workspace via WS env or relative location
cat > "$WS/start.sh" <<'START'
#!/usr/bin/env bash
set -euo pipefail
# Discover workspace: prefer WS env, else derive from script location
if [ -n "${WS:-}" ]; then
  ROOT="$WS"
else
  ROOT=$(realpath "$(dirname "$(realpath "$0")")/..")
fi
cd "$ROOT"
make -s
# Run binary in foreground for deterministic capture
./bin/subtree_parent_finder
START
chmod +x "$WS/start.sh"
# Note: idempotent; overwrites same files on repeated runs
exit 0
