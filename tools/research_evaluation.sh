#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="$ROOT_DIR/build/research-evaluation"
REPORT_TSV="$ROOT_DIR/build/adaptive-width-report.tsv"
SUMMARY_MD="$OUT_DIR/summary.md"

mkdir -p "$OUT_DIR/transformed-ir" "$OUT_DIR/logs"

"$ROOT_DIR/tools/demo_report.sh" > "$OUT_DIR/raw-report.tsv"
cp "$REPORT_TSV" "$OUT_DIR/adaptive-width-report.tsv"

for ir in "$ROOT_DIR"/build/*.demo.out.ll; do
  [[ -e "$ir" ]] || continue
  cp "$ir" "$OUT_DIR/transformed-ir/$(basename "$ir")"
done

for log in "$ROOT_DIR"/build/*.demo.log; do
  [[ -e "$log" ]] || continue
  cp "$log" "$OUT_DIR/logs/$(basename "$log")"
done

awk -F '\t' '
NR == 1 { next }
{
  inputs += 1
  candidate_globals += $2
  candidate_allocas += $3
  safe += $4
  blocked += $5
  unknown_width += $6
  not_profitable += $7
  rewrite_blocked += $8
  transformed_globals += $9
  transformed_allocas += $10
  loads_rewritten += $11
  stores_rewritten += $12
  bits_saved += $13
}
END {
  transformed_total = transformed_globals + transformed_allocas
  candidates_total = candidate_globals + candidate_allocas
  transform_rate = safe ? (100.0 * transformed_total / safe) : 0
  rejection_rate = candidates_total ? (100.0 * blocked / candidates_total) : 0

  print "# Adaptive Width Memory Narrowing - Research Evaluation"
  print ""
  print "This artifact summarizes the bundled LLVM IR and C-derived fixtures used to exercise the AdaptiveWidthMemoryPass prototype."
  print ""
  print "## Aggregate metrics"
  print ""
  print "| metric | value |"
  print "|---|---:|"
  printf "| evaluated inputs | %d |\n", inputs
  printf "| candidate globals | %d |\n", candidate_globals
  printf "| candidate allocas | %d |\n", candidate_allocas
  printf "| safe candidates | %d |\n", safe
  printf "| blocked candidates | %d |\n", blocked
  printf "| unknown-width candidates | %d |\n", unknown_width
  printf "| not-profitable candidates | %d |\n", not_profitable
  printf "| rewrite-blocked candidates | %d |\n", rewrite_blocked
  printf "| transformed globals | %d |\n", transformed_globals
  printf "| transformed allocas | %d |\n", transformed_allocas
  printf "| loads rewritten | %d |\n", loads_rewritten
  printf "| stores rewritten | %d |\n", stores_rewritten
  printf "| summed bits saved per transformed element | %d |\n", bits_saved
  printf "| safe-candidate transform rate | %.1f%% |\n", transform_rate
  printf "| candidate blocked rate | %.1f%% |\n", rejection_rate
  print ""
  print "## Per-input report"
  print ""
  print "| input | candidate globals | candidate allocas | safe | blocked | unknown width | not profitable | rewrite blocked | transformed globals | transformed allocas | loads rewritten | stores rewritten | bits saved per element |"
  print "|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|"
}
' "$REPORT_TSV" > "$SUMMARY_MD"

awk -F '\t' '
NR == 1 { next }
{
  printf "| %s | %d | %d | %d | %d | %d | %d | %d | %d | %d | %d | %d | %d |\n", \
    $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13
}
' "$REPORT_TSV" >> "$SUMMARY_MD"

cat >> "$SUMMARY_MD" <<EOF

## Reproducibility notes

- The plugin is built from the current checkout with CMake/Ninja.
- Each transformed IR snapshot is verified with LLVM's verifier by the demo report pipeline before it is copied into this directory.
- Logs are preserved beside transformed IR so reviewers can inspect the exact candidate classification, proposed width, extension policy, and rejection reason for each fixture.
- The reported "bits saved per transformed element" is a static per-element width delta summed across transformed candidates. It is not a runtime memory-footprint claim.

EOF

printf 'summary=%s\n' "$SUMMARY_MD"
printf 'report=%s\n' "$OUT_DIR/adaptive-width-report.tsv"
printf 'transformed_ir=%s\n' "$OUT_DIR/transformed-ir"
printf 'logs=%s\n' "$OUT_DIR/logs"
