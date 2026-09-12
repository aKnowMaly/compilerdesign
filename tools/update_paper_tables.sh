#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RESEARCH_TSV="$ROOT_DIR/build/research-evaluation/adaptive-width-report.tsv"
BENCH_TSV="$ROOT_DIR/build/benchmark-metrics/benchmark-metrics.tsv"
PAPER_TABLE_DIR="$ROOT_DIR/paper/tables"

mkdir -p "$PAPER_TABLE_DIR"

if [[ ! -f "$RESEARCH_TSV" ]]; then
  bash "$ROOT_DIR/tools/research_evaluation.sh" >/dev/null
fi

if [[ ! -f "$BENCH_TSV" ]]; then
  bash "$ROOT_DIR/tools/benchmark_metrics.sh" >/dev/null
fi

escape_latex() {
  sed 's/_/\\_/g'
}

awk -F '\t' '
function esc(s) { gsub(/_/, "\\_", s); return s }
NR == 1 { next }
{
  cand = $2 + $3
  total_cand += cand
  total_safe += $4
  total_blocked += $5
  total_unknown += $6
  total_tg += $9
  total_transformed += $9 + $10
  total_loads += $11
  total_bits += $13
  rows = rows sprintf("%s & %d & %d & %d & %d & %d & %d & %d & %d \\\\\n", esc($1), cand, $4, $5, $6, $9, $10, $11, $13)
}
END {
  print "\\begin{table*}[t]"
  print "\\centering"
  print "\\caption{Fixture-level evaluation summary. The bit-savings column is a static per-element width delta summed across transformed candidates, not a measured runtime memory-footprint reduction.}"
  print "\\label{tab:fixture-results}"
  print "\\begin{tabular}{lrrrrrrrr}"
  print "\\hline"
  print "Input & Cand. & Safe & Blocked & Unknown & Trans. G & Trans. A & Loads & Bits \\\\"
  print "\\hline"
  printf "%s", rows
  print "\\hline"
  printf "Total & %d & %d & %d & %d & %d & %d & %d & %d \\\\\n", total_cand, total_safe, total_blocked, total_unknown, total_tg, total_ta, total_loads, total_bits
  print "\\hline"
  print "\\end{tabular}"
  print "\\end{table*}"
}
' "$RESEARCH_TSV" > "$PAPER_TABLE_DIR/research_evaluation.tex"

awk -F '\t' '
function esc(s) { gsub(/_/, "\\_", s); return s }
NR == 1 { next }
{
  cand = $3 + $4
  total_cand += cand
  total_safe += $5
  total_blocked += $6
  transformed = $10 + $11
  total_transformed += transformed
  total_loads += $12
  total_stores += $13
  total_delta += $17
  total_o2_delta += $20
  total_bits += $14
  rows = rows sprintf("%s & %d & %d & %d & %d & %d & %+d & %+d & %d \\\\\n", esc($1), cand, $5, $6, transformed, $12 + $13, $17, $20, $14)
}
END {
  print "\\begin{table*}[t]"
  print "\\centering"
  print "\\caption{C-kernel benchmark metrics. Raw IR delta is measured immediately after rewriting; optimized IR delta is measured after LLVM default O2 on baseline and transformed IR.}"
  print "\\label{tab:benchmark-results}"
  print "\\begin{tabular}{lrrrrrrrr}"
  print "\\hline"
  print "Benchmark & Cand. & Safe & Blocked & Trans. & R/W & Raw $\\Delta$ & O2 $\\Delta$ & Bits \\\\"
  print "\\hline"
  printf "%s", rows
  print "\\hline"
  printf "Total & %d & %d & %d & %d & %d & %+d & %+d & %d \\\\\n", total_cand, total_safe, total_blocked, total_transformed, total_loads + total_stores, total_delta, total_o2_delta, total_bits
  print "\\hline"
  print "\\end{tabular}"
  print "\\end{table*}"
}
' "$BENCH_TSV" > "$PAPER_TABLE_DIR/benchmark_metrics.tex"

printf 'updated=%s\n' "$PAPER_TABLE_DIR/research_evaluation.tex"
printf 'updated=%s\n' "$PAPER_TABLE_DIR/benchmark_metrics.tex"
