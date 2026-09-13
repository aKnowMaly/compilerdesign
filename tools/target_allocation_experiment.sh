#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GUARD_METRICS="$ROOT_DIR/build/target-allocation-guard"
GUARD_RUNTIME="$ROOT_DIR/build/target-allocation-guard-runtime"

PASS_PIPELINE=adaptive-width-mem-target-aware \
BENCHMARK_OUT_DIR="$GUARD_METRICS" \
  bash "$ROOT_DIR/tools/benchmark_metrics.sh"

PASS_PIPELINE=adaptive-width-mem-target-aware \
RUNTIME_OUT_DIR="$GUARD_RUNTIME" \
  bash "$ROOT_DIR/tools/runtime_differential.sh"

python3 "$ROOT_DIR/tools/compare_target_allocation_guard.py"
