#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PLUGIN="$ROOT_DIR/build/AdaptiveWidthMemoryPass.so"
INPUT="$ROOT_DIR/experiments/method_c/method_c_widths.ll"
OUT_DIR="$ROOT_DIR/build/method-c/smoke"

cmake --build "$ROOT_DIR/build" >/dev/null
mkdir -p "$OUT_DIR"

opt-18 -load-pass-plugin="$PLUGIN" \
  -passes=adaptive-width-mem-method-c -verify-each -S "$INPUT" \
  -o "$OUT_DIR/method-c.ll" 2>"$OUT_DIR/method-c.log"
FileCheck-18 --check-prefix=METHODC "$INPUT" <"$OUT_DIR/method-c.ll"

grep -q 'w-min=5 selected-bits=8' "$OUT_DIR/method-c.log"
grep -q 'w-min=9 selected-bits=16' "$OUT_DIR/method-c.log"

opt-18 -load-pass-plugin="$PLUGIN" \
  -passes=adaptive-width-mem-target-aware -verify-each -S "$INPUT" \
  -o "$OUT_DIR/method-b.ll" 2>"$OUT_DIR/method-b.log"
grep -q 'narrowed-bits=5' "$OUT_DIR/method-b.log"
grep -q 'narrowed-bits=9' "$OUT_DIR/method-b.log"

printf 'method-c smoke test: PASS\n'

