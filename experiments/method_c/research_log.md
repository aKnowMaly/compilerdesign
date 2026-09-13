# Method C autonomous research log

Date: 2026-09-13

## Initial audit

- Located worktree `C:/Users/admin/Documents/ChatGPT/compilerdesign-method-c`.
- Located branch `codex/method-c-experiment` at `7ebf0d8`.
- Verified that the original Method C commit changed no paper file relative to
  base `c8cc1f1`.
- Located the prototype pipeline, scripts, 96 benchmark/target rows, three
  target summaries, runtime result, generated IR, objects, and logs.

## Post-hoc extensions

- Added hidden Method-C-only object and width controls. Their default values
  preserve the original Method C behavior; Methods A/B do not read them.
- Added `run_posthoc.py` for one-object-at-a-time widest-width attribution.
- Added `run_width_sweep.py` for all minimum-allocation safe widths.
- Added `run_width_runtime.py` for host differential validation of every swept
  object/width candidate.

## Measurements

- 23 accepted objects: 18 allocas and 5 globals.
- 91 minimum-allocation safe widths per target; 273 target-width evaluations.
- One consistent improvement, two target-specific regressions, 20 neutral.
- Full Method C correctness: 32/32.
- Width-sweep host correctness: 91/91.
- All 91 width-sweep linked executables: zero file-size delta.
- Disabled-SLP diagnostic made Method B and i8 `unsigned_histogram` identical
  on x86-64, including 69 B `.text`.
- O2 trace located the `select_ranges` divergence at the final InstCombine.

## Final interpretation

- The hypothesis has an existence proof, not a general improvement result.
- TTI is directionally optimistic but poorly predictive for strict final-code
  improvement.
- The only useful alternative width is concentrated in one kernel; i7 and i8
  tie, so native byte legality is not the cause.
- Recommendation: keep as future work pending an independent external sweep.

## Final reproducibility rerun

Executed the documented workflow from the Method C worktree after all analysis
code was in place:

```bash
bash experiments/method_c/run_smoke.sh
python3 experiments/method_c/run_regression.py
python3 experiments/method_c/run_method_c.py
python3 experiments/method_c/run_posthoc.py
python3 experiments/method_c/run_width_sweep.py
python3 experiments/method_c/run_runtime.py
python3 experiments/method_c/run_width_runtime.py
```

- Smoke test: PASS.
- Frozen Method A/B regression tests: PASS.
- Full result matrix: 96 rows (32 kernels x 3 targets).
- Isolated post-hoc matrix: 69 rows (23 objects x 3 targets).
- Exhaustive width matrix: 273 rows (91 widths x 3 targets).
- Full Method C differential tests: 32/32 PASS.
- Exhaustive host width differential tests: 91/91 PASS.
- `git diff --check`: PASS.
- Paper diff against frozen base `c8cc1f1`: empty.
