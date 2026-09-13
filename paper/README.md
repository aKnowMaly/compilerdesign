# Paper source

`main.tex` is the authoritative manuscript. Numerical macros, result tables, and
data-driven vector figures are generated from
`build/final-evaluation/final-evaluation.json` and
`build/target-allocation-comparison/comparison.json`. The separate external
MiBench table and macros come from
`build/external-benchmark-validation/results.json`. These inputs preserve the
controlled A/B result, external validation, and distinct declared-width and
DataLayout-derived allocation levels; do not hand-edit generated outputs.

After running the complete test suite, compile the paper from Windows PowerShell:

```powershell
powershell -ExecutionPolicy Bypass -File tools/build_paper.ps1
```

The build uses Tectonic to compile the genuine two-column LaTeX source and writes
`output/pdf/adaptive-width-memory-narrowing-paper.pdf`.
