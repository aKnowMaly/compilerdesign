# Method C post-hoc research report

## Decision

**Recommendation C: keep Method C as future work.**

The experiment supports one narrow existence claim: a width larger than the
minimum semantically safe width can produce better optimized and lowered code
without changing the DataLayout allocation. It does not support a general
target-width selection contribution. Only one of 23 accepted objects benefits,
two regress on at least one target, and the remaining 20 are neutral.

## Scope and provenance

- Experimental branch: `codex/method-c-experiment`.
- Starting experiment commit: `7ebf0d8`.
- Frozen base commit: `c8cc1f1`.
- LLVM toolchain: 18.1.8.
- Controlled suite: 32 unchanged kernels.
- Targets: x86-64, AArch64, and RISC-V64.
- Frozen `adaptive-width-mem` and `adaptive-width-mem-target-aware` behavior was
  not changed. The paper was not changed.

The post-hoc extension adds hidden options used only with
`adaptive-width-mem-method-c`. They select one safely narrowable object and one
safe minimum-allocation width for isolated experiments. No option affects
Methods A or B.

## Experiments performed

1. Reproduced the original Method B versus widest-equal-allocation Method C
   comparison on all 32 kernels and three targets.
2. Isolated each of the 23 Method-B-accepted objects, changing only that object
   to Method C while retaining `w_min` for every other object.
3. Swept all 91 minimum-allocation safe widths per target: 273 target/width
   compilations covering all 23 objects.
4. Ran 91 host differential executions, one for every object/width candidate.
5. Compared local TTI totals and post-O2 IR features with final machine
   instruction and `.text` changes.
6. Disabled SLP vectorization for the `unsigned_histogram` diagnostic to test
   whether vectorization caused its regression.
7. Traced the O2 pass sequence for `select_ranges` to locate the simplification.

Classification uses machine-instruction count as the primary outcome and
`.text` bytes as the tie-breaker. Object-file bytes are reported separately and
are not treated as an execution-performance measure.

## Aggregate results

| Metric | Result |
|---|---:|
| Method-B-accepted objects | 23 |
| Allocas / globals | 18 / 5 |
| Objects with multiple minimum-allocation widths | 17 |
| Safe minimum-allocation widths per target | 91 |
| Target/width code-generation evaluations | 273 |
| Full Method C differential tests | 32/32 pass |
| Width-sweep differential tests | 91/91 pass |
| Consistent improvements | 1 object |
| Target-specific regressions | 2 objects |
| Neutral objects | 20 objects |
| Objects whose selected width differs from `w_min` under the strict oracle | 1/23 |

Both Method B and every swept width retain the same accepted-object allocation:
134 B to 67 B. Width selection therefore changes lowering results, not the
DataLayout allocation result.

### Full widest-width Method C versus Method B

| Target | Machine instructions | `.text` bytes | Object-file bytes |
|---|---:|---:|---:|
| x86-64 | +2 | +18 B | +336 B |
| AArch64 | -1 | -4 B | +256 B |
| RISC-V64 | -6 | -14 B | -264 B |

The host linked-executable-size sum is unchanged. All 91 isolated host
executables also have zero file-size delta. These results do not establish a
runtime-speed or energy change.

### Exhaustive safe-width sweep

Each target has 68 alternatives beyond the 23 `w_min` baselines.

| Target | Improved alternatives | Neutral | Regressed | Strict-oracle instruction delta | Strict-oracle `.text` delta |
|---|---:|---:|---:|---:|---:|
| x86-64 | 2 | 62 | 4 | -5 | -12 B |
| AArch64 | 2 | 65 | 1 | -4 | -16 B |
| RISC-V64 | 2 | 66 | 0 | -6 | -14 B |

The six improved target/width observations are the same object twice on three
targets: `select_ranges` at i7 and i8. Under a tie rule that retains the
narrowest equally good candidate, i7 is preferred on all three targets. No
object has different preferred widths across the three targets.

## Complete 23-object classification

Each target cell is `machine-instruction delta / .text-byte delta` relative to
Method B. Negative values improve the measured artifact.

| Object | Kind | Category | B -> widest C | x86-64 | AArch64 | RISC-V64 | Classification |
|---|---|---|---:|---:|---:|---:|---|
| alpha_blend_weights | alloca | image_pixel | i8 -> i8 | 0 / 0 | 0 / 0 | 0 / 0 | neutral |
| checksum_nibbles | alloca | packet_header | i4 -> i8 | 0 / 0 | 0 / 0 | 0 / 0 | neutral |
| embedded_counters | alloca | embedded_state | i5 -> i8 | 0 / 0 | 0 / 0 | 0 / 0 | neutral |
| fir4_coefficients | alloca | dsp_signal | i3 -> i8 | 0 / 0 | 0 / 0 | 0 / 0 | neutral |
| global_constants:lut_a | global | lookup_global | i3 -> i8 | 0 / 0 | 0 / 0 | 0 / 0 | neutral |
| global_constants:lut_b | global | lookup_global | i4 -> i8 | 0 / 0 | 0 / 0 | 0 / 0 | neutral |
| global_flag_table:flags_a | global | lookup_global | i1 -> i8 | 0 / 0 | 0 / 0 | 0 / 0 | neutral |
| global_flag_table:flags_b | global | lookup_global | i2 -> i8 | 0 / 0 | 0 / 0 | 0 / 0 | neutral |
| global_flag_table:flags_c | global | lookup_global | i3 -> i8 | 0 / 0 | 0 / 0 | 0 / 0 | neutral |
| grayscale_threshold | alloca | image_pixel | i8 -> i8 | 0 / 0 | 0 / 0 | 0 / 0 | neutral |
| ipv4_header_fields | alloca | packet_header | i8 -> i8 | 0 / 0 | 0 / 0 | 0 / 0 | neutral |
| packet_flags | alloca | packet_header | i5 -> i8 | 0 / 0 | 0 / 0 | 0 / 0 | neutral |
| pixel_channels | alloca | image_pixel | i8 -> i8 | 0 / 0 | 0 / 0 | 0 / 0 | neutral |
| protocol_version_table | alloca | packet_header | i5 -> i8 | +1 / +1 | 0 / 0 | 0 / 0 | target-specific regression |
| quantized_filter | alloca | dsp_signal | i7 -> i8 | 0 / 0 | 0 / 0 | 0 / 0 | neutral |
| rgb565_unpack | alloca | image_pixel | i6 -> i8 | 0 / 0 | 0 / 0 | 0 / 0 | neutral |
| select_ranges | alloca | unsigned_ranges | i6 -> i8 | -5 / -12 | -4 / -16 | -6 / -14 | consistent improvement |
| signed_delta_pair | alloca | signed_values | i8 -> i8 | 0 / 0 | 0 / 0 | 0 / 0 | neutral |
| signed_offsets | alloca | signed_values | i8 -> i8 | 0 / 0 | 0 / 0 | 0 / 0 | neutral |
| small_state_machine | alloca | embedded_state | i3 -> i8 | 0 / 0 | 0 / 0 | 0 / 0 | neutral |
| status_flags | alloca | embedded_state | i3 -> i8 | 0 / 0 | 0 / 0 | 0 / 0 | neutral |
| tcp_flag_decode | alloca | packet_header | i1 -> i8 | 0 / 0 | 0 / 0 | 0 / 0 | neutral |
| unsigned_histogram | alloca | unsigned_ranges | i7 -> i8 | +6 / +29 | +3 / +12 | 0 / 0 | target-specific regression |

## Successful and regressive cases

### `select_ranges`: real but not a native-width result

Method B's i6 representation leaves two complementary selects and two
reconstruction masks after O2. At i7 or i8, the final InstCombine pass proves
the selected values remain non-negative and eliminates both selects plus one
mask, reducing O2 assignments by four. The lowered function loses 5, 4, and 6
instructions on x86-64, AArch64, and RISC-V64.

i7 and i8 are identical by every measured generated-code metric. The result is
therefore evidence that one semantic slack bit can unlock a middle-end
simplification. It is not evidence that the byte-legal i8 representation is
intrinsically preferable.

### `unsigned_histogram`: SLP-induced regression

Changing i7 to i8 enables SLP to combine four scalar loads into a `<4 x i32>`
load, truncate and mask it as `<4 x i8>`, and then extract lanes for the
prefix-controlled accumulation. Relative to Method B, post-O2 IR adds seven
vector-typed lines, four extracts, and four zero extensions. This costs +6
instructions/+29 B on x86-64 and +3/+12 B on AArch64; RISC-V64 does not form
the vector and ties.

LLVM's SLP remark reports the store tree as profitable locally. Disabling SLP
makes the i7 and i8 x86-64 outputs identical, both with 69 B of `.text`. This
diagnostic establishes SLP as the cause of the measured regression.

### `protocol_version_table`: backend-sensitive regression

i6, i7, and i8 all add one x86-64 instruction and one `.text` byte relative to
i5, while AArch64 and RISC-V64 tie. The O2 assignment and opcode counts are
unchanged. On x86-64, the i5 ordering admits an `lea`; wider variants use a
move, OR, and two ADDs. This is a lowering/register-use sensitivity that the
current IR operation-count features do not predict.

## Predictive-feature and TTI analysis

### TTI

For the widest Method C choice, summed local TTI cost decreases by 40 on every
target. At the isolated-object level, TTI predicts a lower cost for 15 of 23
objects on each target, but only `select_ranges` actually reduces machine
instructions. Precision for strict improvement is therefore 1/15 (6.7%).

Across all 68 nonminimum candidates per target, TTI identifies only one of the
two improving widths for `select_ranges`, misses the equally good i7 candidate,
and favors the regressive i8 versions of `unsigned_histogram` and
`protocol_version_table`. Pearson correlation between TTI delta and machine
instruction delta is approximately -0.01, 0.04, and 0.08 for x86-64, AArch64,
and RISC-V64. Local TTI totals are not an adequate selector for this experiment.

### Pre-code-generation indicators

- DataLayout proves allocation equality but cannot distinguish code generation.
- Native-width legality cannot distinguish the outcomes: the widest i8 rule
  changes 17 objects, yielding one improvement, two regressions, and 14 neutral
  changed objects.
- A strict reduction in post-O2 assignment count selects only i7/i8 for
  `select_ranges` and has no false positive in these 273 observations. This is
  a post-hoc result from one independent object, not a validated predictor.
- New vector IR plus lane extraction flags the `unsigned_histogram` risk, but
  it does not detect the `protocol_version_table` backend regression.
- Exact sign and magnitude are not reliably predictable using the current
  pre-O2 TTI or simple IR counts. A dependable selector would need speculative
  target lowering, a machine-level cost oracle, or a broader trained and
  independently validated structural model.

## Prior-art assessment

Heo et al. (2025) infer bit usage, select a narrower byte width based on the
highest required bit, propagate width changes, and insert extensions when
operand widths differ. They explicitly report that a single narrowed load can
be neutral when extensions are needed, and that later optimizations can change
static instruction counts. They do not describe enumerating multiple
DataLayout-equivalent memory-object widths and selecting among them with a
cross-target lowering oracle.

The general hypothesis is not new. Stephenson et al.'s Bitwise work minimizes
operand widths through range propagation. Redwine and Ramsey's 2004 *Widening
Integer Arithmetic* explicitly models multiple machine-supported widths and
uses dynamic programming to minimize extension cost. A 2026 LLVM sign-extension
elimination RFC also represents multiple possible widths and includes a
profitability planner. These works substantially narrow any novelty claim.

The defensible residual gap is the combination of conservative LLVM
memory-object safety, complete-object DataLayout allocation equivalence, and
empirical comparison of several safe widths through the downstream target
pipeline. The current prototype demonstrates that space, but does not yet
provide a reliable selection method or broad evidence.

Relevant sources:

- S. Heo et al., "Bit-level compiler optimization for ultra low-power embedded
  systems," *Journal of Systems Architecture* 168 (2025), 103546,
  https://doi.org/10.1016/j.sysarc.2025.103546
- K. Redwine and N. Ramsey, "Widening Integer Arithmetic," CC 2004,
  https://www.cs.tufts.edu/~nr/pubs/widen.pdf
- M. Stephenson, J. Babb, and S. Amarasinghe, "Bitwidth Analysis with
  Application to Silicon Compilation," PLDI 2000,
  https://doi.org/10.1145/358438.349317
- LLVM TargetTransformInfo documentation,
  https://llvm.org/doxygen/classllvm_1_1TargetTransformInfo.html
- LLVM RFC, "A New Sign Extension Elimination Pass" (2026),
  https://discourse.llvm.org/t/rfc-a-new-sign-extension-elimination-pass/91506

## Supported claims

1. Allocation-equivalent safe LLVM integer widths can produce different
   optimized IR and target artifacts.
2. `w_min` is not universally best: `select_ranges` is a concrete counterexample
   on all three evaluated targets.
3. Choosing a wider safe width can also regress generated code through
   phase-ordering and vectorization effects.
4. Local TTI cost improvements do not reliably predict whole-pipeline machine
   instruction changes in this experiment.
5. A target-aware selector must model downstream transformations, not only
   DataLayout and primitive cast/load/store costs.

## Unsupported claims to avoid

- Method C generally improves code generation.
- Byte-boundary widths are generally better than arbitrary LLVM widths.
- The preferred width differs across targets in this suite.
- Method C improves runtime, energy, cache behavior, or physical memory use.
- The post-O2 assignment heuristic is validated or generalizable.
- Method C is superior to Heo et al. or invents target-aware width selection.
- TTI provides an exact LLVM 18 legalization or final-code predictor.

## Strengths and weaknesses

Strengths:

- exhaustive evaluation of the complete 91-width minimum-allocation space;
- causal one-object-at-a-time attribution, including multi-global kernels;
- three target backends and two independent differential-test layers;
- a reproducible positive counterexample and two diagnosed regressions;
- frozen safety analysis and unchanged Methods A/B.

Weaknesses:

- the only positive result is one controlled kernel;
- no target chooses a different preferred width under the stated objective;
- the apparent post-O2 predictor is derived from one positive object;
- final outcomes depend on InstCombine, SLP, instruction selection, and register
  use, making a portable early selector difficult;
- globals require function/subtarget-aware treatment because TTI is a function
  analysis;
- the external MiBench transformation set has not been swept for Method C.

## Paper integration recommendation

Do not add Method C as a main contribution, do not change the title, and do not
change the main results. If the authors want to mention it now, restrict the
mention to a short Future Work observation: allocation-equivalent safe widths
form a downstream-sensitive search space, but the current controlled evidence
is too sparse for a selection claim.

The genuinely necessary next experiment is a preregistered external sweep over
the existing MiBench Method-B transformations, using a selection rule fixed
before examining their final machine code. Method C should move beyond future
work only if that independent set produces repeated strict wins, avoids
regressions, and demonstrates either target-dependent choices or a reliable
cross-target selector.
