# Method C feasibility assessment

## 1. Prior-art verdict

The direction is differentiated only in a narrow combination. Bitwise-style
analysis minimizes inferred operand widths; Heo et al. infer required bit/byte
usage for AVR-oriented data-width optimization; variable-packing work exploits
known widths for packing; and LLVM work on sign-extension elimination consults
legal instruction widths. The targeted search did not find prior work that
combines conservative LLVM memory-object safety, complete-object DataLayout
allocation, enumeration of multiple safe widths, and per-target lowering/code
generation selection. This is a meaningful gap, but not a claim that
target-aware width selection itself is unprecedented.

## 2. Exact gap

For one already-safe LLVM memory-object rewrite, determine whether a width
larger than `w_min` but allocation-equivalent under the active DataLayout yields
better lowering than `w_min`, without changing the safety proof or claiming
that narrower IR always improves generated code.

## 3. LLVM 18 feasibility

LLVM 18.1.8 provides:

- `DataLayout::getTypeAllocSize` for complete-object allocation;
- public TTI queries including `isTypeLegal`, `getCastInstrCost`, and
  `getMemoryOpCost`;
- function-specific `TargetIRAnalysis`, because TTI can vary by subtarget.

LLVM 18 does not expose `getTypeLegalizationCost` through the public
`TargetTransformInfo` interface. That implementation is available inside
`BasicTTIImpl`, while exact type actions live in code-generation
`TargetLowering`. A module pass also cannot assign one unqualified TTI result to
a global used by functions with different subtarget attributes. Therefore a
small offline LLVM-lowering oracle is practical; a production-quality generic
in-pass legalization model is not a small extension.

## 4. Experiment

The separate pipeline `adaptive-width-mem-method-c` leaves Methods A and B
unchanged. It reuses the existing safety result, enumerates all widths from
`w_min` to `W-1`, minimizes complete-object allocation, and emits the widest
candidate among equally minimal allocations. Actual LLVM 18 O2 lowering then
tests whether that candidate is preferable to Method B's `w_min` on x86-64,
AArch64, and RISC-V64.

The experiment covers the unchanged 32-kernel controlled suite. It measures raw
and O2 IR assignments, TTI cost-model totals, disassembled machine instructions,
`.text` bytes, object-file bytes, and x86-64 differential execution.

## 5. Key results

- Safely narrowable Method A objects examined: 26.
- Safe widths enumerated: 271.
- Allocation-positive width alternatives: 91.
- Method B and C accepted objects: 23 each.
- Accepted objects with multiple equal-minimum-allocation widths: 17/23.
- Method C width differs from `w_min`: 17/23.
- Both methods retain the same complete-object allocation result: 134 B to
  67 B, saving 67 B.
- Method B widths are i1 through i8; the experimental candidate generator
  selects i8 for all 23 accepted objects.
- Differential execution: 32/32 pass, 0 fail.
- Summed x86-64 linked-executable-size delta versus the original programs: 0 B.

| Target | B machine inst. | C machine inst. | C-B | B `.text` | C `.text` | C-B | B object | C object | C-B |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| x86-64 | 366 | 368 | +2 | 875 B | 893 B | +18 B | 30112 B | 30448 B | +336 B |
| AArch64 | 226 | 225 | -1 | 904 B | 900 B | -4 B | 32504 B | 32760 B | +256 B |
| RISC-V64 | 494 | 488 | -6 | 1178 B | 1164 B | -14 B | 40536 B | 40272 B | -264 B |

TTI's summed local IR cost decreases by 40 on each target, but machine-code
results do not uniformly follow that estimate. Only `select_ranges` improves on
all three targets when i6 is replaced by allocation-equivalent i8: -5, -4, and
-6 machine instructions on x86-64, AArch64, and RISC-V64 respectively. In
contrast, changing `unsigned_histogram` from i7 to i8 adds 6 instructions on
x86-64 and 3 on AArch64 while tying on RISC-V64. Changing
`protocol_version_table` from i5 to i8 adds one x86-64 instruction and ties on
the other targets.

An offline per-benchmark oracle choosing the better of Method B and the
byte-boundary candidate would reduce the total relative to Method B by 5, 4,
and 6 machine instructions and by 12 B, 16 B, and 14 B of `.text` on x86-64,
AArch64, and RISC-V64. The opportunity is therefore measurable but concentrated
in one of 32 kernels.

## 6. Novelty and contribution assessment

The experiment supports the hypothesis: the minimum safe width is not always
the best lowered representation, and the preferred choice can vary by target
and use graph. It also reveals a sharper result: local TTI cast/memory costs can
favor a wider legal type even when whole-pipeline code generation regresses.

The strongest defensible future claim is: allocation-equivalent safe LLVM
memory widths form a target-sensitive selection space, and selecting among them
requires downstream-aware evaluation rather than minimum-width or DataLayout
reasoning alone.

The present evidence is too sparse and inconsistent for a new main-paper
contribution. A fixed byte-boundary heuristic regresses on x86-64 overall, only
one kernel improves consistently, and exact legalization information is not a
portable public LLVM 18 IR-pass API.

## 7. Final decision

**KEEP AS FUTURE WORK.**

The hypothesis is worthwhile, and the prototype establishes feasibility and a
real counterexample to `w_min`-always-best. It should move into the paper only
after a per-object target-specific selector avoids the measured regressions and
the effect repeats on a broader external benchmark set.

