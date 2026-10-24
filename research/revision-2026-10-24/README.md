# Revised research evidence

`evidence.zip` is the permanent 23-file compact snapshot for the corrected pass.
It contains every controlled kernel/object outcome, A/B comparison, all MiBench
candidate/program rows, regression status, source digest, and the original,
minimum-width and conventional-width disassemblies of the three changed-code
kernels. `manifest.json` records the producing commit/run and SHA-256 digests of
the member evidence files. The separately browsable width-choice JSON and TSVs
are copies of members in that archive.

The full research explanation is in
[`docs/research-revision.md`](../../docs/research-revision.md).
The rebuilt paper is
[`output/pdf/adaptive-width-memory-narrowing-paper.pdf`](../../output/pdf/adaptive-width-memory-narrowing-paper.pdf).

Initial experiment run:
[40112839035](https://github.com/aKnowMaly/compilerdesign/actions/runs/40112839035).
The subsequent complete validation, including paper generation and compilation,
also passed in
[40113876834](https://github.com/aKnowMaly/compilerdesign/actions/runs/40113876834).
The pass source was unchanged between these runs.

Hosted full IR/log/executable artifacts expire after 14 days. This committed
compact archive remains available and the scripts reproduce the full artifacts.
These measurements concern one LLVM 18.1.3 x86-64 setup; no timing or energy
improvement is claimed.
