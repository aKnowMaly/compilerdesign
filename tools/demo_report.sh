#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PLUGIN="$ROOT_DIR/build/AdaptiveWidthMemoryPass.so"
LLVM_DIR="${LLVM_DIR:-/usr/lib/llvm-18/lib/cmake/llvm}"
REPORT="$ROOT_DIR/build/adaptive-width-report.tsv"

if [[ ! -f "$ROOT_DIR/build/build.ninja" ]]; then
  cmake -S "$ROOT_DIR" -B "$ROOT_DIR/build" -G Ninja -DLLVM_DIR="$LLVM_DIR"
fi

cmake --build "$ROOT_DIR/build" >/dev/null

printf 'input\tcandidate_globals\tcandidate_allocas\tsafe\tblocked\tunknown_width\tno_meaningful_reduction\trewrite_blocked\ttransformed_globals\ttransformed_allocas\tloads_rewritten\tstores_rewritten\tbits_saved_per_element\n' > "$REPORT"

run_input() {
  local input="$1"
  base="$(basename "$input" .ll)"
  log="$ROOT_DIR/build/$base.demo.log"
  out="$ROOT_DIR/build/$base.demo.out.ll"

  opt-18 -load-pass-plugin="$PLUGIN" -passes=adaptive-width-mem \
    -verify-each -S "$input" -o "$out" 2> "$log"
  opt-18 -passes=verify -disable-output "$out"

  summary="$(grep -F '[adaptive-width-mem] summary' "$log" | tail -n 1)"
  get_field() {
    local key="$1"
    printf '%s\n' "$summary" | sed -n "s/.* $key=\\([0-9][0-9]*\\).*/\\1/p"
  }

  printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
    "$base" \
    "$(get_field candidate-globals)" \
    "$(get_field candidate-allocas)" \
    "$(get_field safe)" \
    "$(get_field blocked)" \
    "$(get_field unknown-width)" \
    "$(get_field no-meaningful-reduction)" \
    "$(get_field rewrite-blocked)" \
    "$(get_field transformed-globals)" \
    "$(get_field transformed-allocas)" \
    "$(get_field loads-rewritten)" \
    "$(get_field stores-rewritten)" \
    "$(get_field bits-saved-per-element)" >> "$REPORT"
}

for input in \
  "$ROOT_DIR/tests/candidates.ll" \
  "$ROOT_DIR/tests/transform_alloca.ll" \
  "$ROOT_DIR/tests/inference.ll"; do
  run_input "$input"
done

for input in "$ROOT_DIR"/examples/*.ll; do
  [[ -e "$input" ]] || continue
  run_input "$input"
done

for source in "$ROOT_DIR"/examples/*.c; do
  [[ -e "$source" ]] || continue
  base="$(basename "$source" .c)"
  ir="$ROOT_DIR/build/$base.example.ll"
  clang-18 -O0 -S -emit-llvm -Xclang -disable-O0-optnone "$source" -o "$ir"
  run_input "$ir"
done

cat "$REPORT"
