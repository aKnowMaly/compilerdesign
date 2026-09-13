# Method C feasibility experiment

This directory contains a deliberately separate prototype. It does not alter
the behavior of `adaptive-width-mem` (Method A) or
`adaptive-width-mem-target-aware` (Method B), and it does not modify the paper.

The experimental pipeline is:

```text
adaptive-width-mem-method-c
```

For each candidate already proven safe by the existing analysis, the prototype
enumerates every integer width from `w_min` through `W - 1`. It retains only
widths whose complete rewritten object has a smaller
`DataLayout::getTypeAllocSize` than the original object. It first minimizes that
allocation size and, among allocation-equivalent candidates, selects the widest
candidate. On byte-addressed targets this normally chooses a byte-boundary type
such as i8 or i16 rather than an arbitrary i5 or i9.

This is a feasibility heuristic, not a finished LLVM cost model. The experiment
then uses actual LLVM 18 O2 lowering as an offline oracle and compares Method B
and Method C across x86-64, AArch64, and RISC-V64 using:

- transformed widths and complete-object DataLayout allocation;
- raw and O2 IR assignment counts;
- disassembled machine-instruction counts;
- `.text` section size and object-file size;
- host differential execution for the 32 controlled kernels.

The lexicographic experimental objective is:

1. preserve the existing semantic safety result;
2. minimize complete-object DataLayout allocation;
3. among equal-allocation widths, prefer lower O2 machine-instruction count;
4. then prefer smaller `.text` size;
5. retain `w_min` on a complete tie.

The in-pass widest-equal-allocation choice is only a candidate generator. The
reported oracle comparison determines whether that candidate is actually better.

Run from the repository root under WSL:

```bash
bash experiments/method_c/run_smoke.sh
python3 experiments/method_c/run_method_c.py
python3 experiments/method_c/run_posthoc.py
python3 experiments/method_c/run_width_sweep.py
python3 experiments/method_c/run_runtime.py
python3 experiments/method_c/run_width_runtime.py
```

Outputs are written below `build/method-c/`.

The tracked post-hoc evidence is in `experiments/method_c/results/`:

- `posthoc_objects.tsv` and `posthoc_summary.json`: isolated 23-object results;
- `width_sweep.tsv` and `width_sweep_summary.json`: all 91 safe widths per target;
- `width_sweep_runtime.tsv` and `width_sweep_runtime_summary.json`: host
  differential results for all swept widths.

The complete interpretation and command chronology are in
`posthoc_report.md` and `research_log.md`. The object/width command-line controls
are hidden, experimental, and affect only `adaptive-width-mem-method-c`.
