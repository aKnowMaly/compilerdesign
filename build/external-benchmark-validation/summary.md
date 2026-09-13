# External MiBench Validation

Suite: LLVM test-suite MiBench at `4b2c892865cbbb05ee996c88794a58e17d3adb81`.

Programs attempted: 17; compiled: 17; skipped: 0; programs with candidates: 17.
MiBench C compilation units: 211. LLVM test-suite support tools are not included.
Candidates: 5003; safety-safe: 255; safety-blocked: 4748.

| Metric | Method A | Method B |
|---|---:|---:|
| Transformed | 42 | 40 |
| Positive / zero / negative | 40 / 2 / 0 | 40 / 0 / 0 |
| Allocation-benefit precision | 95.24% | 100.00% |
| Accepted allocation | 2700 to 1448 B | 1672 to 420 B |
| Accepted saving | 1252 B (46.37%) | 1252 B (74.88%) |
| Raw / O2 IR delta | +109 / +119 | +100 / +53 |
| Executable-size delta | +216 B | +208 B |
| Differential pass / fail / skip | 16 / 0 / 1 | 16 / 0 / 1 |

Method B eliminated 2 neutral and 0 negative Method A transformations.
On Method A's common opportunity set: baseline 2700 B; A result 1448 B; B result 1448 B.

## Skipped programs

- None.

## Differential-execution skips

- `office-ispell`: exit-code-1: Illegal format hash table (official packaged executable: SKIP; exit-code-1: Illegal format hash table)

## Interpretation guardrails

- This is external validation; the 32-kernel controlled experiment remains separate and unchanged.
- DataLayout allocation size is not physical or peak runtime memory.
- IR counts and executable file size do not establish runtime speed or energy benefit.
- Differential agreement is finite evidence for the packaged commands, not universal equivalence.
