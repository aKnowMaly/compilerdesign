#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PLUGIN="$ROOT_DIR/build/AdaptiveWidthMemoryPass.so"
LLVM_DIR="${LLVM_DIR:-/usr/lib/llvm-18/lib/cmake/llvm}"
TEST_STATUS="$ROOT_DIR/build/final-test-status.tsv"

if [[ ! -f "$ROOT_DIR/build/build.ninja" ]]; then
  cmake -S "$ROOT_DIR" -B "$ROOT_DIR/build" -G Ninja -DLLVM_DIR="$LLVM_DIR"
fi

cmake --build "$ROOT_DIR/build"
python3 "$ROOT_DIR/tests/safety_regressions.py"

opt-18 -load-pass-plugin="$PLUGIN" -passes=adaptive-width-mem \
  -verify-each -disable-output "$ROOT_DIR/tests/smoke.ll"

opt-18 -load-pass-plugin="$PLUGIN" -passes=adaptive-width-mem \
  -verify-each -S "$ROOT_DIR/tests/inference.ll" \
  -o "$ROOT_DIR/build/inference.out.ll"
opt-18 -passes=verify -disable-output "$ROOT_DIR/build/inference.out.ll"
FileCheck-18 "$ROOT_DIR/tests/inference.ll" \
  --input-file "$ROOT_DIR/build/inference.out.ll"
opt-18 -load-pass-plugin="$PLUGIN" -passes=adaptive-width-mem \
  -verify-each -disable-output "$ROOT_DIR/tests/inference.ll" \
  2> "$ROOT_DIR/build/inference.log"
FileCheck-18 "$ROOT_DIR/tests/inference.ll" --check-prefix=LOG \
  --input-file "$ROOT_DIR/build/inference.log"

for pipeline in adaptive-width-mem-log adaptive-width-mem-allocas adaptive-width-mem-globals; do
  opt-18 -load-pass-plugin="$PLUGIN" -passes="$pipeline" \
    -verify-each -S "$ROOT_DIR/tests/modes.ll" \
    -o "$ROOT_DIR/build/modes.$pipeline.out.ll"
  opt-18 -passes=verify -disable-output "$ROOT_DIR/build/modes.$pipeline.out.ll"
done
FileCheck-18 "$ROOT_DIR/tests/modes.ll" --check-prefix=LOGONLY \
  --input-file "$ROOT_DIR/build/modes.adaptive-width-mem-log.out.ll"
FileCheck-18 "$ROOT_DIR/tests/modes.ll" --check-prefix=ALLOCAS \
  --input-file "$ROOT_DIR/build/modes.adaptive-width-mem-allocas.out.ll"
FileCheck-18 "$ROOT_DIR/tests/modes.ll" --check-prefix=GLOBALS \
  --input-file "$ROOT_DIR/build/modes.adaptive-width-mem-globals.out.ll"

opt-18 -load-pass-plugin="$PLUGIN" -passes=adaptive-width-mem \
  -verify-each -S "$ROOT_DIR/tests/candidates.ll" \
  -o "$ROOT_DIR/build/candidates.transformed.ll"
opt-18 -passes=verify -disable-output "$ROOT_DIR/build/candidates.transformed.ll"
FileCheck-18 "$ROOT_DIR/tests/candidates.ll" \
  --input-file "$ROOT_DIR/build/candidates.transformed.ll"
opt-18 -load-pass-plugin="$PLUGIN" -passes=adaptive-width-mem \
  -verify-each -disable-output "$ROOT_DIR/tests/candidates.ll" \
  2> "$ROOT_DIR/build/candidates.log"
FileCheck-18 "$ROOT_DIR/tests/candidates.ll" --check-prefix=LOG \
  --input-file "$ROOT_DIR/build/candidates.log"

opt-18 -load-pass-plugin="$PLUGIN" -passes=adaptive-width-mem \
  -verify-each -S "$ROOT_DIR/tests/transform_alloca.ll" \
  -o "$ROOT_DIR/build/transform_alloca.out.ll"
opt-18 -passes=verify -disable-output "$ROOT_DIR/build/transform_alloca.out.ll"
FileCheck-18 "$ROOT_DIR/tests/transform_alloca.ll" \
  --input-file "$ROOT_DIR/build/transform_alloca.out.ll"
opt-18 -load-pass-plugin="$PLUGIN" -passes=adaptive-width-mem \
  -verify-each -disable-output "$ROOT_DIR/tests/transform_alloca.ll" \
  2> "$ROOT_DIR/build/transform_alloca.log"
FileCheck-18 "$ROOT_DIR/tests/transform_alloca.ll" --check-prefix=LOG \
  --input-file "$ROOT_DIR/build/transform_alloca.log"

opt-18 -load-pass-plugin="$PLUGIN" -passes=adaptive-width-mem-target-aware \
  -verify-each -S "$ROOT_DIR/tests/target_allocation_guard.ll" \
  -o "$ROOT_DIR/build/target_allocation_guard.out.ll" \
  2> "$ROOT_DIR/build/target_allocation_guard.log"
opt-18 -passes=verify -disable-output \
  "$ROOT_DIR/build/target_allocation_guard.out.ll"
FileCheck-18 "$ROOT_DIR/tests/target_allocation_guard.ll" --check-prefix=IR \
  --input-file "$ROOT_DIR/build/target_allocation_guard.out.ll"
FileCheck-18 "$ROOT_DIR/tests/target_allocation_guard.ll" --check-prefix=LOG \
  --input-file "$ROOT_DIR/build/target_allocation_guard.log"

bash "$ROOT_DIR/tools/demo_report.sh" > "$ROOT_DIR/build/demo_report.stdout"
FileCheck-18 "$ROOT_DIR/examples/report.check" \
  --input-file "$ROOT_DIR/build/demo_report.stdout"

bash "$ROOT_DIR/tools/research_evaluation.sh" > "$ROOT_DIR/build/research_evaluation.stdout"
FileCheck-18 "$ROOT_DIR/examples/evaluation.check" \
  --input-file "$ROOT_DIR/build/research_evaluation.stdout"
FileCheck-18 "$ROOT_DIR/examples/report.check" \
  --input-file "$ROOT_DIR/build/research-evaluation/adaptive-width-report.tsv"

bash "$ROOT_DIR/tools/benchmark_metrics.sh" > "$ROOT_DIR/build/benchmark_metrics.stdout"
FileCheck-18 "$ROOT_DIR/examples/benchmark_metrics.check" \
  --input-file "$ROOT_DIR/build/benchmark_metrics.stdout"

bash "$ROOT_DIR/tools/update_paper_tables.sh" > "$ROOT_DIR/build/paper_tables.stdout"
FileCheck-18 "$ROOT_DIR/examples/paper_tables.check" \
  --input-file "$ROOT_DIR/build/paper_tables.stdout"

bash "$ROOT_DIR/tools/runtime_differential.sh" > "$ROOT_DIR/build/runtime_differential.stdout"
FileCheck-18 "$ROOT_DIR/examples/runtime_differential.check" \
  --input-file "$ROOT_DIR/build/runtime_differential.stdout"
grep -q $'\tFAIL\t' "$ROOT_DIR/build/runtime-differential/runtime-differential.tsv" && {
  echo "runtime differential test failed" >&2
  exit 1
}

printf 'status\tllvm_version\tcompiler\tenvironment\npassed\t18\tclang-18\t%s\n' "$(uname -srm)" > "$TEST_STATUS"
python3 "$ROOT_DIR/tools/final_evaluation.py" > "$ROOT_DIR/build/final_evaluation.stdout"

echo "adaptive-width-mem tests passed"
