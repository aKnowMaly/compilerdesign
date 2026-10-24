# Target-Aware Conservative Width Narrowing of LLVM Memory Objects

This repository contains the revised LLVM 18 prototype, its tests, a category-aware
32-kernel evaluation suite, deterministic differential testing, an authoritative
evidence snapshot, a controlled target-allocation A/B experiment, and the
LaTeX research paper.

The pass narrows selected local integer arrays and internal/private integer
globals only when its supported analysis proves the narrower representation and
load reconstruction. Unsupported pointer users, mixed extension families,
unknown stored values, volatile/atomic memory operations, and other uncertain
cases are left unchanged. An isolated experimental pipeline adds a strict
DataLayout complete-object allocation guard after the unchanged safety analysis.
The project does not claim a general target cost model, runtime speedup, or
universal physical-memory reduction. It reports declared IR-width changes
separately from target-specific DataLayout-derived allocation-size changes.

## Environment

- Windows host with WSL Ubuntu
- LLVM/Clang 18 (`clang-18`, `opt-18`, `FileCheck-18`)
- CMake and Ninja
- Python 3; ReportLab is used only for vector result figures
- Tectonic 0.15.0 for LaTeX compilation

## Build the pass

Run in WSL from the repository root:

```bash
cmake -S . -B build -G Ninja -DLLVM_DIR=/usr/lib/llvm-18/lib/cmake/llvm
cmake --build build
```

The plugin is `build/AdaptiveWidthMemoryPass.so`.

## Invoke the pass

```bash
opt-18 -load-pass-plugin=build/AdaptiveWidthMemoryPass.so \
  -passes=adaptive-width-mem -verify-each -S tests/transform_alloca.ll \
  -o build/transform_alloca.out.ll
```

Available pipelines are `adaptive-width-mem`, `adaptive-width-mem-log`,
`adaptive-width-mem-allocas`, `adaptive-width-mem-globals`, and
`adaptive-width-mem-target-aware`, and `adaptive-width-mem-native-width`.
The target-aware pipeline accepts a safe rewrite only
when `DataLayout::getTypeAllocSize` strictly decreases for the complete object.
The native-width experiment uses the same safety and allocation checks but
selects the next width in 8/16/32/64 only when its complete-object allocation
equals that of the minimum safe width.

"Global" means module-level storage. LLVM `private` restricts direct references
to the current module and omits the symbol from the object-file symbol table;
`internal` emits a local symbol and corresponds to file-scope C `static`.

The revision repairs nested sign/zero extension inference and resets rewritten
access alignment to one because narrowing changes array strides. GEP source
types must match the parent object path; opaque-pointer reinterpretations,
dynamic-count allocas, and special alloca modes are rejected. The legacy log
fields `safe`/`blocked` classify pointer users only, not the full safety predicate.

## Complete validation and final evidence

The complete runner builds the plugin, checks fixtures with LLVM verification
and FileCheck, evaluates all benchmarks, compiles and compares baseline and
transformed executables, writes binary-size evidence, regenerates tables, and
creates the authoritative final summary:

```bash
bash tests/run_tests.sh
```

Individual commands are:

```bash
bash tools/benchmark_metrics.sh
bash tools/runtime_differential.sh
python3 tools/final_evaluation.py
bash tools/target_allocation_experiment.sh
python3 tools/width_choice_experiment.py
```

Primary generated evidence:

- `build/benchmark-metrics/benchmark-metrics.tsv`
- `build/runtime-differential/runtime-differential.tsv`
- `build/final-evaluation/final-evaluation.json` (authoritative paper numbers)
- `build/final-evaluation/summary.md`
- `build/final-evaluation/transformed-widths.tsv`
- `build/final-evaluation/data-layout-allocations.tsv` (complete per-object evidence)
- `build/final-evaluation/data-layout-by-kind.tsv`
- `build/final-evaluation/data-layout-by-category.tsv`
- `build/final-evaluation/claim-sources.tsv`
- `build/final-test-status.tsv`
- `build/target-allocation-comparison/comparison.json` (authoritative A/B result)
- `build/target-allocation-comparison/methods.tsv`
- `build/target-allocation-comparison/categories.tsv`
- `build/target-allocation-comparison/rejection-reasons.tsv`

The final evaluator fails if candidate partitions, runtime partitions,
transformed-object counts, or summed width reductions disagree across sources.
For every transformed object, the pass records the complete original and
rewritten type plus `DataLayout::getTypeAllocSize` and ABI alignment. Arrays are
measured using their complete array type. The results are specific to the
module's x86-64 DataLayout and are not physical-memory measurements.

## External MiBench validation

The additional external experiment evaluates the two frozen pipelines on the
established MiBench integration in the
[official LLVM test-suite](https://github.com/llvm/llvm-test-suite). It pins
LLVM test-suite commit `4b2c892865cbbb05ee996c88794a58e17d3adb81`, uses the
suite's unmodified C sources and packaged training commands, and keeps these
results separate from the primary controlled 32-kernel experiment. The
external validation covers 17 MiBench programs comprising 211 unmodified C
compilation units. The generated
`compile_commands.json` has 214 entries in total. Its 213 C entries comprise
the 211 MiBench units plus `fpcmp.c` and `timeit.c`, two LLVM test-suite support
tools; the remaining entry builds `not.cpp`. All three support-tool entries are
excluded from the MiBench unit count.

Additional WSL dependencies are Git and network access for the first source
fetch. The normal LLVM 18, CMake, Ninja, Bash, and Python 3 dependencies listed
above are also required. Run from the repository root:

```bash
bash tools/external_benchmark_experiment.sh
```

The script obtains a sparse, line-ending-stable checkout under
`build/external-suite`, builds all MiBench programs through the LLVM test-suite,
recompiles each unmodified source program to whole-program LLVM IR, runs Method
A and Method B, verifies raw and O2 IR, links executables, executes the official
training command where possible, and validates the resulting schemas and
partitions. Set `EXTERNAL_MIBENCH_SOURCE` only to reuse an existing checkout of
the exact pinned commit. Set `JOBS` or `EXTERNAL_RUN_TIMEOUT` to control build
parallelism or the per-executable timeout.

Auditable outputs are written to:

- `build/external-benchmark-validation/results.json`
- `build/external-benchmark-validation/programs.tsv`
- `build/external-benchmark-validation/candidates.tsv`
- `build/external-benchmark-validation/rejection-reasons.tsv`
- `build/external-benchmark-validation/summary.md`
- `build/external-benchmark-validation/programs/<name>/` for raw/O2 IR,
  executables, pass logs, commands, stdout, and stderr

Candidate counts refer to LLVM memory objects encountered by the pass, not to
benchmark-program counts. Many real programs contain string and other memory
objects that are counted as candidates and then conservatively rejected as
unsupported; the raw candidate TSV retains every such decision. Differential
agreement covers only commands that terminate successfully and compares the
same deterministic stdout channel used by the suite's reference-output tests.
The sole execution skip is `office-ispell`: its packaged command exits with
`Illegal format hash table` for both the rebuilt baseline and the original
test-suite executable, so this is a harness/data compatibility skip rather than
a transformation failure. The external evidence is validation on one x86-64
DataLayout and one finite workload per program; it does not establish
target-independent benefit, runtime speedup, physical-memory reduction, or
universal equivalence.

## Build the paper

The GitHub Actions workflow builds LLVM 18 tests, repeats the controlled and
external evaluations, and uploads the complete evidence. The safety regression
suite executes eight O0/O2 binaries, exhaustively checking the 256 nested-cast
inputs and 65536 inputs per addressing case. The width-choice experiment reports
every kernel, including regressions, in `build/width-choice/benchmarks.tsv`.
Its static machine-instruction and text-section metrics do not measure runtime.

The paper needs fresh A/B, external, and width-choice results before regenerating
its tables. Do not combine historical evidence with a changed pass implementation.

From Windows PowerShell, after the full test suite:

```powershell
powershell -ExecutionPolicy Bypass -File tools/build_paper.ps1
```

This generates evidence-backed PDF figures and LaTeX tables, compiles
`paper/main.tex`, and writes
`output/pdf/adaptive-width-memory-narrowing-paper.pdf`.

## Scope

Supported inference includes constants, truncation, zero/sign extension,
constant masks, OR, compatible selects and bounded PHIs, plus a conservative
KnownBits fallback. Arbitrary LLVM integer widths such as `i5` are supported.

Not implemented: heap narrowing, structure narrowing, vectorizer integration,
machine learning, a general target-aware cost model, generic alias-analysis
infrastructure, scalar register narrowing, or universal formal verification.
