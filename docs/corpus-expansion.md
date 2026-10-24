# Expanded benchmark corpus

The research now has 32 controlled kernels and two external cohorts: the
original 17 MiBench programs and 107 additional C programs from ten preselected
LLVM test-suite families. This is 156 program instances overall, including 124
external programs. External compilation units increase from 211 to 667 and
external candidate memory objects from 5,003 to 9,208.

## Why this strengthens the study

The added programs come from Stanford, Shootout, Misc, CoyoteBench, BitBench,
McCat, Olden, Ptrdist, FreeBench and Prolangs-C at the same pinned source
revision. The manifest was published before inspecting their transformation
outcomes. All configured C-only targets are included: 108 targets were
discovered, 107 are C-only and one C++ target is excluded. None of the C
programs was excluded because it had no narrowing opportunities.

The new cohort has 107 distinct sets of C source contents, 456 compilation
units and 451 unique C-source-content hashes. Repeated source content is not
counted as independent data. Hashes cannot establish that different algorithms
or benchmark families are statistically independent. The dataset is a
purposive collection, not a random population sample.

## Findings

- Method A transforms 26 objects, including two allocation-neutral rewrites.
- Methods B/C each transform 24 objects and preserve the same 579-byte
  aggregate DataLayout allocation saving. Method B transforms at least one
  object in 15 of the 107 programs, which bounds its applicability.
- All three methods have 103 passing differential comparisons, zero failures
  and four skipped baseline workloads. 101 passes have observable output or
  generated-file evidence; two check only successful exit.
- B/C accept identical object sets with equal allocation bytes. Widths change
  in 14 programs: C reduces static machine-instruction counts in four, ties in
  ten and worsens none. Aggregate differences are -22 static instructions and
  -128 text-section bytes relative to B.

| External program | B instructions | C instructions | B text bytes | C text bytes |
|---|---:|---:|---:|---:|
| FreeBench/analyzer | 1903 | 1902 | 7638 | 7622 |
| Prolangs-C/unix-tbl | 7494 | 7477 | 30324 | 30228 |
| Ptrdist/anagram | 723 | 722 | 2866 | 2850 |
| Ptrdist/bc | 8259 | 8256 | 32864 | 32864 |

All four improved cases pass differential testing.
Eleven of the fourteen changed-representation programs have valid runtime
comparisons; the remaining three contribute static evidence only.
The holdout supplies
external evidence beyond the original toy kernels. It does not erase the two
controlled cases where conventional widths are worse, establish a universally
better width rule, or measure execution speed. Static counts include padding
NOPs; text sections are different from linked executable file sizes.

## Correctness and skip accounting

The runner executes each original twice in isolated copies of the packaged
working directory. It compares stdout, stderr and hashes of generated or
modified files. A failed, timed-out or non-repeatable baseline is a recorded
skip; a failed or timed-out transformed program against a valid baseline is a
failure. Skips are not passes. The four unsuccessful baseline commands are
archie, football, gnugo and richards_benchmark; they remain in static coverage
without dynamic-equivalence claims. The runner also records the official
packaged executable result for unsuccessful rebuilt baselines.
All four official packaged commands also return exit code one.

`tests/check_expanded_results.py` independently checks the program, family,
candidate, allocation and runtime partitions against all individual TSV rows.
`benchmarks/external-corpus.json` pins the manifest and source revision.

## Reproduction and permanent evidence

Run the existing full suite and MiBench experiment, then:

```sh
python3 tools/expanded_corpus_experiment.py
python3 tests/check_expanded_results.py build/expanded-corpus
python3 tools/generate_paper_assets.py
```

The producing run for the initial expanded measurements is
[40115975637](https://github.com/aKnowMaly/compilerdesign/actions/runs/40115975637),
commit `336a4a97d9c2ada5889009ef7340687e174480ce`.
The subsequent provenance/runtime audit and independent evidence reconciliation
passed in [40118279957](https://github.com/aKnowMaly/compilerdesign/actions/runs/40118279957),
commit `dbc5bd8b8378d5b026980cdf74e0a3ee11c68f2a`. Exact-source-set overlap
between the new cohort and MiBench is zero, yielding 124 distinct external
C-source sets in the combined corpus.
The compact snapshot under `research/corpus-expansion-2026-10-24/` preserves
all program/candidate/family rows and baseline-status records. Hosted full
IR, disassembly, binaries and runtime files expire after 14 days; the committed
compact evidence and pinned protocol remain available.

The project pass has not been tuned or changed using this holdout. Additional
quality improvements would require other targets/compiler releases, stronger
translation validation and representative performance measurements.
