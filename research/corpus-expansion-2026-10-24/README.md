# Expanded corpus evidence

This snapshot preserves the audited 107-program external holdout results from
[run 40118279957](https://github.com/aKnowMaly/compilerdesign/actions/runs/40118279957).

- `results.json`: aggregate metrics, source-set overlap audit, toolchain and hashes.
- `families.tsv`: every family, including zero-transformation families.
- `programs.tsv`: every discovered target, runtime status and static code metrics.
- `evidence.zip`: all candidate rows, baseline/repeated/official runtime records,
  transformed runtime statuses, stderr records, build log and compact reports.
- `manifest.json`: SHA-256 checksums for every evidence-archive member.

The initial expansion protocol was committed before measuring these outcomes.
The pass source is unchanged from the earlier controlled experiment.
The combined corpus has 124 distinct external C-source sets, 667 C compilation
units and 9,208 candidate memory objects; the separate controlled cohort has
32 kernels. Program counts, compilation units and candidates are different
units of evidence, and benchmark-family correlation limits generalization.

See [the interpretation](../../docs/corpus-expansion.md) and
[the revised paper](../../output/pdf/adaptive-width-memory-narrowing-paper.pdf).
Full generated IR, disassemblies and executables are available from the run's
hosted artifact for 14 days, and can be reproduced with the pinned source manifest.
