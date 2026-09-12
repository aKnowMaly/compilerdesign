# Adaptive Bit-Width Memory Narrowing MVP

This repository contains a small LLVM New Pass Manager plugin for a research
prototype: adaptive bit-width optimization for memory objects. The current pass
is intentionally conservative. It narrows only integer memory objects whose uses
and stored values are simple enough to prove locally.

## Environment

The pass is built and tested in Ubuntu WSL with LLVM 18:

- `clang-18`
- `opt-18`
- `llvm-config-18`
- `FileCheck-18`
- `cmake`
- `ninja`

The default LLVM CMake directory used by the test runner is:

```bash
/usr/lib/llvm-18/lib/cmake/llvm
```

## Build

```bash
cmake -S . -B build -G Ninja -DLLVM_DIR=/usr/lib/llvm-18/lib/cmake/llvm
cmake --build build
```

The plugin is produced at:

```bash
build/AdaptiveWidthMemoryPass.so
```

## Run

```bash
opt-18 \
  -load-pass-plugin=build/AdaptiveWidthMemoryPass.so \
  -passes=adaptive-width-mem \
  -verify-each \
  -S tests/transform_alloca.ll
```

Available pipeline names:

- `adaptive-width-mem`: analyze and transform supported globals and stack arrays.
- `adaptive-width-mem-log`: analyze and report only; no IR mutation.
- `adaptive-width-mem-allocas`: transform only supported stack arrays.
- `adaptive-width-mem-globals`: transform only supported internal/private globals.

## Test

From WSL:

```bash
tests/run_tests.sh
```

The test runner builds the plugin, runs the smoke and transformation fixtures,
verifies the transformed IR, and checks the expected output with `FileCheck-18`.

## Demo Report

To generate a compact tab-separated report from the bundled fixtures:

```bash
tools/demo_report.sh
```

The report is written to:

```bash
build/adaptive-width-report.tsv
```

Example columns:

- candidates found;
- safe vs blocked candidates;
- unknown-width and not-profitable candidates;
- transformed globals and allocas;
- rewritten loads and stores;
- summed bits saved per transformed element.

Current bundled report:

```text
input                   transformed_globals  transformed_allocas  bits_saved_per_element
candidates              2                    3                    67
transform_alloca        0                    5                    50
inference               0                    6                    59
stack_positive          0                    1                    11
globals.example         2                    0                    36
masked_stack.example    0                    1                    11
rejected_escape.example 0                    0                    0
```

The `examples/*.c` files are compiled to LLVM IR by `tools/demo_report.sh` using:

```bash
clang-18 -O0 -S -emit-llvm -Xclang -disable-O0-optnone
```

This keeps the examples close to source-level code while still leaving memory
objects visible to the research pass.

## Research Evaluation Artifact

To regenerate the fuller evaluation bundle:

```bash
bash tools/research_evaluation.sh
```

This writes:

```text
build/research-evaluation/summary.md
build/research-evaluation/adaptive-width-report.tsv
build/research-evaluation/transformed-ir/
build/research-evaluation/logs/
```

The summary includes aggregate candidate counts, transform/rejection rates, the
per-input table, and reproducibility notes. The transformed IR snapshots and
logs are kept with the summary so the artifact is inspectable without rerunning
the pass.

## Benchmark Metrics

To run the initial benchmark-kernel metrics:

```bash
bash tools/benchmark_metrics.sh
```

This compiles every `benchmarks/*.c` file to LLVM IR, runs the pass, verifies the
transformed IR, and writes:

```text
build/benchmark-metrics/summary.md
build/benchmark-metrics/benchmark-metrics.tsv
build/benchmark-metrics/ir/
build/benchmark-metrics/transformed-ir/
build/benchmark-metrics/logs/
```

The benchmark summary adds paper-facing metrics beyond the fixture report:

- static candidate and transformation counts;
- safe/blocked/unknown/not-profitable classification counts;
- rewritten load/store counts;
- static per-element bit-width savings;
- LLVM IR instruction-count delta after transformation;
- LLVM IR instruction-count delta after applying LLVM's default O2 pipeline to
  baseline and transformed IR;
- coarse pass wall-clock time for regression tracking.

The included benchmark suite currently contains 32 deliberately small
C-derived kernels. They exercise positive unsigned narrowing, signed narrowing,
global constants, select-based ranges, packet/pixel-style bit extraction, and
conservative rejection behavior before scaling the same harness to larger
programs.

## Runtime Differential Tests

To compile and compare baseline vs transformed benchmark executables:

```bash
bash tools/runtime_differential.sh
```

This generates deterministic C harnesses for every `benchmarks/*.c` file,
compiles baseline and transformed LLVM IR to native executables, runs both, and
compares their checksum outputs. Results are written to:

```text
build/runtime-differential/summary.md
build/runtime-differential/runtime-differential.tsv
build/runtime-differential/ir/
build/runtime-differential/bin/
build/runtime-differential/logs/
```

The runtime differential tests complement LLVM verifier checks by confirming
that the current transformed benchmark executables produce the same outputs as
their baselines on deterministic generated inputs.

## Paper Draft

The first paper draft lives in:

```text
paper/main.tex
```

The draft includes the method, safety model, implementation, limitations,
related work framing, and evaluation tables generated from the current artifact
metrics. To refresh the checked-in LaTeX tables after rerunning metrics:

```bash
bash tools/update_paper_tables.sh
```

If a TeX distribution is available, build from `paper/` with:

```bash
pdflatex main.tex
bibtex main
pdflatex main.tex
pdflatex main.tex
```

If LaTeX is unavailable, generate a polished PDF artifact with the bundled
Python/reportlab workflow:

```powershell
& 'C:\Users\admin\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe' tools\build_paper_pdf.py
```

The generated PDF is written to:

```text
output/pdf/adaptive-width-memory-narrowing-paper.pdf
```

Diagram assets used to explain the pass live in:

```text
paper/figures/
```

## Current Capabilities

The pass currently handles:

- local stack integer arrays;
- internal/private integer globals;
- direct GEP, load, and store users;
- constants, `trunc`, `zext`, `sext`, `and` with a constant mask, `or`, `select`,
  simple bounded `phi` values, and LLVM `KnownBits`-bounded expressions as
  stored values;
- narrowed loads by inserting either a `zext` or `sext` back to the original
  load type, depending on the proven stored-value family.

Each run prints a deterministic summary line, for example:

```text
[adaptive-width-mem] summary candidate-globals=4 candidate-allocas=6 safe=8 blocked=2 unknown-width=2 not-profitable=1 rewrite-blocked=0 transformed-globals=2 transformed-allocas=3 loads-rewritten=2 stores-rewritten=3 bits-saved-per-element=67
```

Example transformations:

```llvm
%mask_arr = alloca [2 x i16]
```

becomes:

```llvm
%mask_arr.narrow = alloca [2 x i5]
```

and:

```llvm
%loaded = load i16, ptr %slot
```

becomes:

```llvm
%loaded.narrow = load i5, ptr %slot.narrow
%loaded.wide = zext i5 %loaded.narrow to i16
```

## Safety Policy

The transformation tracks whether a candidate's stored values are safely
restored with zero-extension or sign-extension. It transforms only candidates
where every stored value agrees on one extension family under the current local
inference rules:

- integer constants that fit the proposed active-bit width;
- zero-extension chains;
- sign-extension chains;
- truncation when the resulting width is the original stored width;
- constant masks such as `and i16 %x, 31`.
- `or`, `select`, and `phi` only when every contributing value is bounded by
  the same local inference rules and the same extension family.
- LLVM `computeKnownBits` is used as a conservative fallback when local rules do
  not directly recognize an integer expression.

Mixed signed/unsigned candidates, such as a `select` between `sext` and `zext`
values, are treated as unknown and are not narrowed.

## Conservative Rejections

The pass currently refuses:

- external globals;
- scalar allocas;
- floating-point memory;
- pointer escapes such as calls;
- unknown stored values;
- aggregate loads;
- bitcast and address-space-cast transform cases;
- any candidate whose proposed width is not smaller than the original width.

These rejections are deliberate. The project is structured so each broader case
can be added with a focused test.
