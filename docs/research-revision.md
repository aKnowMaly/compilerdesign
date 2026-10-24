# Research revision, 24 October 2026

The revision preserves the project's object-level scope and distinguishes three
questions: is narrowing safe, does it reduce the target type allocation, and
which allocation-equivalent representation produces better static code?

## Correctness repairs

- Rewritten loads and stores use alignment one. Shrinking an array stride can
  invalidate the old per-access alignment even when the base remains aligned.
- `zext(sext(x))` retains the intermediate width when needed. For signed i8 -1,
  sext to i16 followed by zext to i32 must remain 65535 rather than become 255.
- GEP source types must match the pointee type established by the parent path.
  Opaque-pointer byte/structure reinterpretations are rejected before rewriting.
- Only ordinary static array allocas with count one are rewritten. This keeps
  the complete-object allocation metric consistent with the supported objects.
- The old `safe`/`blocked` log counters describe pointer-use checks. The full
  safety predicate additionally requires value fit and rewriteability.

The regression suite builds eight O0/O2 executables: original IR and Methods
A/B/C. Every executable checks all 256 nested-extension inputs and all 65536
inputs of each of four addressing cases. FileCheck inspects repaired alignments
and rejected addressing patterns. This is targeted regression evidence, not a
mechanized proof of the pass.

## New controlled experiment

Method B uses the minimum inferred width and the allocation guard. Method C
selects the next width in 8/16/32/64 only when its complete-object DataLayout
allocation equals that of B. It uses the same safety predicates. All 32 kernels
are measured; outcomes are not selected after observing their performance.

Both methods accept 23 objects, reducing their common type allocation from
134 to 67 bytes. C changes 17 representations across 14 kernels. Among those
14, machine-instruction counts improve in one, tie in eleven, and regress in
two; text-section sizes have the same outcome partition. Both methods pass
32/32 deterministic runtime comparisons.

| Kernel | B instructions | C instructions | B text bytes | C text bytes |
|---|---:|---:|---:|---:|
| select_ranges | 12 | 7 | 27 | 15 |
| protocol_version_table | 11 | 12 | 24 | 25 |
| unsigned_histogram | 30 | 36 | 69 | 98 |

Across all 32 kernels, C has 369 versus B's 367 machine instructions and 896
versus 878 text bytes. The original inputs have 366 instructions and 897 text
bytes. Static counts include alignment NOPs and all emitted functions. These
object-file section sizes differ from the separately reported linked executable
file sizes and establish no runtime improvement.

The select_ranges native-width disassembly eliminates the conditional-selection
sequence present in the minimum-width output. The unsigned_histogram native
output instead contains vector loads and packing instructions absent from B.
These observed differences show why a single allocation metric is insufficient
to select a universally better representation.

## Revalidated A/B findings

The corrected pass retains the controlled 26-versus-23 transformation result and
67-byte common-set saving. MiBench retains 42-versus-40 transformations and
1252-byte common-set saving. All 16 executed MiBench comparisons agree; the
existing office-ispell hash-table incompatibility remains one explicit skip.
MiBench O2 IR growth is +119 for A and +53 for B. Executable sizes increase by
216 and 208 bytes respectively. None of those measures establishes speedup.

## Positioning and related work

Bit-width analysis and target-aware optimization are established areas. The
contribution here is an inspectable conservative memory-object implementation,
an explicit allocation acceptance policy, and reproducible empirical evidence
about neutral rewrites and allocation-equivalent width choices. This review
does not establish a first-ever technique or superiority over prior methods.

- [Heo et al., 2025](https://doi.org/10.1016/j.sysarc.2025.103546) implement LLVM
  bit-level optimizations and measure AVR execution. We do not reproduce their
  instruction-level pipeline or compare performance against it.
- [Nandivada and Barik, 2013](https://doi.org/10.1145/2509420.2509427) study
  bitwidth-aware register packing; that is distinct from this memory-object
  rewrite but establishes that width-sensitive representation choices are old.
- [MLIR rationale](https://mlir.llvm.org/docs/Rationale/Rationale/) explicitly
  distinguishes logical width from target storage requirements. The distinction
  itself is not claimed as new.
- [LLVM 18 language reference](https://releases.llvm.org/18.1.8/docs/LangRef.html)
  defines private/internal linkage, extension semantics, and the requirement
  that access alignment not be overstated.

## Reproduction and provenance

Run `bash tests/run_tests.sh`, `bash tools/target_allocation_experiment.sh`,
`python3 tools/width_choice_experiment.py`, and
`bash tools/external_benchmark_experiment.sh` with LLVM 18. The paper asset
generator checks the pass source hash against the width-choice evidence.

The initial complete revised run is
[GitHub Actions run 40112839035](https://github.com/aKnowMaly/compilerdesign/actions/runs/40112839035)
at commit `c5fd663ee0b07163e494a287150c3a121e7c258a`, using Ubuntu Clang 18.1.3
and x86-64. The permanent compact snapshot under
`research/revision-2026-10-24/` includes all kernel/object outcome rows, A/B
comparison, external results, safety-test status, source digest, and the
disassemblies for the three non-neutral kernels. The workflow also uploads full
generated IR, logs, and executables; those hosted artifacts expire after 14 days.
