import fs from 'node:fs/promises';
import path from 'node:path';
import { pathToFileURL } from 'node:url';
import { Presentation, PresentationFile } from '@oai/artifact-tool';

const workspaceDir = 'C:/Users/admin/Documents/ChatGPT/compilerdesign';
const SKILL_DIR = 'C:/Users/admin/.codex/plugins/cache/openai-primary-runtime/presentations/26.921.11914/skills/presentations';
const RUNTIME_PYTHON = 'C:/Users/admin/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe';
const buildDir = path.join(workspaceDir, 'review1_build');
const outputDir = path.join(workspaceDir, 'output', 'review1');
const finalPath = path.join(outputDir, 'Compiler_Design_Review_1_Compact_Literature_Review.pptx');
const reportPath = path.join(outputDir, 'Review_1_Content_Literature_and_QA.md');
const { finalizePresentation, resolvePresentationFont } = await import(pathToFileURL(path.join(SKILL_DIR, 'container_tools/artifact_tool_utils.mjs')).href);

// The first ten are a temporary workspace-backed core. Replace them with the
// user's original survey before final handoff if it differs.
const papers = [
  ['Lattner and Adve','2004','LLVM: A Compilation Framework for Lifelong Program Analysis and Transformation','CGO','10.1109/CGO.2004.1281665','LLVM IR and pass infrastructure make an implementable object-level transformation possible.'],
  ['Cousot and Cousot','1977','Abstract Interpretation: A Unified Lattice Model for Static Analysis of Programs by Construction or Approximation of Fixpoints','POPL','10.1145/512950.512973','Provides the conservative analysis principle: unknown values must not be narrowed.'],
  ['Wegman and Zadeck','1991','Constant Propagation with Conditional Branches','ACM TOPLAS','10.1145/103135.103136','Shows how control flow can refine value facts used by width analysis.'],
  ['Stephenson et al.','2000','Bitwidth Analysis with Application to Silicon Compilation','PLDI','10.1145/349299.349317','Foundational forward and backward bitwidth inference, mainly applied to hardware generation.'],
  ['Budiu et al.','2000','BitValue Inference: Detecting and Exploiting Narrow Bitwidth Computations','Euro-Par','10.1007/3-540-44520-X_137','Identifies unused and constant bits through dataflow, motivating proof of narrow stored values.'],
  ['Lee et al.','2005','MiniBit: Bit-Width Optimization via Affine Arithmetic','DAC','10.1145/1065579.1065799','Shows affine range reasoning for selecting narrower widths in fixed-point hardware.'],
  ['Mahlke et al.','2001','Bitwidth Cognizant Architecture Synthesis of Custom Hardware Accelerators','IEEE TCAD','10.1109/43.959864','Connects width information with target-specific resource choices.'],
  ['Lee et al.','2006','Accuracy-Guaranteed Bit-Width Optimization','IEEE TCAD','10.1109/TCAD.2006.873887','Studies guaranteed accuracy in fixed-point synthesis; our integer memory rewrite requires exact semantics.'],
  ['Nandivada and Barik','2013','Improved Bitwidth-Aware Variable Packing','ACM TACO','10.1145/2509420.2509427','Uses narrow values for register packing, a different resource from memory objects.'],
  ['Bhaskaracharya et al.','2016','Automatic Storage Optimization for Arrays','ACM TOPLAS','10.1145/2845078','Shows that array storage layout can be transformed; motivates an LLVM object-level scope.'],
  ['Heo et al.','2025','Bit-Level Compiler Optimization for Ultra Low-Power Embedded Systems','Journal of Systems Architecture','10.1016/j.sysarc.2025.103546','A close LLVM-based predecessor for bit usage and narrow memory accesses; the proposal must be compared directly.'],
  ['Lopes et al.','2021','Alive2: Bounded Translation Validation for LLVM','PLDI','10.1145/3453483.3454030','Motivates bounded equivalence checks for individual IR rewrites.'],
  ['Guthaus et al.','2001','MiBench: A Free, Commercially Representative Embedded Benchmark Suite','IEEE WWC','10.1109/WWC.2001.990739','Provides representative embedded workloads for planned external evaluation.'],
  ['Jain et al.','2019','An Analysis of Executable Size Reduction by LLVM Passes','CSI Transactions on ICT','10.1007/s40012-019-00248-5','Reminds us to measure final executable size separately from IR width.'],
  ['Cherubin and Agosta','2020','Tools for Reduced Precision Computation: A Survey','ACM Computing Surveys','10.1145/3381039','Maps reduced-precision tools and highlights the distinction between approximate and exact transformations.'],
  ['Jantz and Kulkarni','2014','Analyzing and Addressing False Interactions During Compiler Optimization Phase Ordering','Software: Practice and Experience','10.1002/spe.2176','Supports explicit study of how pass placement changes opportunities.'],
  ['Zhou et al.','2021','An Empirical Study of Optimization Bugs in GCC and LLVM','Journal of Systems and Software','10.1016/j.jss.2020.110884','Shows why correctness testing is central to a compiler optimization proposal.'],
  ['Even-Mendoza et al.','2022','CsmithEdge: More Effective Compiler Testing by Handling Undefined Behaviour Less Conservatively','Empirical Software Engineering','10.1007/s10664-022-10146-1','Informs test design for undefined-behavior boundaries.'],
  ['Gort and Anderson','2013','Range and Bitmask Analysis for Hardware Optimization in High-Level Synthesis','ASP-DAC','10.1109/ASPDAC.2013.6509694','Combines range and bitmask facts; suggests stronger candidate width inference.'],
  ['Zhang et al.','2010','Bit-Level Optimization for High-Level Synthesis and FPGA-Based Acceleration','FPGA','10.1145/1723112.1723124','Uses bit-flow information for hardware; contrasts with software memory layout.'],
  ['Cooprider and Regehr','2007','Offline Compression for On-Chip RAM','PLDI','10.1145/1250734.1250776','Whole-program packing reduces RAM but uses a broader source transformation than the proposed conservative LLVM pass.'],
  ['Tallam and Gupta','2003','Bitwidth Aware Global Register Allocation','POPL','10.1145/604131.604139','Exploits subword values in registers, not direct storage-type narrowing.'],
  ['Canesche et al.','2022','A Polynomial Time Exact Solution to the Bit-Aware Register Binding Problem','Compiler Construction','10.1145/3497776.3517773','Formalizes bit-aware register binding, another target resource decision.'],
  ['McMichen et al.','2025','Saving Energy with Per-Variable Bitwidth Speculation','ASPLOS','10.1145/3676641.3716271','Contrasts speculative hardware-supported widths with the proposed static safety policy.'],
  ['Li et al.','2005','Speculative Subword Register Allocation in Embedded Processors','LCPC / LNCS','10.1007/11532378_6','Uses runtime speculation for subword registers; this project keeps memory rewrites static.'],
  ['Cong et al.','2005','Bitwidth-Aware Scheduling and Binding in High-Level Synthesis','ASP-DAC','10.1145/1120725.1121055','Shows width and target resources must be considered together.'],
  ['Bhagat et al.','2011','Global Productiveness Propagation: A Code Optimization Technique to Speculatively Prune Useless Narrow Computations','LCTES','10.1145/1967677.1967700','Studies useful narrow computations and speculation; informs candidate screening.'],
  ['Zhang and Gupta','2002','Data Compression Transformations for Dynamically Allocated Data Structures','Compiler Construction / LNCS','10.1007/3-540-45937-5_4','Shows narrow-data compression of heap fields; excluded heap objects define our initial scope.'],
  ['Lopes et al.','2015','Provably Correct Peephole Optimizations with Alive','PLDI','10.1145/2737924.2737965','Demonstrates machine-checked validation of LLVM optimization patterns.'],
  ['Yang et al.','2011','Finding and Understanding Bugs in C Compilers','PLDI','10.1145/1993498.1993532','Supports differential execution tests to detect wrong-code transformations.'],
];
if (papers.length !== 30 || new Set(papers.map(p => p[4].toLowerCase())).size !== 30) throw new Error('Paper count or DOI duplication');
const paperReviews = [
  'Introduces LLVM as a typed SSA intermediate representation with reusable analysis and transformation infrastructure. It supplies the implementation setting; it does not propose this memory-width decision.',
  'Formalizes abstract interpretation through sound approximations and fixpoints. It justifies conservative width proofs: an unknown reachable value cannot be assumed to fit a smaller representation.',
  'Develops sparse conditional constant propagation, using branch information to discover constants. It can refine value facts but does not choose a new storage type for an array or global.',
  'Bitwise propagates width information forward and backward to minimize operand widths, then applies the result to silicon compilation. It establishes bitwidth inference, while our study asks about complete LLVM memory objects.',
  'BitValue uses forward and backward dataflow to discover constant and unused bits in C computations. That evidence can suggest candidates, but a memory rewrite also needs pointer-use and load-semantics checks.',
  'MiniBit uses affine arithmetic to choose integer and fractional bit widths for fixed-point hardware designs. Its precision and circuit-area goals differ from exact integer memory semantics in LLVM.',
  'Makes hardware accelerator synthesis aware of operation bitwidths when allocating architectural resources. It supports target-aware reasoning, though its resource is synthesized hardware rather than software memory allocation.',
  'Extends bit-width optimization with a guarantee about fixed-point output accuracy. The project instead seeks exact preservation of integer values and memory behavior, without an error budget.',
  'Improves packing of narrow live values into physical registers, including width-aware representations. Register pressure and spills are relevant downstream effects, but the method does not itself narrow array storage.',
  'Finds smaller storage mappings for arrays across scheduled loop nests by reusing locations whose value lifetimes do not overlap. This changes array extents and mapping, whereas our proposed pass changes selected element widths.',
  'Uses LLVM bit-usage analysis and width transformations for narrow embedded processors, including narrower memory accesses. This is close prior art; our study must test a distinct complete-object, target-allocation criterion without claiming to originate LLVM width narrowing.',
  'Checks bounded equivalence of LLVM IR transformations using SMT reasoning. It can help validate individual rewrites, but bounded analysis has limits, so differential tests and explicit safety rules remain necessary.',
  'Introduces a representative embedded benchmark suite. It offers workloads for planned evaluation, but its existence is not evidence that this proposed pass improves them.',
  'Studies how LLVM passes affect final executable size. It motivates measuring binary size separately because a narrower IR object need not yield a smaller executable.',
  'Surveys tools for reduced precision and their automation challenges. Many surveyed uses tolerate numerical error; this project targets exact integer behavior and therefore needs different acceptance rules.',
  'Analyzes false interactions caused by optimization phase ordering. It motivates comparing pass placement with SROA and related passes rather than treating pipeline order as irrelevant.',
  'Empirically studies optimization bugs in GCC and LLVM. It provides a correctness motivation, not a width-selection algorithm, and supports a strong rejection policy for uncertain cases.',
  'Improves compiler test generation by handling undefined behavior less conservatively. It informs adversarial test design, but generated tests cannot prove every rewrite correct.',
  'Combines value-range and bitmask analyses in high-level synthesis to reduce hardware resources. The combined facts are useful for width inference, but the evaluated target is an FPGA circuit.',
  'Builds a bit-flow graph for bit-level transformations in high-level synthesis and FPGA acceleration. It demonstrates fine-grained bit reasoning, while generated circuits have different storage constraints from LLVM software objects.',
  'Uses whole-program value and pointer analysis to pack globals, arrays, and structures for on-chip RAM. It directly motivates storage reduction, but its source-level compression and tradeoffs are broader than our conservative LLVM object rewrite.',
  'Uses inferred bitwidths to co-locate subword live values in registers. The result concerns register allocation, so it should not be counted as a demonstrated reduction in the bytes allocated for arrays or globals.',
  'Provides an exact polynomial-time solution for a bit-aware register-binding problem. It strengthens the evidence for width-sensitive target decisions, but addresses binding rather than LLVM memory-object layout.',
  'Selects per-variable widths with profile-guided speculation and compiler–architecture support. It explores performance beyond static proofs; our proposed pass will avoid speculation and preserve behavior through conservative analysis.',
  'Speculatively places subword values into register halves with an embedded-processor instruction-set extension. It reduces potential spills, but requires hardware support and targets registers rather than object representation.',
  'Includes bitwidth in high-level synthesis scheduling and binding decisions. It shows why target resource models matter, although its output is custom hardware rather than native LLVM object allocation.',
  'Propagates whether narrow computations are productive so useless work can be pruned speculatively. The target is computation pruning, not a proof that an entire stored object can change type.',
  'Compresses fields in dynamically allocated data structures using narrow-data and pointer representations, with processor support. It is relevant memory-compression prior art; heap fields are outside our initial scope.',
  'Uses the Alive framework to specify and prove local LLVM peephole optimizations. It offers a model for checking rewrite semantics, while a whole memory-object conversion needs additional pointer and layout reasoning.',
  'Uses randomized C programs to expose wrong-code compiler bugs. It motivates differential execution of baseline and transformed programs, while testing remains finite evidence rather than a universal proof.',
];
if(paperReviews.length!==papers.length) throw new Error('Literature review count mismatch');

const novelty = [
  '1  Complete array or private global is the width decision unit.',
  '2  Combine stored-value proof with every load and pointer use.',
  '3  Track zero-extension and sign-extension obligations separately.',
  '4  Require the complete target allocation to shrink.',
  '5  Use an explicit safe-use policy for each object class.',
  '6  Reject mixed signed/unsigned evidence rather than guess.',
  '7  Record a precise reason for every rejected candidate.',
  '8  Study pass placement alongside SROA and other LLVM passes.',
  '9  Separate IR width, target allocation, binary size, and runtime.',
  '10 Compare a safety-only pass with a target-size-gated variant.',
];
const slides = [
  {title:'Compiler Design · Review 1', lines:['Target-aware conservative width narrowing of LLVM memory objects','Research proposal · LLVM 18 · selected stack arrays and private globals'], notes:'Initial-stage proposal. No final-paper findings or measured project outcomes are used.'},
  {title:'Problem statement and technical idea', lines:['Wide integer types can reserve more storage than reachable values need.','Example: 100 i32 elements declare 400 bytes; i8 would declare 100 bytes if every value fits 0–255.','A smaller type is legal only if all stores, loads, pointer uses, and signedness semantics remain valid.','Proposed question: when can LLVM narrow a complete memory object safely and usefully?','A smaller IR type does not guarantee a smaller target allocation or faster code.'], notes:'The 400/100 byte example is arithmetic, not a project measurement. LLVM LangRef: https://llvm.org/docs/LangRef.html ; DataLayout: https://llvm.org/doxygen/classllvm_1_1DataLayout.html'},
  {title:'Objectives and initial scope', lines:['Infer a conservative smaller element width for selected integer arrays and internal/private globals.','Preserve observable values by proving the needed zero extension or sign extension after loads.','Reject escaping pointers, unknown stores, externally visible layouts, and volatile/atomic accesses.','Accept a rewrite only when the target reports a smaller complete-object allocation.','Evaluate correctness, candidate coverage, code size, and runtime against unchanged LLVM 18.','Initial scope excludes heap objects, structures, vector objects, and approximate precision.'], notes:'These are proposed objectives and scope boundaries, not completed results. LLVM semantics: https://llvm.org/docs/LangRef.html'},
  {title:'Existing system vs proposed work', comparison:true, notes:'Baseline: same LLVM 18 pipeline without the proposed pass. SROA description: https://llvm.org/docs/Passes.html ; KnownBits: https://llvm.org/doxygen/structllvm_1_1KnownBits.html'},
  {title:'Literature review · inferring required bits', paperRefs:[2,3,4,5,6,19,20], review:[
    'Cousot and Cousot [2] establish sound approximation; Wegman and Zadeck [3] use branch-sensitive propagation. These foundations explain why a smaller width must be proved across reachable paths.',
    'Bitwise [4] propagates width constraints forward and backward. BitValue [5] detects constant and unused bits. Both show that computation often carries redundant bits, chiefly in hardware-oriented settings.',
    'MiniBit [6] applies affine arithmetic to fixed-point circuits. Gort and Anderson [19] combine ranges with bitmasks; Zhang et al. [20] use a bit-flow graph for FPGA synthesis.',
    'Together, these works inform candidate width analysis. They do not by themselves establish when changing a complete LLVM array or global preserves pointer behavior and reduces allocated bytes.'
  ], notes:'Papers 1–10 remain provisional until the original survey is supplied.'},
  {title:'Literature review · changing storage', paperRefs:[10,11,14,15,21,28], review:[
    'Bhaskaracharya et al. [10] contract array storage through reuse across scheduled loops. Cooprider and Regehr [21] pack embedded RAM using whole-program analysis; Zhang and Gupta [28] compress heap fields.',
    'Heo et al. [11] is close prior art: an LLVM-based bit-usage analysis narrows selected memory accesses and computations for embedded processors. This rules out a broad claim of originating LLVM memory-width optimization.',
    'Jain et al. [14] examine executable-size effects of LLVM passes. Cherubin and Agosta [15] survey reduced-precision tools, including error-tolerant settings. Neither metric nor precision model can be transferred to exact integer storage unchanged.',
    'The project therefore tests a bounded question: safe whole-object element-width changes, exact load reconstruction, and a measured reduction in target allocation size.'
  ], notes:'Heo et al. (2025) is especially important close prior work; explain the proposed scope precisely.'},
  {title:'Literature review · widths and target resources', paperRefs:[7,8,9,22,23,24,25,26,27], review:[
    'Mahlke et al. [7] and Cong et al. [26] use bitwidth in accelerator synthesis. Lee et al. [8] guarantee fixed-point accuracy. These works optimize hardware area or bounded error rather than exact LLVM memory representation.',
    'Tallam and Gupta [22], Nandivada and Barik [9], and Canesche et al. [23] exploit narrow values in register allocation or binding. Register savings should not be reported as object-allocation savings.',
    'Li et al. [25] and BitSpec [24] add speculation or hardware support for narrow registers. Bhagat et al. [27] prune unproductive narrow computations; the proposed pass instead uses static proof before a memory rewrite.',
    'The common lesson is that bit savings depend on the target resource. The proposed DataLayout gate will test complete-object allocation, not infer physical savings from IR width alone.'
  ], notes:'Target-resource scope is the major comparison: registers and custom circuits versus native LLVM memory objects.'},
  {title:'Literature review · validation and evaluation', paperRefs:[1,12,13,16,17,18,29,30], review:[
    'LLVM [1] supplies the typed IR and pass framework. Alive [29] checks local rewrite rules; Alive2 [12] validates bounded LLVM IR translations. Object rewrites still require explicit pointer and layout reasoning.',
    'Zhou et al. [17] study optimization bugs. Csmith [30] and CsmithEdge [18] generate challenging compiler tests while addressing undefined behavior. These motivate negative cases and baseline-versus-transformed execution.',
    'Jantz and Kulkarni [16] show that pass order can matter. MiBench [13] supplies embedded workloads. A controlled experiment must hold the LLVM pipeline fixed and report cases that cannot be tested.',
    'The review supports four distinct evaluation claims: correctness, transformation coverage, target allocation, and downstream binary/runtime effects. None should be substituted for another.'
  ], notes:'The companion document gives method, contribution, and boundary for every one of the 30 papers.'},
  {title:'Research gap and proposed workflow', lines:['Width inference, RAM compression, narrow LLVM accesses, and compiler validation are established areas.','Heo et al. (2025) is close prior work; the claim is a narrower, testable integration question.','Select eligible complete objects → inspect stores/loads/pointers → prove width and extension rule.','Check the target DataLayout allocation → rewrite only profitable safe cases → verify and log rejections.','Study how many cases survive safety and target-size checks, and why others do not.'], notes:'Heo et al.: https://doi.org/10.1016/j.sysarc.2025.103546 ; target size: https://llvm.org/doxygen/classllvm_1_1DataLayout.html'},
  {title:'Ten proposed novelty points', novelty:true, notes:'These are ten planned design/evaluation differentiators, not ten independent invention claims. Prior work on width inference and narrow memory accesses is acknowledged.'},
  {title:'Validation plan and expected outcomes', lines:['Correctness: LLVM verifier, focused positive/negative IR tests, and differential execution.','Coverage: accepted widths, skipped objects, and reasons for rejection.','Resource evidence: report declared IR width and target allocation size separately.','Secondary evidence: executable size and runtime under identical baseline settings.','Expected deliverables: LLVM 18 prototype, reproducible test cases, and a bounded evaluation.','No speedup or universal memory saving is assumed; null results will be reported.'], notes:'Alive2: https://doi.org/10.1145/3453483.3454030 ; MiBench: https://doi.org/10.1109/WWC.2001.990739'},
  {title:'Review 1 plan and faculty questions', lines:['Now: reconcile the original ten papers and finish the 30-paper survey.','Next: implement candidate analysis, guarded rewrite, and IR verification.','Then: run controlled baseline comparisons and inspect rejected cases.','Likely question — Why not SROA? SROA promotes or splits; this study targets surviving object storage widths.','Likely question — Why might i32→i8 not help? Padding, alignment, and target lowering can remove the saving.','Likely question — What if safety cannot be proved? Keep the original object unchanged.'], notes:'The companion document contains the complete eleven-question faculty Q&A.'},
];
const reviewedNumbers=slides.filter(s=>s.paperRefs).flatMap(s=>s.paperRefs);
if(reviewedNumbers.length!==30 || new Set(reviewedNumbers).size!==30 || reviewedNumbers.some(n=>n<1||n>30)) throw new Error('Literature slides must cover each of 30 papers once');

const qa = [
  ['What is bitwidth narrowing?','Represent a value with fewer bits only when analysis proves all observable results remain the same.'],
  ['Why memory objects instead of only arithmetic instructions?','A smaller computation does not necessarily change the allocated array or global; the project studies that storage decision.'],
  ['How is this different from SROA?','SROA splits or promotes suitable stack aggregates. Our proposed decision is whether a selected remaining object can safely use a narrower integer element type.'],
  ['Is narrow memory access already studied?','Yes. Heo et al. (2025) is close prior work. We will compare scope and methods, especially complete-object size, signed reconstruction, and rejection policy.'],
  ['What happens if the pointer escapes?','The object stays unchanged because outside code may rely on its representation.'],
  ['How do signed values differ?','A narrow negative value must be restored with sign extension; nonnegative unsigned data uses zero extension. The pass must prove which is valid.'],
  ['Does i32 to i8 always save 75% of memory?','No. The bit count is a logical illustration; padding, alignment, target layout, and code generation determine actual allocation and performance.'],
  ['How will you check correctness?','Run the LLVM verifier, focused positive and negative IR tests, and differential execution against the unchanged baseline.'],
  ['What is the baseline?','The same Clang/LLVM 18 pipeline and workload, with the proposed pass disabled.'],
  ['What if no performance gain appears?','Report that result. Safety, coverage, target allocation changes, and the reasons a rewrite was rejected are still meaningful findings.'],
  ['Are all ten novelty points individually new?','No. They are defensible proposed design and evaluation differentiators; the study tests their combined value without a first-ever claim.'],
];

await fs.mkdir(buildDir, {recursive:true});
await fs.mkdir(outputDir, {recursive:true});
const font = resolvePresentationFont({fontFamily:'Aptos'});
const pres = Presentation.create({slideSize:{width:1280,height:720}});
const ink = '#142434', muted = '#426070', accent = '#006E74', bg = '#F8FAFA';
function addText(slide,text,x,y,w,h,size=22,color=ink,bold=false,face=font){
  const s=slide.shapes.add({geometry:'textbox',position:{left:x,top:y,width:w,height:h},fill:'none',line:{fill:'none',width:0}});
  s.text=text;
  s.text.style={typeface:face,fontSize:size,color,bold,autoFit:'shrinkText',verticalAlignment:'middle',wrap:true};
  return s;
}
function baseSlide(title,index,notes){
  const slide=pres.slides.add(); slide.background.fill=bg;
  addText(slide,title,70,44,1135,78,index===1?44:35,ink,true);
  addText(slide,String(index).padStart(2,'0'),1150,657,60,30,16,muted);
  slide.speakerNotes.textFrame.setText(notes||'');
  return slide;
}
for(let i=0;i<slides.length;i++){
  const d=slides[i], slide=baseSlide(d.title,i+1,d.notes);
  if(d.comparison){
    const table=slide.tables.add({rows:5,columns:3,left:70,top:145,width:1130,height:460,
      columnWidths:[190,425,515],values:[
        ['Decision','Existing LLVM baseline','Proposed study'],
        ['Decision unit','Scalar values and promotable allocas','Selected complete memory objects'],
        ['Width choice','General LLVM simplification','Proven stored range and bit facts'],
        ['Target rule','Normal target lowering','Explicit allocation-size gate'],
        ['Evidence','Standard compiler tests','Candidate log, IR checks, differential runs'],
      ]});
    table.styleOptions={headerRow:true};
    table.borders.assign({style:'solid',fill:'#C9D7D9',width:1});
    table.cells.block({row:0,column:0,rowCount:1,columnCount:3}).textStyle.bold=true;
    table.cells.block({row:0,column:0,rowCount:1,columnCount:3}).textStyle.color=accent;
    table.cells.block({row:0,column:0,rowCount:5,columnCount:3}).textStyle.fontSize=19;
    continue;
  }
  if(d.review){
    slide.speakerNotes.textFrame.setText(d.notes+'\n\n'+d.paperRefs.map(n=>{const p=papers[n-1];return `[${n}] ${p[0]} (${p[1]}). ${p[2]}. ${p[3]}. https://doi.org/${p[4]}\nReview: ${paperReviews[n-1]}`}).join('\n\n'));
    d.review.forEach((paragraph,j)=>addText(slide,paragraph,75,145+j*119,1110,106,19.4,j===3?accent:ink));
    if(i===4||i===5) addText(slide,'References 1–10 are provisional pending the original survey.',75,625,1000,28,13.5,muted);
    continue;
  }
  if(d.novelty){
    novelty.forEach((line,j)=>{
      const col=j>=5?1:0, row=j%5, x=75+col*565, y=149+row*91;
      addText(slide,line,x,y,525,83,18.4,row===0?accent:ink);
    });
    addText(slide,'Proposed combination and evaluation choices; no first-ever claim.',75,627,1000,28,14,muted);
    continue;
  }
  let y=i===0?280:146;
  const count=d.lines.length;
  const gap=i===0?94:Math.min(92,Math.floor(474/count));
  d.lines.forEach((line,j)=>{
    const isLast=i===0&&j===1;
    addText(slide,line,75,y+j*gap,1110,Math.min(gap-4,87),i===0?(j===0?29:21):(count>=6?20:21.5),isLast?muted:(j===0&&i!==0?accent:ink),i===0&&j===0);
  });
}

const md=[];
md.push('# Compiler Design · Review 1\n');
md.push('**Topic:** Target-aware conservative width narrowing of LLVM memory objects.');
md.push('**Stage:** Research proposal. All transformations, validation steps, and outcomes below are planned; no final result is presented.');
md.push('**Source-status note:** The separate ten-paper original survey has not yet been supplied. Papers 1–10 below are a provisional foundational set verified against academic records, not a claim about the contents of that survey. Replace/reconcile them when the original file arrives. Papers 11–30 are an independently checked expansion.\n');
md.push('## Recommended slide-by-slide structure and exact slide content\n');
slides.forEach((s,i)=>{
  md.push(`### Slide ${i+1} — ${s.title}\n`);
  if(s.review){s.review.forEach(paragraph=>md.push(paragraph+'\n'));md.push(`Papers discussed: ${s.paperRefs.map(n=>`[${n}]`).join(', ')}.`);}
  else if(s.comparison){md.push('| Decision | Existing LLVM baseline | Proposed study |','|---|---|---|','| Decision unit | Scalar values and promotable allocas | Selected complete memory objects |','| Width choice | General LLVM simplification | Proven stored range and bit facts |','| Target rule | Normal target lowering | Explicit allocation-size gate |','| Evidence | Standard compiler tests | Candidate log, IR checks, differential runs |');}
  else if(s.novelty){novelty.forEach(x=>md.push(`- ${x}`));}
  else s.lines.forEach(x=>md.push(`- ${x}`));
  md.push('');
});
md.push('## Complete 30-paper literature review\n');
md.push('Each entry states the paper’s method or evidence and its boundary relative to the proposed project. A boundary is a scope comparison, not a claim that the paper is deficient.\n');
papers.forEach((p,i)=>md.push(`${i+1}. **${p[0]} (${p[1]}). ${p[2]}.** ${p[3]}. [DOI](https://doi.org/${p[4]}). ${paperReviews[i]}${i===9?'\n\n**Papers 11–30: additional researched set.**':''}\n`));
md.push('## Research gap\n');
md.push('Published work demonstrates bitwidth inference, RAM compression, LLVM bit-usage optimization, and compiler validation. In particular, Heo et al. (2025) already studies narrow LLVM memory accesses, so a broad claim of first LLVM memory narrowing would be unsound. This project asks a narrower question: can an LLVM 18 pass safely change the element type of selected complete local arrays and internal/private globals, reconstruct signed or unsigned loads correctly, and require a real target allocation-size reduction? The evaluation will measure accepted and rejected cases under one controlled baseline.\n');
md.push('## Existing system\n');
md.push('The baseline is an unchanged Clang/LLVM 18 optimization pipeline. LLVM already performs scalar simplification and SROA for promotable stack aggregates. Existing value facts and register-level width techniques do not establish that each candidate complete array or private global can safely change storage type. The proposed pass will be compared with this baseline using identical inputs and settings.\n');
md.push('## Proposed work\n');
md.push('Select eligible objects; inspect stores, loads and pointer uses; derive a conservative width and extension rule; compare complete-object allocation sizes through `DataLayout`; rewrite only supported cases; verify IR and program output; log each rejection. Heap objects, externally visible ABI objects, volatile/atomic memory, and unsupported pointer uses are outside the initial scope.\n');
md.push('## Ten proposed novelty points\n');
novelty.forEach(x=>md.push(`- ${x}`));
md.push('\nThese are proposed design and evaluation differentiators. They are not ten independent claims of invention; several ingredients are established in prior work.\n');
md.push('## Expected outcomes\n');
slides[10].lines.slice(4).forEach(x=>md.push(`- ${x}`));
md.push('\n## Likely faculty questions and concise answers\n');
qa.forEach(([q,a],i)=>md.push(`${i+1}. **${q}** ${a}\n`));
md.push('## Key technical sources\n');
md.push('- [LLVM pass reference](https://llvm.org/docs/Passes.html)');
md.push('- [LLVM language reference](https://llvm.org/docs/LangRef.html)');
md.push('- [LLVM DataLayout allocation size](https://llvm.org/doxygen/classllvm_1_1DataLayout.html)');
md.push('- [LLVM KnownBits](https://llvm.org/doxygen/structllvm_1_1KnownBits.html)');
await fs.writeFile(reportPath,md.join('\n'),'utf8');

const stagingDir=path.join(workspaceDir,'.codex-finalizer');
await fs.mkdir(stagingDir,{recursive:true});
const candidatePath=path.join(stagingDir,'review1-candidate.pptx');
await (await PresentationFile.exportPptx(pres)).save(candidatePath);
const result=await finalizePresentation({
  workspaceDir,candidatePath,finalPath,
  pythonExecutable:RUNTIME_PYTHON,
  integrityValidatorPath:path.join(SKILL_DIR,'container_tools/inspect_presentation_package_integrity.py'),
  layoutValidatorPath:path.join(SKILL_DIR,'container_tools/inspect_presentation_layout_geometry.py'),
  layoutArgs:['--expected-slide-size-emu','12192000,6858000','--validate-heading-fit','--require-native-table-slide','4'],
  requiredNativeTableOwnerSlides:[4],
  fontPolicy:{basis:'design',families:[font]},
  verifyArtifactToolImport:true,
  receiptPath:path.join(stagingDir,'review1-validation-literature-review.json'),
});
console.log(JSON.stringify({slides:pres.slides.length,finalPath,reportPath,result},null,2));
