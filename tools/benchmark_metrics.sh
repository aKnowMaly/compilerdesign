#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PLUGIN="$ROOT_DIR/build/AdaptiveWidthMemoryPass.so"
LLVM_DIR="${LLVM_DIR:-/usr/lib/llvm-18/lib/cmake/llvm}"
BENCH_DIR="${1:-$ROOT_DIR/benchmarks}"
OUT_DIR="${BENCHMARK_OUT_DIR:-$ROOT_DIR/build/benchmark-metrics}"
PASS_PIPELINE="${PASS_PIPELINE:-adaptive-width-mem}"
REPORT="$OUT_DIR/benchmark-metrics.tsv"
SUMMARY="$OUT_DIR/summary.md"
MANIFEST="$BENCH_DIR/manifest.tsv"

if [[ ! -d "$BENCH_DIR" ]]; then
  echo "benchmark directory not found: $BENCH_DIR" >&2
  exit 1
fi

if [[ ! -f "$ROOT_DIR/build/build.ninja" ]]; then
  cmake -S "$ROOT_DIR" -B "$ROOT_DIR/build" -G Ninja -DLLVM_DIR="$LLVM_DIR"
fi

cmake --build "$ROOT_DIR/build" >/dev/null
mkdir -p "$OUT_DIR/ir" "$OUT_DIR/logs" "$OUT_DIR/transformed-ir" "$OUT_DIR/optimized-ir"

printf 'benchmark\tcategory\tcandidate_globals\tcandidate_allocas\tsafe\tblocked\tunknown_width\tno_meaningful_reduction\trewrite_blocked\ttransformed_globals\ttransformed_allocas\tloads_rewritten\tstores_rewritten\tbits_saved_per_element\tbaseline_ir_instructions\ttransformed_ir_instructions\tir_instruction_delta\toptimized_baseline_ir_instructions\toptimized_transformed_ir_instructions\toptimized_ir_instruction_delta\tpass_wall_ms\n' > "$REPORT"

get_category() {
  local benchmark="$1"
  if [[ -f "$MANIFEST" ]]; then
    awk -F '\t' -v b="$benchmark" 'NR > 1 && $1 == b { print $2; found=1; exit } END { if (!found) print "uncategorized" }' "$MANIFEST"
  else
    printf 'uncategorized\n'
  fi
}

count_ir_instructions() {
  local ir="$1"
  { grep -E '^[[:space:]]*%[-a-zA-Z$._0-9]+[[:space:]]*=' "$ir" || true; } | wc -l | tr -d ' '
}

get_field() {
  local summary="$1"
  local key="$2"
  printf '%s\n' "$summary" | sed -n "s/.* $key=\\([0-9][0-9]*\\).*/\\1/p"
}

run_benchmark() {
  local source="$1"
  local name
  name="$(basename "$source" .c)"
  local category
  category="$(get_category "$name")"
  local input_ir="$OUT_DIR/ir/$name.ll"
  local raw_ir="$OUT_DIR/ir/$name.raw.ll"
  local output_ir="$OUT_DIR/transformed-ir/$name.out.ll"
  local baseline_o2_ir="$OUT_DIR/optimized-ir/$name.baseline.o2.ll"
  local transformed_o2_ir="$OUT_DIR/optimized-ir/$name.transformed.o2.ll"
  local log="$OUT_DIR/logs/$name.log"

  clang-18 -O0 -S -emit-llvm -Xclang -disable-O0-optnone "$source" -o "$raw_ir"
  opt-18 -passes=mem2reg -S "$raw_ir" -o "$input_ir"

  local start_ns end_ns pass_wall_ms
  start_ns="$(date +%s%N)"
  opt-18 -load-pass-plugin="$PLUGIN" -passes="$PASS_PIPELINE" \
    -verify-each -S "$input_ir" -o "$output_ir" 2> "$log"
  end_ns="$(date +%s%N)"
  pass_wall_ms="$(( (end_ns - start_ns) / 1000000 ))"

  opt-18 -passes=verify -disable-output "$output_ir"

  local summary
  summary="$(grep -F '[adaptive-width-mem] summary' "$log" | tail -n 1)"
  opt-18 -passes='default<O2>' -S "$input_ir" -o "$baseline_o2_ir"
  opt-18 -passes='default<O2>' -S "$output_ir" -o "$transformed_o2_ir"
  opt-18 -passes=verify -disable-output "$baseline_o2_ir"
  opt-18 -passes=verify -disable-output "$transformed_o2_ir"

  local baseline_count transformed_count baseline_o2_count transformed_o2_count
  baseline_count="$(count_ir_instructions "$input_ir")"
  transformed_count="$(count_ir_instructions "$output_ir")"
  baseline_o2_count="$(count_ir_instructions "$baseline_o2_ir")"
  transformed_o2_count="$(count_ir_instructions "$transformed_o2_ir")"

  printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
    "$name" \
    "$category" \
    "$(get_field "$summary" candidate-globals)" \
    "$(get_field "$summary" candidate-allocas)" \
    "$(get_field "$summary" safe)" \
    "$(get_field "$summary" blocked)" \
    "$(get_field "$summary" unknown-width)" \
    "$(get_field "$summary" no-meaningful-reduction)" \
    "$(get_field "$summary" rewrite-blocked)" \
    "$(get_field "$summary" transformed-globals)" \
    "$(get_field "$summary" transformed-allocas)" \
    "$(get_field "$summary" loads-rewritten)" \
    "$(get_field "$summary" stores-rewritten)" \
    "$(get_field "$summary" bits-saved-per-element)" \
    "$baseline_count" \
    "$transformed_count" \
    "$(( transformed_count - baseline_count ))" \
    "$baseline_o2_count" \
    "$transformed_o2_count" \
    "$(( transformed_o2_count - baseline_o2_count ))" \
    "$pass_wall_ms" >> "$REPORT"
}

shopt -s nullglob
sources=("$BENCH_DIR"/*.c)
if [[ "${#sources[@]}" -eq 0 ]]; then
  echo "no .c benchmarks found in $BENCH_DIR" >&2
  exit 1
fi

for source in "${sources[@]}"; do
  run_benchmark "$source"
done

awk -F '\t' '
NR == 1 { next }
{
  inputs += 1
  categories[$2] = 1
  category_inputs[$2] += 1
  category_transformed[$2] += $10 + $11
  category_bits[$2] += $14
  candidate_globals += $3
  candidate_allocas += $4
  safe += $5
  blocked += $6
  unknown_width += $7
  no_meaningful_reduction += $8
  rewrite_blocked += $9
  transformed_globals += $10
  transformed_allocas += $11
  loads_rewritten += $12
  stores_rewritten += $13
  bits_saved += $14
  baseline_instr += $15
  transformed_instr += $16
  instr_delta += $17
  optimized_baseline_instr += $18
  optimized_transformed_instr += $19
  optimized_delta += $20
  pass_wall_ms += $21
}
END {
  transformed_total = transformed_globals + transformed_allocas
  candidates_total = candidate_globals + candidate_allocas
  transform_rate = safe ? (100.0 * transformed_total / safe) : 0
  rejection_rate = candidates_total ? (100.0 * blocked / candidates_total) : 0
  avg_pass_ms = inputs ? (pass_wall_ms / inputs) : 0

  print "# Adaptive Width Benchmark Metrics"
  print ""
  print "These measurements are generated from the C kernels in `benchmarks/`."
  print ""
  print "## Aggregate metrics"
  print ""
  print "| metric | value |"
  print "|---|---:|"
  printf "| benchmark inputs | %d |\n", inputs
  printf "| candidate globals | %d |\n", candidate_globals
  printf "| candidate allocas | %d |\n", candidate_allocas
  printf "| safe candidates | %d |\n", safe
  printf "| blocked candidates | %d |\n", blocked
  printf "| unknown-width candidates | %d |\n", unknown_width
  printf "| candidates with no meaningful width reduction | %d |\n", no_meaningful_reduction
  printf "| rewrite-blocked candidates | %d |\n", rewrite_blocked
  printf "| transformed globals | %d |\n", transformed_globals
  printf "| transformed allocas | %d |\n", transformed_allocas
  printf "| loads rewritten | %d |\n", loads_rewritten
  printf "| stores rewritten | %d |\n", stores_rewritten
  printf "| summed bits saved per transformed element | %d |\n", bits_saved
  printf "| baseline IR instruction count | %d |\n", baseline_instr
  printf "| transformed IR instruction count | %d |\n", transformed_instr
  printf "| IR instruction delta | %+d |\n", instr_delta
  printf "| optimized baseline IR instruction count | %d |\n", optimized_baseline_instr
  printf "| optimized transformed IR instruction count | %d |\n", optimized_transformed_instr
  printf "| optimized IR instruction delta | %+d |\n", optimized_delta
  printf "| safe-candidate transform rate | %.1f%% |\n", transform_rate
  printf "| candidate blocked rate | %.1f%% |\n", rejection_rate
  printf "| average pass wall time | %.1f ms |\n", avg_pass_ms
  print ""
  print "## Category summary"
  print ""
  print "| category | inputs | transformed objects | bits saved per element |"
  print "|---|---:|---:|---:|"
  for (category in categories)
    printf "| %s | %d | %d | %d |\n", category, category_inputs[category], category_transformed[category], category_bits[category]
  print ""
  print "## Per-benchmark metrics"
  print ""
  print "| benchmark | category | candidate globals | candidate allocas | safe | blocked | unknown width | no meaningful reduction | rewrite blocked | transformed globals | transformed allocas | loads rewritten | stores rewritten | bits saved per element | baseline IR inst | transformed IR inst | IR inst delta | optimized IR delta | pass wall ms |"
  print "|---|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|"
}
' "$REPORT" > "$SUMMARY"

awk -F '\t' '
NR == 1 { next }
{
  printf "| %s | %s | %d | %d | %d | %d | %d | %d | %d | %d | %d | %d | %d | %d | %d | %d | %+d | %+d | %d |\n", \
    $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $20, $21
}
' "$REPORT" >> "$SUMMARY"

cat >> "$SUMMARY" <<EOF

## Interpretation guardrails

- Wall time is a coarse process-level measurement intended for regression tracking, not a rigorous compiler-performance result.
- Instruction counts are static LLVM IR assignment counts. The optimized delta is measured after LLVM's default O2 pipeline on baseline and transformed IR, but it is not machine-code size.
- The bit-savings metric is a static per-element width delta across transformed memory objects, not a measured runtime memory-footprint reduction.

EOF

printf 'summary=%s\n' "$SUMMARY"
printf 'report=%s\n' "$REPORT"
printf 'ir=%s\n' "$OUT_DIR/ir"
printf 'transformed_ir=%s\n' "$OUT_DIR/transformed-ir"
printf 'optimized_ir=%s\n' "$OUT_DIR/optimized-ir"
printf 'logs=%s\n' "$OUT_DIR/logs"
