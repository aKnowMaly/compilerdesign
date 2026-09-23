# Compiler Design · Review 1

**Topic:** Target-aware conservative width narrowing of LLVM memory objects.
**Stage:** Research proposal. All transformations, validation steps, and outcomes below are planned; no final result is presented.
**Source-status note:** The separate ten-paper original survey has not yet been supplied. Papers 1–10 below are a provisional foundational set verified against academic records, not a claim about the contents of that survey. Replace/reconcile them when the original file arrives. Papers 11–30 are an independently checked expansion.

## Recommended slide-by-slide structure and exact slide content

### Slide 1 — Compiler Design · Review 1

- Target-aware conservative width narrowing of LLVM memory objects
- Research proposal · LLVM 18 · selected stack arrays and private globals

### Slide 2 — Problem statement and technical idea

- Wide integer types can reserve more storage than reachable values need.
- Example: 100 i32 elements declare 400 bytes; i8 would declare 100 bytes if every value fits 0–255.
- A smaller type is legal only if all stores, loads, pointer uses, and signedness semantics remain valid.
- Proposed question: when can LLVM narrow a complete memory object safely and usefully?
- A smaller IR type does not guarantee a smaller target allocation or faster code.

### Slide 3 — Objectives and initial scope

- Infer a conservative smaller element width for selected integer arrays and internal/private globals.
- Preserve observable values by proving the needed zero extension or sign extension after loads.
- Reject escaping pointers, unknown stores, externally visible layouts, and volatile/atomic accesses.
- Accept a rewrite only when the target reports a smaller complete-object allocation.
- Evaluate correctness, candidate coverage, code size, and runtime against unchanged LLVM 18.
- Initial scope excludes heap objects, structures, vector objects, and approximate precision.

### Slide 4 — Existing system vs proposed work

| Decision | Existing LLVM baseline | Proposed study |
|---|---|---|
| Decision unit | Scalar values and promotable allocas | Selected complete memory objects |
| Width choice | General LLVM simplification | Proven stored range and bit facts |
| Target rule | Normal target lowering | Explicit allocation-size gate |
| Evidence | Standard compiler tests | Candidate log, IR checks, differential runs |

### Slide 5 — Literature review · inferring required bits

Cousot and Cousot [2] establish sound approximation; Wegman and Zadeck [3] use branch-sensitive propagation. These foundations explain why a smaller width must be proved across reachable paths.

Bitwise [4] propagates width constraints forward and backward. BitValue [5] detects constant and unused bits. Both show that computation often carries redundant bits, chiefly in hardware-oriented settings.

MiniBit [6] applies affine arithmetic to fixed-point circuits. Gort and Anderson [19] combine ranges with bitmasks; Zhang et al. [20] use a bit-flow graph for FPGA synthesis.

Together, these works inform candidate width analysis. They do not by themselves establish when changing a complete LLVM array or global preserves pointer behavior and reduces allocated bytes.

Papers discussed: [2], [3], [4], [5], [6], [19], [20].

### Slide 6 — Literature review · changing storage

Bhaskaracharya et al. [10] contract array storage through reuse across scheduled loops. Cooprider and Regehr [21] pack embedded RAM using whole-program analysis; Zhang and Gupta [28] compress heap fields.

Heo et al. [11] is close prior art: an LLVM-based bit-usage analysis narrows selected memory accesses and computations for embedded processors. This rules out a broad claim of originating LLVM memory-width optimization.

Jain et al. [14] examine executable-size effects of LLVM passes. Cherubin and Agosta [15] survey reduced-precision tools, including error-tolerant settings. Neither metric nor precision model can be transferred to exact integer storage unchanged.

The project therefore tests a bounded question: safe whole-object element-width changes, exact load reconstruction, and a measured reduction in target allocation size.

Papers discussed: [10], [11], [14], [15], [21], [28].

### Slide 7 — Literature review · widths and target resources

Mahlke et al. [7] and Cong et al. [26] use bitwidth in accelerator synthesis. Lee et al. [8] guarantee fixed-point accuracy. These works optimize hardware area or bounded error rather than exact LLVM memory representation.

Tallam and Gupta [22], Nandivada and Barik [9], and Canesche et al. [23] exploit narrow values in register allocation or binding. Register savings should not be reported as object-allocation savings.

Li et al. [25] and BitSpec [24] add speculation or hardware support for narrow registers. Bhagat et al. [27] prune unproductive narrow computations; the proposed pass instead uses static proof before a memory rewrite.

The common lesson is that bit savings depend on the target resource. The proposed DataLayout gate will test complete-object allocation, not infer physical savings from IR width alone.

Papers discussed: [7], [8], [9], [22], [23], [24], [25], [26], [27].

### Slide 8 — Literature review · validation and evaluation

LLVM [1] supplies the typed IR and pass framework. Alive [29] checks local rewrite rules; Alive2 [12] validates bounded LLVM IR translations. Object rewrites still require explicit pointer and layout reasoning.

Zhou et al. [17] study optimization bugs. Csmith [30] and CsmithEdge [18] generate challenging compiler tests while addressing undefined behavior. These motivate negative cases and baseline-versus-transformed execution.

Jantz and Kulkarni [16] show that pass order can matter. MiBench [13] supplies embedded workloads. A controlled experiment must hold the LLVM pipeline fixed and report cases that cannot be tested.

The review supports four distinct evaluation claims: correctness, transformation coverage, target allocation, and downstream binary/runtime effects. None should be substituted for another.

Papers discussed: [1], [12], [13], [16], [17], [18], [29], [30].

### Slide 9 — Research gap and proposed workflow

- Width inference, RAM compression, narrow LLVM accesses, and compiler validation are established areas.
- Heo et al. (2025) is close prior work; the claim is a narrower, testable integration question.
- Select eligible complete objects → inspect stores/loads/pointers → prove width and extension rule.
- Check the target DataLayout allocation → rewrite only profitable safe cases → verify and log rejections.
- Study how many cases survive safety and target-size checks, and why others do not.

### Slide 10 — Ten proposed novelty points

- 1  Complete array or private global is the width decision unit.
- 2  Combine stored-value proof with every load and pointer use.
- 3  Track zero-extension and sign-extension obligations separately.
- 4  Require the complete target allocation to shrink.
- 5  Use an explicit safe-use policy for each object class.
- 6  Reject mixed signed/unsigned evidence rather than guess.
- 7  Record a precise reason for every rejected candidate.
- 8  Study pass placement alongside SROA and other LLVM passes.
- 9  Separate IR width, target allocation, binary size, and runtime.
- 10 Compare a safety-only pass with a target-size-gated variant.

### Slide 11 — Validation plan and expected outcomes

- Correctness: LLVM verifier, focused positive/negative IR tests, and differential execution.
- Coverage: accepted widths, skipped objects, and reasons for rejection.
- Resource evidence: report declared IR width and target allocation size separately.
- Secondary evidence: executable size and runtime under identical baseline settings.
- Expected deliverables: LLVM 18 prototype, reproducible test cases, and a bounded evaluation.
- No speedup or universal memory saving is assumed; null results will be reported.

### Slide 12 — Review 1 plan and faculty questions

- Now: reconcile the original ten papers and finish the 30-paper survey.
- Next: implement candidate analysis, guarded rewrite, and IR verification.
- Then: run controlled baseline comparisons and inspect rejected cases.
- Likely question — Why not SROA? SROA promotes or splits; this study targets surviving object storage widths.
- Likely question — Why might i32→i8 not help? Padding, alignment, and target lowering can remove the saving.
- Likely question — What if safety cannot be proved? Keep the original object unchanged.

## Complete 30-paper literature review

Each entry states the paper’s method or evidence and its boundary relative to the proposed project. A boundary is a scope comparison, not a claim that the paper is deficient.

1. **Lattner and Adve (2004). LLVM: A Compilation Framework for Lifelong Program Analysis and Transformation.** CGO. [DOI](https://doi.org/10.1109/CGO.2004.1281665). Introduces LLVM as a typed SSA intermediate representation with reusable analysis and transformation infrastructure. It supplies the implementation setting; it does not propose this memory-width decision.

2. **Cousot and Cousot (1977). Abstract Interpretation: A Unified Lattice Model for Static Analysis of Programs by Construction or Approximation of Fixpoints.** POPL. [DOI](https://doi.org/10.1145/512950.512973). Formalizes abstract interpretation through sound approximations and fixpoints. It justifies conservative width proofs: an unknown reachable value cannot be assumed to fit a smaller representation.

3. **Wegman and Zadeck (1991). Constant Propagation with Conditional Branches.** ACM TOPLAS. [DOI](https://doi.org/10.1145/103135.103136). Develops sparse conditional constant propagation, using branch information to discover constants. It can refine value facts but does not choose a new storage type for an array or global.

4. **Stephenson et al. (2000). Bitwidth Analysis with Application to Silicon Compilation.** PLDI. [DOI](https://doi.org/10.1145/349299.349317). Bitwise propagates width information forward and backward to minimize operand widths, then applies the result to silicon compilation. It establishes bitwidth inference, while our study asks about complete LLVM memory objects.

5. **Budiu et al. (2000). BitValue Inference: Detecting and Exploiting Narrow Bitwidth Computations.** Euro-Par. [DOI](https://doi.org/10.1007/3-540-44520-X_137). BitValue uses forward and backward dataflow to discover constant and unused bits in C computations. That evidence can suggest candidates, but a memory rewrite also needs pointer-use and load-semantics checks.

6. **Lee et al. (2005). MiniBit: Bit-Width Optimization via Affine Arithmetic.** DAC. [DOI](https://doi.org/10.1145/1065579.1065799). MiniBit uses affine arithmetic to choose integer and fractional bit widths for fixed-point hardware designs. Its precision and circuit-area goals differ from exact integer memory semantics in LLVM.

7. **Mahlke et al. (2001). Bitwidth Cognizant Architecture Synthesis of Custom Hardware Accelerators.** IEEE TCAD. [DOI](https://doi.org/10.1109/43.959864). Makes hardware accelerator synthesis aware of operation bitwidths when allocating architectural resources. It supports target-aware reasoning, though its resource is synthesized hardware rather than software memory allocation.

8. **Lee et al. (2006). Accuracy-Guaranteed Bit-Width Optimization.** IEEE TCAD. [DOI](https://doi.org/10.1109/TCAD.2006.873887). Extends bit-width optimization with a guarantee about fixed-point output accuracy. The project instead seeks exact preservation of integer values and memory behavior, without an error budget.

9. **Nandivada and Barik (2013). Improved Bitwidth-Aware Variable Packing.** ACM TACO. [DOI](https://doi.org/10.1145/2509420.2509427). Improves packing of narrow live values into physical registers, including width-aware representations. Register pressure and spills are relevant downstream effects, but the method does not itself narrow array storage.

10. **Bhaskaracharya et al. (2016). Automatic Storage Optimization for Arrays.** ACM TOPLAS. [DOI](https://doi.org/10.1145/2845078). Finds smaller storage mappings for arrays across scheduled loop nests by reusing locations whose value lifetimes do not overlap. This changes array extents and mapping, whereas our proposed pass changes selected element widths.

**Papers 11–30: additional researched set.**

11. **Heo et al. (2025). Bit-Level Compiler Optimization for Ultra Low-Power Embedded Systems.** Journal of Systems Architecture. [DOI](https://doi.org/10.1016/j.sysarc.2025.103546). Uses LLVM bit-usage analysis and width transformations for narrow embedded processors, including narrower memory accesses. This is close prior art; our study must test a distinct complete-object, target-allocation criterion without claiming to originate LLVM width narrowing.

12. **Lopes et al. (2021). Alive2: Bounded Translation Validation for LLVM.** PLDI. [DOI](https://doi.org/10.1145/3453483.3454030). Checks bounded equivalence of LLVM IR transformations using SMT reasoning. It can help validate individual rewrites, but bounded analysis has limits, so differential tests and explicit safety rules remain necessary.

13. **Guthaus et al. (2001). MiBench: A Free, Commercially Representative Embedded Benchmark Suite.** IEEE WWC. [DOI](https://doi.org/10.1109/WWC.2001.990739). Introduces a representative embedded benchmark suite. It offers workloads for planned evaluation, but its existence is not evidence that this proposed pass improves them.

14. **Jain et al. (2019). An Analysis of Executable Size Reduction by LLVM Passes.** CSI Transactions on ICT. [DOI](https://doi.org/10.1007/s40012-019-00248-5). Studies how LLVM passes affect final executable size. It motivates measuring binary size separately because a narrower IR object need not yield a smaller executable.

15. **Cherubin and Agosta (2020). Tools for Reduced Precision Computation: A Survey.** ACM Computing Surveys. [DOI](https://doi.org/10.1145/3381039). Surveys tools for reduced precision and their automation challenges. Many surveyed uses tolerate numerical error; this project targets exact integer behavior and therefore needs different acceptance rules.

16. **Jantz and Kulkarni (2014). Analyzing and Addressing False Interactions During Compiler Optimization Phase Ordering.** Software: Practice and Experience. [DOI](https://doi.org/10.1002/spe.2176). Analyzes false interactions caused by optimization phase ordering. It motivates comparing pass placement with SROA and related passes rather than treating pipeline order as irrelevant.

17. **Zhou et al. (2021). An Empirical Study of Optimization Bugs in GCC and LLVM.** Journal of Systems and Software. [DOI](https://doi.org/10.1016/j.jss.2020.110884). Empirically studies optimization bugs in GCC and LLVM. It provides a correctness motivation, not a width-selection algorithm, and supports a strong rejection policy for uncertain cases.

18. **Even-Mendoza et al. (2022). CsmithEdge: More Effective Compiler Testing by Handling Undefined Behaviour Less Conservatively.** Empirical Software Engineering. [DOI](https://doi.org/10.1007/s10664-022-10146-1). Improves compiler test generation by handling undefined behavior less conservatively. It informs adversarial test design, but generated tests cannot prove every rewrite correct.

19. **Gort and Anderson (2013). Range and Bitmask Analysis for Hardware Optimization in High-Level Synthesis.** ASP-DAC. [DOI](https://doi.org/10.1109/ASPDAC.2013.6509694). Combines value-range and bitmask analyses in high-level synthesis to reduce hardware resources. The combined facts are useful for width inference, but the evaluated target is an FPGA circuit.

20. **Zhang et al. (2010). Bit-Level Optimization for High-Level Synthesis and FPGA-Based Acceleration.** FPGA. [DOI](https://doi.org/10.1145/1723112.1723124). Builds a bit-flow graph for bit-level transformations in high-level synthesis and FPGA acceleration. It demonstrates fine-grained bit reasoning, while generated circuits have different storage constraints from LLVM software objects.

21. **Cooprider and Regehr (2007). Offline Compression for On-Chip RAM.** PLDI. [DOI](https://doi.org/10.1145/1250734.1250776). Uses whole-program value and pointer analysis to pack globals, arrays, and structures for on-chip RAM. It directly motivates storage reduction, but its source-level compression and tradeoffs are broader than our conservative LLVM object rewrite.

22. **Tallam and Gupta (2003). Bitwidth Aware Global Register Allocation.** POPL. [DOI](https://doi.org/10.1145/604131.604139). Uses inferred bitwidths to co-locate subword live values in registers. The result concerns register allocation, so it should not be counted as a demonstrated reduction in the bytes allocated for arrays or globals.

23. **Canesche et al. (2022). A Polynomial Time Exact Solution to the Bit-Aware Register Binding Problem.** Compiler Construction. [DOI](https://doi.org/10.1145/3497776.3517773). Provides an exact polynomial-time solution for a bit-aware register-binding problem. It strengthens the evidence for width-sensitive target decisions, but addresses binding rather than LLVM memory-object layout.

24. **McMichen et al. (2025). Saving Energy with Per-Variable Bitwidth Speculation.** ASPLOS. [DOI](https://doi.org/10.1145/3676641.3716271). Selects per-variable widths with profile-guided speculation and compiler–architecture support. It explores performance beyond static proofs; our proposed pass will avoid speculation and preserve behavior through conservative analysis.

25. **Li et al. (2005). Speculative Subword Register Allocation in Embedded Processors.** LCPC / LNCS. [DOI](https://doi.org/10.1007/11532378_6). Speculatively places subword values into register halves with an embedded-processor instruction-set extension. It reduces potential spills, but requires hardware support and targets registers rather than object representation.

26. **Cong et al. (2005). Bitwidth-Aware Scheduling and Binding in High-Level Synthesis.** ASP-DAC. [DOI](https://doi.org/10.1145/1120725.1121055). Includes bitwidth in high-level synthesis scheduling and binding decisions. It shows why target resource models matter, although its output is custom hardware rather than native LLVM object allocation.

27. **Bhagat et al. (2011). Global Productiveness Propagation: A Code Optimization Technique to Speculatively Prune Useless Narrow Computations.** LCTES. [DOI](https://doi.org/10.1145/1967677.1967700). Propagates whether narrow computations are productive so useless work can be pruned speculatively. The target is computation pruning, not a proof that an entire stored object can change type.

28. **Zhang and Gupta (2002). Data Compression Transformations for Dynamically Allocated Data Structures.** Compiler Construction / LNCS. [DOI](https://doi.org/10.1007/3-540-45937-5_4). Compresses fields in dynamically allocated data structures using narrow-data and pointer representations, with processor support. It is relevant memory-compression prior art; heap fields are outside our initial scope.

29. **Lopes et al. (2015). Provably Correct Peephole Optimizations with Alive.** PLDI. [DOI](https://doi.org/10.1145/2737924.2737965). Uses the Alive framework to specify and prove local LLVM peephole optimizations. It offers a model for checking rewrite semantics, while a whole memory-object conversion needs additional pointer and layout reasoning.

30. **Yang et al. (2011). Finding and Understanding Bugs in C Compilers.** PLDI. [DOI](https://doi.org/10.1145/1993498.1993532). Uses randomized C programs to expose wrong-code compiler bugs. It motivates differential execution of baseline and transformed programs, while testing remains finite evidence rather than a universal proof.

## Research gap

Published work demonstrates bitwidth inference, RAM compression, LLVM bit-usage optimization, and compiler validation. In particular, Heo et al. (2025) already studies narrow LLVM memory accesses, so a broad claim of first LLVM memory narrowing would be unsound. This project asks a narrower question: can an LLVM 18 pass safely change the element type of selected complete local arrays and internal/private globals, reconstruct signed or unsigned loads correctly, and require a real target allocation-size reduction? The evaluation will measure accepted and rejected cases under one controlled baseline.

## Existing system

The baseline is an unchanged Clang/LLVM 18 optimization pipeline. LLVM already performs scalar simplification and SROA for promotable stack aggregates. Existing value facts and register-level width techniques do not establish that each candidate complete array or private global can safely change storage type. The proposed pass will be compared with this baseline using identical inputs and settings.

## Proposed work

Select eligible objects; inspect stores, loads and pointer uses; derive a conservative width and extension rule; compare complete-object allocation sizes through `DataLayout`; rewrite only supported cases; verify IR and program output; log each rejection. Heap objects, externally visible ABI objects, volatile/atomic memory, and unsupported pointer uses are outside the initial scope.

## Ten proposed novelty points

- 1  Complete array or private global is the width decision unit.
- 2  Combine stored-value proof with every load and pointer use.
- 3  Track zero-extension and sign-extension obligations separately.
- 4  Require the complete target allocation to shrink.
- 5  Use an explicit safe-use policy for each object class.
- 6  Reject mixed signed/unsigned evidence rather than guess.
- 7  Record a precise reason for every rejected candidate.
- 8  Study pass placement alongside SROA and other LLVM passes.
- 9  Separate IR width, target allocation, binary size, and runtime.
- 10 Compare a safety-only pass with a target-size-gated variant.

These are proposed design and evaluation differentiators. They are not ten independent claims of invention; several ingredients are established in prior work.

## Expected outcomes

- Expected deliverables: LLVM 18 prototype, reproducible test cases, and a bounded evaluation.
- No speedup or universal memory saving is assumed; null results will be reported.

## Likely faculty questions and concise answers

1. **What is bitwidth narrowing?** Represent a value with fewer bits only when analysis proves all observable results remain the same.

2. **Why memory objects instead of only arithmetic instructions?** A smaller computation does not necessarily change the allocated array or global; the project studies that storage decision.

3. **How is this different from SROA?** SROA splits or promotes suitable stack aggregates. Our proposed decision is whether a selected remaining object can safely use a narrower integer element type.

4. **Is narrow memory access already studied?** Yes. Heo et al. (2025) is close prior work. We will compare scope and methods, especially complete-object size, signed reconstruction, and rejection policy.

5. **What happens if the pointer escapes?** The object stays unchanged because outside code may rely on its representation.

6. **How do signed values differ?** A narrow negative value must be restored with sign extension; nonnegative unsigned data uses zero extension. The pass must prove which is valid.

7. **Does i32 to i8 always save 75% of memory?** No. The bit count is a logical illustration; padding, alignment, target layout, and code generation determine actual allocation and performance.

8. **How will you check correctness?** Run the LLVM verifier, focused positive and negative IR tests, and differential execution against the unchanged baseline.

9. **What is the baseline?** The same Clang/LLVM 18 pipeline and workload, with the proposed pass disabled.

10. **What if no performance gain appears?** Report that result. Safety, coverage, target allocation changes, and the reasons a rewrite was rejected are still meaningful findings.

11. **Are all ten novelty points individually new?** No. They are defensible proposed design and evaluation differentiators; the study tests their combined value without a first-ever claim.

## Key technical sources

- [LLVM pass reference](https://llvm.org/docs/Passes.html)
- [LLVM language reference](https://llvm.org/docs/LangRef.html)
- [LLVM DataLayout allocation size](https://llvm.org/doxygen/classllvm_1_1DataLayout.html)
- [LLVM KnownBits](https://llvm.org/doxygen/structllvm_1_1KnownBits.html)