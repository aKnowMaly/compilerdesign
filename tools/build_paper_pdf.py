import csv
from pathlib import Path

from reportlab.lib import colors
from reportlab.lib.enums import TA_CENTER, TA_JUSTIFY, TA_LEFT
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import ParagraphStyle, getSampleStyleSheet
from reportlab.lib.units import inch
from reportlab.platypus import (
    KeepTogether,
    ListFlowable,
    ListItem,
    PageBreak,
    Paragraph,
    Preformatted,
    SimpleDocTemplate,
    Spacer,
    Table,
    TableStyle,
)


ROOT = Path(__file__).resolve().parents[1]
OUTPUT_DIR = ROOT / "output" / "pdf"
OUTPUT = OUTPUT_DIR / "adaptive-width-memory-narrowing-paper.pdf"


def para(text, style):
    return Paragraph(text, style)


def bullet_items(items, style):
    return ListFlowable(
        [ListItem(Paragraph(item, style), leftIndent=12) for item in items],
        bulletType="bullet",
        leftIndent=18,
    )


def numbered_items(items, style):
    return ListFlowable(
        [ListItem(Paragraph(item, style), leftIndent=12) for item in items],
        bulletType="1",
        leftIndent=18,
    )


def code(text, style):
    return Preformatted(text.strip(), style)


def make_table(data, widths):
    table = Table(data, colWidths=widths, repeatRows=1)
    table.setStyle(
        TableStyle(
            [
                ("FONTNAME", (0, 0), (-1, 0), "Helvetica-Bold"),
                ("FONTSIZE", (0, 0), (-1, -1), 7.6),
                ("ALIGN", (1, 0), (-1, -1), "RIGHT"),
                ("ALIGN", (0, 0), (0, -1), "LEFT"),
                ("BACKGROUND", (0, 0), (-1, 0), colors.HexColor("#e8eef7")),
                ("GRID", (0, 0), (-1, -1), 0.25, colors.HexColor("#9aa7b7")),
                ("ROWBACKGROUNDS", (0, 1), (-1, -2), [colors.white, colors.HexColor("#f7f9fc")]),
                ("BACKGROUND", (0, -1), (-1, -1), colors.HexColor("#edf6ed")),
                ("FONTNAME", (0, -1), (-1, -1), "Helvetica-Bold"),
                ("VALIGN", (0, 0), (-1, -1), "MIDDLE"),
                ("LEFTPADDING", (0, 0), (-1, -1), 3),
                ("RIGHTPADDING", (0, 0), (-1, -1), 3),
                ("TOPPADDING", (0, 0), (-1, -1), 3),
                ("BOTTOMPADDING", (0, 0), (-1, -1), 3),
            ]
        )
    )
    return table


def read_tsv(path):
    with path.open(newline="", encoding="utf-8") as handle:
        return list(csv.DictReader(handle, delimiter="\t"))


def fixture_table_from_report():
    rows = read_tsv(ROOT / "build" / "research-evaluation" / "adaptive-width-report.tsv")
    table = [["Input", "Cand.", "Safe", "Blocked", "Unknown", "Trans. G", "Trans. A", "Loads", "Bits"]]
    totals = [0] * 8
    for row in rows:
        values = [
            int(row["candidate_globals"]) + int(row["candidate_allocas"]),
            int(row["safe"]),
            int(row["blocked"]),
            int(row["unknown_width"]),
            int(row["transformed_globals"]),
            int(row["transformed_allocas"]),
            int(row["loads_rewritten"]),
            int(row["bits_saved_per_element"]),
        ]
        totals = [a + b for a, b in zip(totals, values)]
        table.append([row["input"], *values])
    table.append(["Total", *totals])
    return table, totals


def benchmark_table_from_report():
    rows = read_tsv(ROOT / "build" / "benchmark-metrics" / "benchmark-metrics.tsv")
    table = [["Benchmark", "Cand.", "Safe", "Blocked", "Trans.", "RW", "Raw d", "O2 d", "Bits"]]
    totals = [0] * 8
    for row in rows:
        values = [
            int(row["candidate_globals"]) + int(row["candidate_allocas"]),
            int(row["safe"]),
            int(row["blocked"]),
            int(row["transformed_globals"]) + int(row["transformed_allocas"]),
            int(row["loads_rewritten"]) + int(row["stores_rewritten"]),
            int(row["ir_instruction_delta"]),
            int(row["optimized_ir_instruction_delta"]),
            int(row["bits_saved_per_element"]),
        ]
        totals = [a + b for a, b in zip(totals, values)]
        table.append([row["benchmark"], values[0], values[1], values[2], values[3], values[4], f"{values[5]:+d}", f"{values[6]:+d}", values[7]])
    table.append(["Total", totals[0], totals[1], totals[2], totals[3], totals[4], f"{totals[5]:+d}", f"{totals[6]:+d}", totals[7]])
    return table, totals, len(rows)


def runtime_summary():
    report = ROOT / "build" / "runtime-differential" / "runtime-differential.tsv"
    if not report.exists():
        return 0, 0, 0
    rows = read_tsv(report)
    passed = sum(1 for row in rows if row["status"] == "PASS")
    failed = sum(1 for row in rows if row["status"] != "PASS")
    return len(rows), passed, failed


def header_footer(canvas, doc):
    canvas.saveState()
    canvas.setFont("Helvetica", 8)
    canvas.setFillColor(colors.HexColor("#4b5563"))
    canvas.drawString(doc.leftMargin, 0.45 * inch, "Adaptive Bit-Width Memory Narrowing - Artifact Draft")
    canvas.drawRightString(A4[0] - doc.rightMargin, 0.45 * inch, f"Page {doc.page}")
    canvas.restoreState()


def build():
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    fixture_table, fixture_totals = fixture_table_from_report()
    bench_table, bench_totals, benchmark_count = benchmark_table_from_report()
    runtime_total, runtime_passed, runtime_failed = runtime_summary()

    doc = SimpleDocTemplate(
        str(OUTPUT),
        pagesize=A4,
        rightMargin=0.6 * inch,
        leftMargin=0.6 * inch,
        topMargin=0.55 * inch,
        bottomMargin=0.7 * inch,
        title="Conservative Adaptive Bit-Width Narrowing for LLVM Memory Objects",
        author="AdaptiveWidthMemoryPass Artifact",
    )

    styles = getSampleStyleSheet()
    styles.add(
        ParagraphStyle(
            name="TitleCenter",
            parent=styles["Title"],
            alignment=TA_CENTER,
            fontName="Helvetica-Bold",
            fontSize=18,
            leading=22,
            spaceAfter=8,
        )
    )
    styles.add(
        ParagraphStyle(
            name="Subtitle",
            parent=styles["Normal"],
            alignment=TA_CENTER,
            fontSize=9,
            textColor=colors.HexColor("#4b5563"),
            spaceAfter=16,
        )
    )
    styles.add(
        ParagraphStyle(
            name="Section",
            parent=styles["Heading2"],
            fontName="Helvetica-Bold",
            fontSize=12,
            leading=14,
            spaceBefore=12,
            spaceAfter=6,
            textColor=colors.HexColor("#1f2937"),
        )
    )
    styles.add(
        ParagraphStyle(
            name="BodyJustify",
            parent=styles["BodyText"],
            alignment=TA_JUSTIFY,
            fontName="Times-Roman",
            fontSize=9.2,
            leading=11.2,
            spaceAfter=5,
        )
    )
    styles.add(
        ParagraphStyle(
            name="Small",
            parent=styles["BodyText"],
            alignment=TA_LEFT,
            fontName="Times-Roman",
            fontSize=8.4,
            leading=10.2,
            spaceAfter=4,
        )
    )
    styles.add(
        ParagraphStyle(
            name="LLVMCode",
            parent=styles["Code"],
            fontName="Courier",
            fontSize=7.8,
            leading=9.2,
            leftIndent=6,
            rightIndent=6,
            backColor=colors.HexColor("#f4f6f8"),
            borderColor=colors.HexColor("#cbd5e1"),
            borderWidth=0.25,
            borderPadding=5,
            spaceBefore=4,
            spaceAfter=6,
        )
    )
    styles.add(
        ParagraphStyle(
            name="Caption",
            parent=styles["BodyText"],
            fontName="Helvetica-Oblique",
            fontSize=8,
            leading=9.5,
            alignment=TA_CENTER,
            textColor=colors.HexColor("#374151"),
            spaceBefore=4,
            spaceAfter=8,
        )
    )

    body = styles["BodyJustify"]
    small = styles["Small"]
    section = styles["Section"]
    story = []

    story.append(para("Conservative Adaptive Bit-Width Narrowing for LLVM Memory Objects", styles["TitleCenter"]))
    story.append(para("AdaptiveWidthMemoryPass Artifact Draft - Generated PDF", styles["Subtitle"]))

    story.append(para(f"<b>Abstract.</b> Integer values stored in memory often occupy fewer significant bits than their declared source-level type. While scalar integer narrowing is a familiar compiler optimization theme, narrowing memory objects is more delicate because the transformation must preserve load/store semantics, pointer use structure, and signedness restoration. This paper presents a conservative LLVM New Pass Manager prototype, <i>AdaptiveWidthMemoryPass</i>, that narrows selected local stack arrays and internal/private globals when all observed stores can be classified by local bit-width inference. The pass rewrites memory object element types, truncates stores, and restores narrowed loads with either zero-extension or sign-extension according to a tracked extension family. Unsupported pointer uses, mixed signed/unsigned value families, and unknown stored values are rejected rather than speculated on. On the current fixture corpus, the prototype identifies {fixture_totals[0]} memory-object candidates, transforms {fixture_totals[4] + fixture_totals[5]} of them, and records a static summed per-element width reduction of {fixture_totals[7]} bits. On {benchmark_count} C-derived kernels, it transforms {bench_totals[3]} memory-object candidates and exposes the expected tradeoff between narrower memory and additional cast instructions.", body))

    story.append(para("1. Introduction", section))
    story.append(para("Many programs store values in integer containers wider than the value range required at a particular program point. Examples include masked counters, small enumerations, byte-derived values stored in 16- or 32-bit arrays, and sign-extended offsets later stored in wider integer memory. Narrowing such memory objects can reduce static storage width and may enable downstream optimizations. However, memory narrowing is more constrained than scalar narrowing: every load and store must be rewritten consistently, pointer uses may escape, and signedness-sensitive values must be restored with the correct extension operation.", body))
    story.append(para("This work develops a small, inspectable LLVM pass that prioritizes correctness and reproducibility over broad coverage. The prototype narrows only integer arrays allocated on the stack and internal/private integer globals. It accepts only direct pointer uses through getelementptr, load, and store. It performs local stored-value inference over constants, casts, masks, simple select/phi/or compositions, and LLVM KnownBits information. If a candidate cannot be proven safe and profitable under these rules, it is left unchanged and reported with a reason.", body))
    story.append(bullet_items([
        "a conservative memory-object narrowing transformation for LLVM IR;",
        "an explicit extension-family safety policy for zero- and sign-restored loads;",
        "deterministic candidate classification and rejection logging;",
        "a reproducible metrics harness that reports coverage, transformation counts, width deltas, and IR overhead.",
    ], small))

    story.append(para("2. Motivation", section))
    story.append(para("A local array whose stored values are masked before every store may not require its declared element width. The pass can replace a 16-bit array with a five-bit array, truncate stores, and zero-extend loads back to the original type.", body))
    story.append(code("""
arr = alloca [2 x i16]
masked = and i16 x, 31
store i16 masked, ptr slot
v = load i16, ptr slot

; after narrowing
arr.narrow = alloca [2 x i5]
masked.narrow = trunc i16 masked to i5
store i5 masked.narrow, ptr slot.narrow
v.narrow = load i5, ptr slot.narrow
v.wide = zext i5 v.narrow to i16
""", styles["LLVMCode"]))
    story.append(para("For signed byte-derived values, zero-extension is not equivalent. Therefore the prototype tracks whether the stored-value family must be restored by zext or sext. A candidate containing a mixture of both families is rejected.", body))

    story.append(para("3. Safety Model", section))
    story.append(para("Let a candidate memory object have original element type iN and proposed narrow element type iK where K < N. The transformation is allowed only if the memory object is a supported stack array or internal/private global, all pointer users are recursively limited to supported GEP/load/store operations, every store has an inferred width at most K, every stored value agrees on one extension family, and the candidate is profitable.", body))
    story.append(para("The local preservation condition is: extend_E(trunc_K(v)) = v for each stored value v that may be loaded from the object. The current implementation checks this condition through syntactic and KnownBits-based inference rules rather than whole-program analysis. If inference fails, the candidate is treated as unknown and is not transformed.", body))
    story.append(para("Invariant and Preservation Sketch", section))
    story.append(para("For every transformed object O, every value stored through a supported pointer path to O belongs to one inferred extension family E and has representable width at most K, the new element width. Because all admitted loads and stores are rewritten through the same rebuilt pointer graph, each transformed load observes a value previously stored in truncated form. Since inference requires extend_E(trunc_K(v)) = v for every admitted stored value, restoring the narrowed load with E preserves the original loaded value. Escaping pointers, unsupported casts, aggregate loads, volatile/atomic behavior, unknown values, and mixed extension families are rejected before rewriting.", body))

    story.append(para("4. Algorithm and Implementation", section))
    story.append(para("The pass is implemented as an LLVM 18 New Pass Manager plugin. It exposes full analysis/transformation, log-only analysis, stack-allocation-only transformation, and global-only transformation pipelines. Candidate discovery scans functions for local stack integer arrays and the module for internal/private integer globals. Scalar allocas, floating-point objects, external globals, aggregate loads, and pointer escapes are rejected.", body))
    story.append(para("The inference engine computes a required bit width and extension family for stored values. It recognizes integer constants, truncation including C-style trunc(and i32 %x, mask) forms, zero-extension and sign-extension chains, constant masks, bitwise OR, select and bounded phi nodes when all arms agree, and LLVM KnownBits as a conservative fallback. For compositions such as select, phi, and OR, operands must agree on the same extension family.", body))
    story.append(para("For a profitable candidate, the pass creates a replacement memory object with the narrowed integer element type. It rebuilds GEPs using the new source element type, rewrites stores by truncating stored values to the new type, rewrites loads from the new type, and extends loaded values back to the original type.", body))

    story.append(para("Transformation Algorithm", section))
    story.append(code("""
for object O in stack_arrays + internal_globals:
  if not integer_memory_object(O):
    reject(O, "non-integer")
    continue
  U = collect_supported_pointer_uses(O)
  if U has escaping or unsupported users:
    reject(O, "unsupported-user")
    continue
  W, E = infer_width_and_extension(stores(O))
  if inference failed:
    reject(O, "unknown-width")
    continue
  if W >= original_element_width(O):
    reject(O, "not-profitable")
    continue
  O2 = create_narrow_object(O, W)
  rewrite_geps_loads_stores(O, O2, E)
  erase_dead_old_ir(O)
""", styles["LLVMCode"]))

    story.append(para("Pass Architecture", section))
    story.append(para("The implementation separates candidate discovery, recursive pointer-use classification, width and extension-family inference, and IR rewriting. The metrics harness consumes the same deterministic log output used by the tests, so paper tables are generated from the artifact rather than manually transcribed.", body))
    arch = [
        ["Discover\nallocas/globals", "Validate Uses\nGEP/load/store", "Infer Width\nbits + zext/sext", "Rewrite IR\nnarrow memory", "Verify\nLLVM IR"],
    ]
    arch_table = Table(arch, colWidths=[1.3 * inch] * 5)
    arch_table.setStyle(TableStyle([
        ("BACKGROUND", (0, 0), (-1, -1), colors.HexColor("#eef4ff")),
        ("GRID", (0, 0), (-1, -1), 0.7, colors.HexColor("#4169a8")),
        ("FONTNAME", (0, 0), (-1, -1), "Helvetica-Bold"),
        ("FONTSIZE", (0, 0), (-1, -1), 8),
        ("ALIGN", (0, 0), (-1, -1), "CENTER"),
        ("VALIGN", (0, 0), (-1, -1), "MIDDLE"),
        ("TOPPADDING", (0, 0), (-1, -1), 8),
        ("BOTTOMPADDING", (0, 0), (-1, -1), 8),
    ]))
    story.append(KeepTogether([
        arch_table,
        para("Figure 1. Pass architecture. Unsupported, unknown, or unprofitable candidates are logged and left unchanged.", styles["Caption"]),
    ]))

    story.append(para("5. Evaluation Methodology", section))
    story.append(para("The artifact includes three evaluation layers. Fixture-level tests exercise individual transformation and rejection behaviors. A benchmark-metrics harness compiles small C kernels to LLVM IR with Clang 18, applies a light mem2reg normalization step to remove irrelevant scalar spills, runs the pass, verifies transformed IR, and emits tab-separated and Markdown results. Runtime differential harnesses compile baseline and transformed benchmark executables and compare deterministic checksum outputs. Metrics include candidate counts, safety classifications, transformed globals and allocas, rewritten loads and stores, static summed per-element bit savings, LLVM IR instruction-count delta before and after LLVM default O2, and coarse process-level pass wall time.", body))

    story.append(KeepTogether([
        make_table(fixture_table, [1.45 * inch, 0.45 * inch, 0.45 * inch, 0.55 * inch, 0.58 * inch, 0.55 * inch, 0.55 * inch, 0.45 * inch, 0.45 * inch]),
        para("Table 1. Fixture-level evaluation summary. Bit savings are static per-element width deltas, not measured runtime footprint reductions.", styles["Caption"]),
    ]))

    story.append(KeepTogether([
        make_table(bench_table, [1.45 * inch, 0.42 * inch, 0.42 * inch, 0.52 * inch, 0.48 * inch, 0.42 * inch, 0.46 * inch, 0.55 * inch, 0.42 * inch]),
        para("Table 2. C-kernel benchmark metrics. Raw delta is measured immediately after rewriting; O2 delta is measured after LLVM default O2 on baseline and transformed IR.", styles["Caption"]),
    ]))

    story.append(para("6. Results", section))
    story.append(para(f"Across seven fixture inputs, the pass identifies {fixture_totals[0]} candidates. It classifies {fixture_totals[1]} as safe under the pointer-use policy and transforms {fixture_totals[4] + fixture_totals[5]} total memory objects: {fixture_totals[4]} globals and {fixture_totals[5]} stack arrays. The fixture corpus intentionally includes unknown-width and escaped-pointer cases; these account for the {fixture_totals[2]} blocked candidates and {fixture_totals[3]} unknown-width classifications. The resulting static summed per-element width delta is {fixture_totals[7]} bits.", body))
    story.append(para(f"The C-kernel benchmark snapshot demonstrates the intended behaviors at source-derived IR level. The suite includes unsigned mask extraction, pixel-channel packing, packet flag decoding, signed offsets, global constants, select-based ranges, and deliberate rejection cases. Across {benchmark_count} kernels, the pass sees {bench_totals[0]} memory-object candidates, classifies {bench_totals[1]} as safe under the use policy, and transforms {bench_totals[3]} objects. The transformed C kernels increase raw static IR instruction count by {bench_totals[5]} assignments because the pass inserts explicit truncation and extension instructions; after LLVM default O2 this overhead falls to {bench_totals[6]} assignments.", body))
    if runtime_total:
        story.append(para(f"Runtime differential testing compiles baseline and transformed versions of all {runtime_total} benchmark harnesses and compares deterministic checksum outputs. The current run reports {runtime_passed} passing comparisons and {runtime_failed} failures. This does not replace formal proof or large input-space testing, but it strengthens the artifact-level behavioral evidence for the current benchmark suite.", body))

    story.append(para("7. Limitations", section))
    story.append(para("The current prototype does not handle arbitrary pointer aliasing, external globals, scalar allocas, bitcast/address-space-cast rewrite cases, aggregate loads, volatile or atomic semantics, interprocedural effects, or broad arithmetic range inference. The current evaluation uses small fixtures and kernels rather than external benchmark suites. Therefore the reported numbers establish correctness and reproducibility of the artifact, not general application-level memory or performance improvements.", body))

    story.append(para("8. Related Work", section))
    story.append(para("The implementation builds on LLVM's modular pass infrastructure and uses LLVM IR semantics as the transformation target. Its inference style is related to classic data-flow and abstract-interpretation ideas, and to compiler propagation analyses such as conditional constant propagation. The use of LLVM KnownBits connects the prototype to existing value-tracking infrastructure. Unlike scalar-only simplifications, this work focuses specifically on narrowing memory object element types while preserving load/store behavior.", body))

    story.append(para("9. Future Work", section))
    story.append(para("Future work should scale the metrics harness to larger benchmark suites, measure optimized machine-code effects after downstream LLVM passes, support additional safe pointer-use patterns, extend arithmetic range inference, and add runtime differential testing for transformed kernels. Another important direction is comparing memory-object narrowing against scalar bit-width optimizations to determine when memory rewriting provides unique benefits.", body))

    story.append(para("10. Conclusion", section))
    story.append(para("This draft presented a conservative LLVM prototype for adaptive bit-width narrowing of selected memory objects. The pass combines local stored-value inference, explicit signedness restoration, conservative pointer-use filtering, and deterministic reporting. The current results show that the implementation can safely transform targeted fixture and C-derived kernels while preserving a clear rejection policy. The artifact is now positioned for broader benchmark evaluation and iterative paper development.", body))

    story.append(PageBreak())
    story.append(para("References", section))
    story.append(numbered_items([
        "Chris Lattner and Vikram Adve. LLVM: A Compilation Framework for Lifelong Program Analysis and Transformation. CGO, 2004.",
        "Patrick Cousot and Radhia Cousot. Abstract Interpretation: A Unified Lattice Model for Static Analysis of Programs by Construction or Approximation of Fixpoints. POPL, 1977.",
        "Mark N. Wegman and F. Kenneth Zadeck. Constant Propagation with Conditional Branches. ACM TOPLAS, 1991.",
        "LLVM Project. LLVM Language Reference Manual and ValueTracking/KnownBits infrastructure documentation.",
    ], small))

    doc.build(story, onFirstPage=header_footer, onLaterPages=header_footer)
    print(OUTPUT)


if __name__ == "__main__":
    build()
