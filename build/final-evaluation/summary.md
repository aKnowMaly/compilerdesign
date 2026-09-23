# Definitive Final Evaluation Summary

This file is generated from current benchmark, runtime, per-object DataLayout, and test evidence. `final-evaluation.json` is the paper's authoritative numerical source.

| Metric | Value |
|---|---:|
| Benchmarks | 32 |
| Candidate globals | 8 |
| Candidate allocas | 31 |
| Total candidates | 39 |
| Safe candidates | 35 |
| Rejected/blocked candidates | 4 |
| Transformed globals | 5 |
| Transformed allocas | 21 |
| Total transformed objects | 26 |
| Summed declared per-element width reduction (bits) | 271 |
| Mean declared-width reduction per object (bits) | 10.42 |
| Median declared-width reduction per object (bits) | 10.5 |
| Baseline DataLayout allocation (bytes) | 150 |
| Transformed DataLayout allocation (bytes) | 83 |
| DataLayout allocation reduction (bytes) | 67 |
| DataLayout allocation reduction (%) | 44.67 |
| Mean object allocation reduction (bytes) | 2.58 |
| Median object allocation reduction (bytes) | 3.0 |
| Mean object allocation reduction (%) | 44.23 |
| Median object allocation reduction (%) | 50.0 |
| Objects with positive allocation reduction | 23 |
| Objects with zero allocation reduction | 3 |
| Objects with negative allocation reduction | 0 |
| Raw IR instruction delta | 141 |
| O2 IR instruction delta | 4 |
| Runtime differential comparisons | 32 |
| Runtime comparisons passed | 32 |
| Runtime comparisons failed | 0 |
| Summed baseline executable bytes | 514144 |
| Summed transformed executable bytes | 514144 |
| Summed executable-size delta (bytes) | 0 |
| Summed executable-size delta (%) | 0.0 |
| End-to-end compile time measured | False |
| Full test suite | passed |

## Interpretation

Level 1 is declared LLVM per-element width reduction. Level 2 is target-specific DataLayout-derived allocation-size reduction computed from each complete original and transformed object type. Neither is a whole-program physical-memory or runtime-speed measurement.

## Consistency checks

- Transformed-object count agrees between the aggregate TSV and 26 individual transformation records.
- Declared width reduction agrees between aggregate and individual evidence (271 bits).
- DataLayout aggregation covers all objects: 150 baseline bytes and 83 transformed bytes.
- Candidate partition: 35 safe + 4 blocked = 39 candidates.
- Runtime partition: 32 passed + 0 failed = 32 comparisons.
