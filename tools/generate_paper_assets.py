#!/usr/bin/env python3
"""Generate evidence-backed vector figures and compact LaTeX tables."""

from __future__ import annotations

import csv
import json
from collections import Counter, defaultdict
from pathlib import Path

from reportlab.lib import colors
from reportlab.pdfgen import canvas


ROOT = Path(__file__).resolve().parents[1]
EVAL = ROOT / "build/final-evaluation/final-evaluation.json"
BENCH = ROOT / "build/benchmark-metrics/benchmark-metrics.tsv"
WIDTHS = ROOT / "build/final-evaluation/transformed-widths.tsv"
COMPARE = ROOT / "build/target-allocation-comparison/comparison.json"
COMPARE_CATEGORIES = ROOT / "build/target-allocation-comparison/categories.tsv"
EXTERNAL = ROOT / "build/external-benchmark-validation/results.json"
FIG = ROOT / "paper/figures"
TAB = ROOT / "paper/tables"
NAVY = colors.HexColor("#17365D")
BLUE = colors.HexColor("#4F81BD")
LIGHT = colors.HexColor("#D9E4F2")
GRAY = colors.HexColor("#666666")
RED = colors.HexColor("#A23E48")


def read_tsv(path: Path) -> list[dict[str, str]]:
    with path.open(encoding="utf-8", newline="") as stream:
        return list(csv.DictReader(stream, delimiter="\t"))


def finish(c: canvas.Canvas, title: str) -> None:
    c.setTitle(title)
    c.showPage()
    c.save()


def architecture() -> None:
    path = FIG / "pass_architecture.pdf"
    width, height = 468, 145
    c = canvas.Canvas(str(path), pagesize=(width, height))
    c.setLineWidth(0.8)

    def arrow(x1: float, y1: float, x2: float, y2: float, color=GRAY) -> None:
        c.setStrokeColor(color)
        c.line(x1, y1, x2, y2)
        c.line(x2 - 5, y2 + 4, x2, y2)
        c.line(x2 - 5, y2 - 4, x2, y2)

    top = [
        (3, 108, 90, "LLVM Module"),
        (103, 108, 100, "Candidate Detection"),
        (213, 108, 112, "Static Value / Bit Analysis"),
        (335, 108, 130, "Width + Extension Inference"),
    ]
    for i in range(3):
        x, y, w, _ = top[i]
        nx, ny, _, _ = top[i + 1]
        arrow(x + w, y + 12, nx - 3, ny + 12)
    bottom = [
        (3, 45, 86, "Safety Check"),
        (98, 45, 88, "DataLayout Guard"),
        (195, 45, 82, "Memory Narrowing"),
        (286, 45, 86, "Load / Store Rebuild"),
        (381, 45, 84, "LLVM O2 / Code Gen"),
    ]
    # Wrap from width inference to the lower acceptance sequence.
    c.setStrokeColor(GRAY)
    c.line(400, 108, 400, 88)
    c.line(400, 88, 46, 88)
    c.line(46, 88, 46, 72)
    c.line(42, 77, 46, 72)
    c.line(50, 77, 46, 72)
    for i in range(4):
        x, y, w, _ = bottom[i]
        nx, ny, _, _ = bottom[i + 1]
        arrow(x + w, y + 12, nx - 3, ny + 12)

    # Explicit and independent rejection paths.
    c.setStrokeColor(RED)
    for x in (46, 142):
        c.line(x, 45, x, 21)
        c.line(x - 4, 26, x, 21)
        c.line(x + 4, 26, x, 21)
    c.setFillColor(RED)
    c.setFont("Times-Bold", 7.4)
    c.drawCentredString(46, 8, "Reject unsafe")
    c.drawCentredString(142, 8, "Reject neutral")

    for x, y, w, label in top + bottom:
        c.setFillColor(
            LIGHT
            if label not in {"Safety Check", "DataLayout Guard"}
            else colors.HexColor("#FFF2CC")
        )
        c.setStrokeColor(NAVY)
        c.roundRect(x, y, w, 24, 4, fill=1, stroke=1)
        c.setFillColor(colors.black)
        c.setFont(
            "Times-Bold"
            if label in {"LLVM Module", "Safety Check", "DataLayout Guard"}
            else "Times-Roman",
            7.1,
        )
        c.drawCentredString(x + w / 2, y + 8.5, label)
    finish(c, "AdaptiveWidthMemoryPass architecture")


def bar_chart(path: Path, title: str, labels: list[str], values: list[int], color=BLUE, highlight_last=True) -> None:
    width, height = 225, 150
    c = canvas.Canvas(str(path), pagesize=(width, height))
    c.setFont("Times-Bold", 10)
    c.setFillColor(NAVY)
    c.drawString(8, height - 14, title)
    left, bottom, chart_w, chart_h = 34, 28, 182, 98
    top = max(values) if values else 1
    top = max(top, 1)
    gap = chart_w / max(len(values), 1)
    c.setStrokeColor(colors.HexColor("#BBBBBB"))
    c.line(left, bottom, left + chart_w, bottom)
    for i, (label, value) in enumerate(zip(labels, values)):
        bw = gap * 0.58
        x = left + i * gap + gap * 0.21
        h = chart_h * value / top
        c.setFillColor(RED if highlight_last and i == len(values) - 1 else color)
        c.rect(x, bottom, bw, h, fill=1, stroke=0)
        c.setFillColor(colors.black)
        c.setFont("Times-Bold", 8)
        c.drawCentredString(x + bw / 2, bottom + h + 3, str(value))
        c.saveState()
        c.translate(x + bw / 2 + 2, bottom - 4)
        c.rotate(35)
        c.setFont("Times-Roman", 7.2)
        c.drawRightString(0, 0, label)
        c.restoreState()
    finish(c, title)


def width_distribution(width_rows: list[dict[str, str]]) -> None:
    counts = Counter(
        int(row["declared_width_reduction_bits"]) for row in width_rows
    )
    labels = [str(value) for value in sorted(counts)]
    values = [counts[int(label)] for label in labels]
    bar_chart(
        FIG / "width_reduction_distribution.pdf",
        "Per-object width reductions",
        labels,
        values,
        highlight_last=False,
    )


def category_chart(bench: list[dict[str, str]]) -> None:
    inputs = Counter(row["category"] for row in bench)
    transformed = defaultdict(int)
    for row in bench:
        transformed[row["category"]] += int(row["transformed_globals"]) + int(row["transformed_allocas"])
    ordered = sorted(inputs, key=lambda key: (-inputs[key], key))
    width, height = 225, 182
    c = canvas.Canvas(str(FIG / "category_distribution.pdf"), pagesize=(width, height))
    c.setFillColor(NAVY)
    c.setFont("Times-Bold", 10)
    c.drawString(8, height - 14, "Benchmark categories and transformations")
    left, right, top, row_h = 83, 215, height - 30, 16
    max_value = max(inputs.values())
    for i, category in enumerate(ordered):
        y = top - i * row_h
        c.setFillColor(colors.black)
        c.setFont("Times-Roman", 7.6)
        c.drawRightString(left - 5, y + 2, category.replace("_", " "))
        total_w = (right - left) * inputs[category] / max_value
        trans_w = (right - left) * transformed[category] / max_value
        c.setFillColor(LIGHT)
        c.rect(left, y, total_w, 8, fill=1, stroke=0)
        c.setFillColor(BLUE)
        c.rect(left, y, trans_w, 8, fill=1, stroke=0)
        c.setFillColor(colors.black)
        c.setFont("Times-Roman", 7)
        c.drawString(left + total_w + 3, y + 1, f"{inputs[category]} / {transformed[category]}")
    c.setFont("Times-Italic", 7)
    c.setFillColor(GRAY)
    c.drawString(8, 8, "Light: kernels; blue: transformed objects (counts use separate concepts).")
    finish(c, "Benchmark category distribution")


def artifact_effects(data: dict[str, object]) -> None:
    width, height = 225, 150
    c = canvas.Canvas(str(FIG / "artifact_effects.pdf"), pagesize=(width, height))
    c.setFillColor(NAVY)
    c.setFont("Times-Bold", 10)
    c.drawString(8, height - 14, "Generated-artifact effects")
    c.setFont("Times-Bold", 9)
    c.setFillColor(colors.black)
    c.drawString(12, 112, "LLVM IR assignment delta")
    raw = int(data["raw_ir_instruction_delta"])
    o2 = int(data["o2_ir_instruction_delta"])
    scale = 125 / max(abs(raw), abs(o2), 1)
    for idx, (label, value) in enumerate((("Raw", raw), ("After O2", o2))):
        y = 91 - idx * 25
        c.setFillColor(BLUE)
        c.rect(63, y, value * scale, 10, fill=1, stroke=0)
        c.setFillColor(colors.black)
        c.setFont("Times-Roman", 8)
        c.drawRightString(57, y + 2, label)
        c.drawString(67 + value * scale, y + 2, f"{value:+d}")
    base = int(data["baseline_binary_bytes_sum"])
    trans = int(data["transformed_binary_bytes_sum"])
    delta = int(data["binary_size_delta_bytes_sum"])
    c.setFillColor(colors.black)
    c.setFont("Times-Bold", 9)
    c.drawString(12, 43, "Summed host executable sizes")
    c.setFont("Times-Roman", 8)
    c.drawString(12, 29, f"Baseline: {base:,} B   Transformed: {trans:,} B")
    c.drawString(12, 16, f"Delta: {delta:+,} B ({float(data['binary_size_delta_percent']):+.3f}%)")
    finish(c, "Generated artifact effects")


def allocation_by_category(data: dict[str, object]) -> None:
    categories = data["data_layout_allocation_by_category"]
    ordered = sorted(
        categories,
        key=lambda key: (-categories[key]["reduction_percent"], key),
    )
    width, height = 225, 170
    c = canvas.Canvas(
        str(FIG / "allocation_by_category.pdf"), pagesize=(width, height)
    )
    c.setFillColor(NAVY)
    c.setFont("Times-Bold", 10)
    c.drawString(8, height - 14, "DataLayout allocation reduction")
    left, right, top, row_h = 82, 190, height - 32, 17
    for i, category in enumerate(ordered):
        value = float(categories[category]["reduction_percent"])
        y = top - i * row_h
        c.setFillColor(colors.black)
        c.setFont("Times-Roman", 7.5)
        c.drawRightString(left - 5, y + 2, category.replace("_", " "))
        c.setFillColor(LIGHT)
        c.rect(left, y, right - left, 8, fill=1, stroke=0)
        c.setFillColor(BLUE)
        c.rect(left, y, (right - left) * value / 50.0, 8, fill=1, stroke=0)
        c.setFillColor(colors.black)
        c.setFont("Times-Roman", 7)
        c.drawString(right + 4, y + 1, f"{value:.2f}%")
    c.setFillColor(GRAY)
    c.setFont("Times-Italic", 7)
    c.drawString(8, 8, "Complete object types; x86-64 module DataLayout.")
    finish(c, "DataLayout allocation reduction by category")


def ab_selection(comparison: dict[str, object]) -> None:
    a = comparison["baseline_a"]
    b = comparison["experiment_b"]
    width, height = 225, 160
    c = canvas.Canvas(str(FIG / "ab_selection.pdf"), pagesize=(width, height))
    c.setFillColor(NAVY)
    c.setFont("Times-Bold", 10)
    c.drawString(8, height - 14, "A/B transformation selection")
    groups = [
        ("Accepted", int(a["transformed"]), int(b["transformed"])),
        ("Beneficial", int(a["positive"]), int(b["positive"])),
        ("Neutral", int(a["zero"]), int(b["zero"])),
    ]
    left, bottom, chart_w, chart_h = 33, 31, 182, 100
    c.setStrokeColor(colors.HexColor("#BBBBBB"))
    c.line(left, bottom, left + chart_w, bottom)
    top = max(value for _, av, bv in groups for value in (av, bv))
    gap = chart_w / len(groups)
    for i, (label, av, bv) in enumerate(groups):
        base_x = left + i * gap + 8
        for j, (value, color) in enumerate(((av, GRAY), (bv, BLUE))):
            x = base_x + j * 18
            h = chart_h * value / top
            c.setFillColor(color)
            c.rect(x, bottom, 14, h, fill=1, stroke=0)
            c.setFillColor(colors.black)
            c.setFont("Times-Bold", 7.5)
            c.drawCentredString(x + 7, bottom + h + 3, str(value))
        c.setFont("Times-Roman", 7.5)
        c.drawCentredString(base_x + 16, bottom - 11, label)
    c.setFont("Times-Italic", 7)
    c.setFillColor(GRAY)
    c.drawString(8, 8, "Gray: A original conservative; blue: B target-aware guard.")
    finish(c, "Controlled A/B transformation selection")


def ab_ir_effects(comparison: dict[str, object]) -> None:
    a = comparison["baseline_a"]
    b = comparison["experiment_b"]
    width, height = 225, 145
    c = canvas.Canvas(str(FIG / "ab_ir_effects.pdf"), pagesize=(width, height))
    c.setFillColor(NAVY)
    c.setFont("Times-Bold", 10)
    c.drawString(8, height - 14, "IR overhead in the controlled A/B test")
    pairs = [
        ("Raw IR", int(a["raw_ir_delta"]), int(b["raw_ir_delta"])),
        ("After O2", int(a["o2_ir_delta"]), int(b["o2_ir_delta"])),
    ]
    left, top, max_w = 57, 105, 145
    maximum = max(value for _, av, bv in pairs for value in (av, bv))
    for i, (label, av, bv) in enumerate(pairs):
        y = top - i * 43
        c.setFillColor(colors.black)
        c.setFont("Times-Roman", 8)
        c.drawRightString(left - 5, y + 2, label)
        for j, (value, color, tag) in enumerate(
            ((av, GRAY, "A"), (bv, BLUE, "B"))
        ):
            yy = y - j * 13
            c.setFillColor(color)
            c.rect(left, yy, max_w * value / maximum, 9, fill=1, stroke=0)
            c.setFillColor(colors.black)
            c.setFont("Times-Roman", 7)
            c.drawString(left + max_w * value / maximum + 3, yy + 1, f"{tag} {value:+d}")
    c.setFont("Times-Italic", 7)
    c.setFillColor(GRAY)
    c.drawString(8, 8, "No runtime-speed inference; counts are static LLVM IR assignments.")
    finish(c, "Controlled A/B IR effects")


def tex_escape(value: str) -> str:
    return value.replace("_", r"\_")


def tables(
    data: dict[str, object],
    bench: list[dict[str, str]],
    widths: list[dict[str, str]],
    comparison: dict[str, object],
    comparison_categories: list[dict[str, str]],
    external: dict[str, object],
) -> None:
    a = comparison["baseline_a"]
    b = comparison["experiment_b"]
    common = comparison["common_26_object_opportunity_set"]
    ext_a = external["method_a"]
    ext_b = external["method_b"]
    ext_common = external["common_method_a_opportunity_set"]
    ext_units = int(external["mibench_c_compilation_units"])
    macros = f"""% Generated from build/final-evaluation/final-evaluation.json. Do not edit.
\\newcommand{{\\BenchmarkCount}}{{{data['benchmark_count']}}}
\\newcommand{{\\CandidateGlobals}}{{{data['candidate_globals']}}}
\\newcommand{{\\CandidateAllocas}}{{{data['candidate_allocas']}}}
\\newcommand{{\\CandidateTotal}}{{{data['candidate_total']}}}
\\newcommand{{\\SafeCandidates}}{{{data['safe_candidates']}}}
\\newcommand{{\\BlockedCandidates}}{{{data['blocked_candidates']}}}
\\newcommand{{\\TransformedGlobals}}{{{data['transformed_globals']}}}
\\newcommand{{\\TransformedAllocas}}{{{data['transformed_allocas']}}}
\\newcommand{{\\TransformedTotal}}{{{data['transformed_total']}}}
\\newcommand{{\\StaticReductionSum}}{{{data['static_per_element_width_reduction_bits_sum']}}}
\\newcommand{{\\StaticReductionMean}}{{{float(data['static_per_element_width_reduction_bits_mean']):.2f}}}
\\newcommand{{\\StaticReductionMedian}}{{{float(data['static_per_element_width_reduction_bits_median']):.2f}}}
\\newcommand{{\\AllocationBaselineBytes}}{{{data['data_layout_allocation_baseline_bytes']}}}
\\newcommand{{\\AllocationTransformedBytes}}{{{data['data_layout_allocation_transformed_bytes']}}}
\\newcommand{{\\AllocationReductionBytes}}{{{data['data_layout_allocation_reduction_bytes']}}}
\\newcommand{{\\AllocationReductionPercent}}{{{float(data['data_layout_allocation_reduction_percent']):.2f}}}
\\newcommand{{\\AllocationMeanBytes}}{{{float(data['data_layout_mean_object_reduction_bytes']):.2f}}}
\\newcommand{{\\AllocationMedianBytes}}{{{float(data['data_layout_median_object_reduction_bytes']):.2f}}}
\\newcommand{{\\AllocationMeanPercent}}{{{float(data['data_layout_mean_object_reduction_percent']):.2f}}}
\\newcommand{{\\AllocationMedianPercent}}{{{float(data['data_layout_median_object_reduction_percent']):.2f}}}
\\newcommand{{\\AllocationPositive}}{{{data['data_layout_positive_reductions']}}}
\\newcommand{{\\AllocationZero}}{{{data['data_layout_zero_reductions']}}}
\\newcommand{{\\AllocationNegative}}{{{data['data_layout_negative_reductions']}}}
\\newcommand{{\\AllocaAllocationBaseline}}{{{data['data_layout_allocation_by_kind']['alloca']['baseline_bytes']}}}
\\newcommand{{\\AllocaAllocationTransformed}}{{{data['data_layout_allocation_by_kind']['alloca']['transformed_bytes']}}}
\\newcommand{{\\AllocaAllocationReduction}}{{{data['data_layout_allocation_by_kind']['alloca']['reduction_bytes']}}}
\\newcommand{{\\AllocaAllocationPercent}}{{{float(data['data_layout_allocation_by_kind']['alloca']['reduction_percent']):.2f}}}
\\newcommand{{\\GlobalAllocationBaseline}}{{{data['data_layout_allocation_by_kind']['global']['baseline_bytes']}}}
\\newcommand{{\\GlobalAllocationTransformed}}{{{data['data_layout_allocation_by_kind']['global']['transformed_bytes']}}}
\\newcommand{{\\GlobalAllocationReduction}}{{{data['data_layout_allocation_by_kind']['global']['reduction_bytes']}}}
\\newcommand{{\\GlobalAllocationPercent}}{{{float(data['data_layout_allocation_by_kind']['global']['reduction_percent']):.2f}}}
\\newcommand{{\\RawIRDelta}}{{{int(data['raw_ir_instruction_delta']):+d}}}
\\newcommand{{\\OtwoIRDelta}}{{{int(data['o2_ir_instruction_delta']):+d}}}
\\newcommand{{\\RuntimeTotal}}{{{data['runtime_differential_total']}}}
\\newcommand{{\\RuntimePassed}}{{{data['runtime_differential_passed']}}}
\\newcommand{{\\RuntimeFailed}}{{{data['runtime_differential_failed']}}}
\\newcommand{{\\BaselineBinaryBytes}}{{{data['baseline_binary_bytes_sum']}}}
\\newcommand{{\\TransformedBinaryBytes}}{{{data['transformed_binary_bytes_sum']}}}
\\newcommand{{\\BinaryDeltaBytes}}{{{int(data['binary_size_delta_bytes_sum']):+d}}}
\\newcommand{{\\BinaryDeltaPercent}}{{{float(data['binary_size_delta_percent']):+.3f}}}
\\newcommand{{\\PassWallMean}}{{{float(data['pass_process_wall_ms_mean']):.2f}}}
\\newcommand{{\\PassWallMedian}}{{{float(data['pass_process_wall_ms_median']):.2f}}}
\\newcommand{{\\ATransformed}}{{{a['transformed']}}}
\\newcommand{{\\BTransformed}}{{{b['transformed']}}}
\\newcommand{{\\APositive}}{{{a['positive']}}}
\\newcommand{{\\BPositive}}{{{b['positive']}}}
\\newcommand{{\\AZero}}{{{a['zero']}}}
\\newcommand{{\\BZero}}{{{b['zero']}}}
\\newcommand{{\\ANegative}}{{{a['negative']}}}
\\newcommand{{\\BNegative}}{{{b['negative']}}}
\\newcommand{{\\ADeclaredBits}}{{{a['declared_width_reduction_bits']}}}
\\newcommand{{\\BDeclaredBits}}{{{b['declared_width_reduction_bits']}}}
\\newcommand{{\\APrecision}}{{{float(a['benefit_precision_percent']):.2f}}}
\\newcommand{{\\BPrecision}}{{{float(b['benefit_precision_percent']):.2f}}}
\\newcommand{{\\ARawIR}}{{{int(a['raw_ir_delta']):+d}}}
\\newcommand{{\\BRawIR}}{{{int(b['raw_ir_delta']):+d}}}
\\newcommand{{\\RawIRAvoided}}{{{int(a['raw_ir_delta']) - int(b['raw_ir_delta'])}}}
\\newcommand{{\\AOtwoIR}}{{{int(a['o2_ir_delta']):+d}}}
\\newcommand{{\\BOtwoIR}}{{{int(b['o2_ir_delta']):+d}}}
\\newcommand{{\\AExecutableDelta}}{{{int(a['executable_size_delta_bytes']):+d}}}
\\newcommand{{\\BExecutableDelta}}{{{int(b['executable_size_delta_bytes']):+d}}}
\\newcommand{{\\CommonBaselineBytes}}{{{common['baseline_bytes']}}}
\\newcommand{{\\CommonResultBytes}}{{{common['experiment_b_result_bytes']}}}
\\newcommand{{\\CommonSavedBytes}}{{{common['saved_bytes_both_methods']}}}
\\newcommand{{\\CommonReductionPercent}}{{{float(common['reduction_percent_both_methods']):.2f}}}
\\newcommand{{\\ExternalPrograms}}{{{external['programs_successfully_compiled']}}}
\\newcommand{{\\ExternalCompilationUnits}}{{{ext_units}}}
\\newcommand{{\\ExternalCandidates}}{{{external['total_candidates']}}}
\\newcommand{{\\ExternalSafe}}{{{external['safety_safe']}}}
\\newcommand{{\\ExternalBlocked}}{{{external['safety_blocked']}}}
\\newcommand{{\\ExternalATransformed}}{{{ext_a['transformed']}}}
\\newcommand{{\\ExternalBTransformed}}{{{ext_b['transformed']}}}
\\newcommand{{\\ExternalAPositive}}{{{ext_a['positive']}}}
\\newcommand{{\\ExternalBPositive}}{{{ext_b['positive']}}}
\\newcommand{{\\ExternalAZero}}{{{ext_a['zero']}}}
\\newcommand{{\\ExternalBZero}}{{{ext_b['zero']}}}
\\newcommand{{\\ExternalANegative}}{{{ext_a['negative']}}}
\\newcommand{{\\ExternalBNegative}}{{{ext_b['negative']}}}
\\newcommand{{\\ExternalAPrecision}}{{{float(ext_a['allocation_benefit_precision_percent']):.2f}}}
\\newcommand{{\\ExternalBPrecision}}{{{float(ext_b['allocation_benefit_precision_percent']):.2f}}}
\\newcommand{{\\ExternalCommonBaseline}}{{{ext_common['baseline_bytes']}}}
\\newcommand{{\\ExternalCommonResult}}{{{ext_common['method_b_result_bytes']}}}
\\newcommand{{\\ExternalCommonSaved}}{{{ext_common['method_b_saved_bytes']}}}
\\newcommand{{\\ExternalCommonPercent}}{{{float(ext_common['method_b_reduction_percent']):.2f}}}
\\newcommand{{\\ExternalAcceptedBBaseline}}{{{ext_b['baseline_allocation_bytes']}}}
\\newcommand{{\\ExternalAcceptedBResult}}{{{ext_b['transformed_allocation_bytes']}}}
\\newcommand{{\\ExternalAcceptedBPercent}}{{{float(ext_b['allocation_reduction_percent']):.2f}}}
\\newcommand{{\\ExternalARawIR}}{{{int(ext_a['raw_ir_delta']):+d}}}
\\newcommand{{\\ExternalBRawIR}}{{{int(ext_b['raw_ir_delta']):+d}}}
\\newcommand{{\\ExternalAOtwoIR}}{{{int(ext_a['o2_ir_delta']):+d}}}
\\newcommand{{\\ExternalBOtwoIR}}{{{int(ext_b['o2_ir_delta']):+d}}}
\\newcommand{{\\ExternalOtwoAvoided}}{{{int(ext_a['o2_ir_delta']) - int(ext_b['o2_ir_delta'])}}}
\\newcommand{{\\ExternalOtwoAvoidedPercent}}{{{100.0 * (int(ext_a['o2_ir_delta']) - int(ext_b['o2_ir_delta'])) / int(ext_a['o2_ir_delta']):.1f}}}
\\newcommand{{\\ExternalAExecutableDelta}}{{{int(ext_a['executable_size_delta_bytes']):+d}}}
\\newcommand{{\\ExternalBExecutableDelta}}{{{int(ext_b['executable_size_delta_bytes']):+d}}}
\\newcommand{{\\ExternalDiffPassed}}{{{ext_a['differential_passed']}}}
\\newcommand{{\\ExternalDiffFailed}}{{{ext_a['differential_failed']}}}
\\newcommand{{\\ExternalDiffSkipped}}{{{ext_a['differential_skipped']}}}
"""
    (ROOT / "paper/generated_metrics.tex").write_text(macros, encoding="utf-8")
    category_inputs = Counter(row["category"] for row in bench)
    category_candidates = defaultdict(int)
    category_transformed = defaultdict(int)
    for row in bench:
        category_candidates[row["category"]] += int(row["candidate_globals"]) + int(row["candidate_allocas"])
        category_transformed[row["category"]] += int(row["transformed_globals"]) + int(row["transformed_allocas"])
    rows = "\n".join(
        f"{tex_escape(category)} & {category_inputs[category]} & {category_candidates[category]} & {category_transformed[category]} \\\\"
        for category in sorted(category_inputs)
    )
    (TAB / "benchmark_categories.tex").write_text(
        """\\begin{table}[t]
\\centering
\\caption{Method A benchmark-suite composition. Candidate and transformed-object counts may exceed kernel counts.}
\\label{tab:categories}
\\small
\\begin{tabular}{lrrr}
\\toprule
Category & Kernels & Cand. & Trans. \\\\
\\midrule
""" + rows + "\n\\bottomrule\n\\end{tabular}\n\\end{table}\n",
        encoding="utf-8",
    )
    coverage = f"""\\begin{{table}}[t]
\\centering
\\caption{{Final transformation coverage from the authoritative benchmark snapshot.}}
\\label{{tab:coverage}}
\\small
\\begin{{tabular}}{{lr}}
\\toprule
Measure & Count \\\\
\\midrule
Candidate globals & {data['candidate_globals']} \\\\
Candidate allocas & {data['candidate_allocas']} \\\\
All candidates & {data['candidate_total']} \\\\
Pointer-use checks passed & {data['safe_candidates']} \\\\
Rejected candidates & {data['blocked_candidates']} \\\\
Transformed globals & {data['transformed_globals']} \\\\
Transformed allocas & {data['transformed_allocas']} \\\\
All transformed objects & {data['transformed_total']} \\\\
\\bottomrule
\\end{{tabular}}
\\end{{table}}
"""
    (TAB / "coverage.tex").write_text(coverage, encoding="utf-8")
    width_stats = f"""\\begin{{table}}[t]
\\centering
\\caption{{Method A static declared-element width reduction. These values are not measured runtime memory savings.}}
\\label{{tab:width}}
\\small
\\begin{{tabular}}{{lr}}
\\toprule
Statistic & Bits \\\\
\\midrule
Summed per-element reduction & {data['static_per_element_width_reduction_bits_sum']} \\\\
Mean per transformed object & {float(data['static_per_element_width_reduction_bits_mean']):.2f} \\\\
Median per transformed object & {float(data['static_per_element_width_reduction_bits_median']):.2f} \\\\
\\bottomrule
\\end{{tabular}}
\\end{{table}}
"""
    (TAB / "width_stats.tex").write_text(width_stats, encoding="utf-8")
    transitions = Counter(
        (int(row["original_bits"]), int(row["transformed_bits"]))
        for row in widths
    )
    transition_rows = "\n".join(
        f"{original} & {transformed} & {original - transformed} & {count} \\\\"
        for (original, transformed), count in sorted(transitions.items())
    )
    width_transitions = """\\begin{table}[t]
\\centering
\\caption{Method A integer element-width transitions. Counts are transformed objects.}
\\label{tab:width-transitions}
\\small
\\begin{tabular}{rrrr}
\\toprule
Original & Transformed & Reduced & Objects \\\\
\\midrule
""" + transition_rows + "\n\\bottomrule\n\\end{tabular}\n\\end{table}\n"
    (TAB / "width_transitions.tex").write_text(
        width_transitions, encoding="utf-8"
    )
    allocation_summary = f"""\\begin{{table}}[t]
\\centering
\\caption{{Target-specific DataLayout-derived allocation effects over complete transformed object types.}}
\\label{{tab:allocation-summary}}
\\small
\\begin{{tabular}}{{lr}}
\\toprule
Measure & Value \\\\
\\midrule
Transformed objects & {data['transformed_total']} \\\\
Baseline allocation & {data['data_layout_allocation_baseline_bytes']} B \\\\
Transformed allocation & {data['data_layout_allocation_transformed_bytes']} B \\\\
Allocation reduction & {data['data_layout_allocation_reduction_bytes']} B ({float(data['data_layout_allocation_reduction_percent']):.2f}\\%) \\\\
Mean object reduction & {float(data['data_layout_mean_object_reduction_bytes']):.2f} B; {float(data['data_layout_mean_object_reduction_percent']):.2f}\\% \\\\
Median object reduction & {float(data['data_layout_median_object_reduction_bytes']):.2f} B; {float(data['data_layout_median_object_reduction_percent']):.2f}\\% \\\\
Positive / zero / negative & {data['data_layout_positive_reductions']} / {data['data_layout_zero_reductions']} / {data['data_layout_negative_reductions']} \\\\
\\bottomrule
\\end{{tabular}}
\\end{{table}}
"""
    (TAB / "allocation_summary.tex").write_text(
        allocation_summary, encoding="utf-8"
    )

    category_data = data["data_layout_allocation_by_category"]
    category_rows = "\n".join(
        f"{tex_escape(category)} & {values['objects']} & {values['baseline_bytes']} & "
        f"{values['transformed_bytes']} & {values['reduction_bytes']} & "
        f"{float(values['reduction_percent']):.2f}\\% \\\\"
        for category, values in category_data.items()
    )
    allocation_categories = """\\begin{table*}[t]
\\centering
\\caption{DataLayout-derived allocation results by benchmark category. Bytes are summed over transformed objects only.}
\\label{tab:allocation-categories}
\\small
\\begin{tabular}{lrrrrr}
\\toprule
Category & Objects & Baseline B & Transformed B & Saved B & Reduction \\\\
\\midrule
""" + category_rows + "\n\\bottomrule\n\\end{tabular}\n\\end{table*}\n"
    (TAB / "allocation_categories.tex").write_text(
        allocation_categories, encoding="utf-8"
    )
    artifact = f"""\\begin{{table}}[t]
\\centering
\\caption{{LLVM IR and host generated-artifact effects. Executable sizes are summed across kernels.}}
\\label{{tab:artifacts}}
\\small
\\begin{{tabular}}{{lr}}
\\toprule
Measure & Result \\\\
\\midrule
Raw IR instruction delta & {int(data['raw_ir_instruction_delta']):+d} \\\\
O2 IR instruction delta & {int(data['o2_ir_instruction_delta']):+d} \\\\
Baseline executable bytes & {int(data['baseline_binary_bytes_sum']):,} \\\\
Transformed executable bytes & {int(data['transformed_binary_bytes_sum']):,} \\\\
Executable-size delta & {int(data['binary_size_delta_bytes_sum']):+,} B ({float(data['binary_size_delta_percent']):+.3f}\\%) \\\\
Mean pass-process wall time & {float(data['pass_process_wall_ms_mean']):.2f} ms \\\\
\\bottomrule
\\end{{tabular}}
\\end{{table}}
"""
    (TAB / "artifact_effects.tex").write_text(artifact, encoding="utf-8")
    runtime = f"""\\begin{{table}}[t]
\\centering
\\caption{{Deterministic runtime differential validation.}}
\\label{{tab:runtime}}
\\small
\\begin{{tabular}}{{lr}}
\\toprule
Measure & Count \\\\
\\midrule
Comparisons & {data['runtime_differential_total']} \\\\
Passed & {data['runtime_differential_passed']} \\\\
Failed & {data['runtime_differential_failed']} \\\\
\\bottomrule
\\end{{tabular}}
\\end{{table}}
"""
    (TAB / "runtime.tex").write_text(runtime, encoding="utf-8")

    ab_table = f"""\\begin{{table*}}[t]
\\centering
\\caption{{Controlled A/B evaluation. Accepted-allocation percentages use each method's accepted objects; the common-set result is identical.}}
\\label{{tab:ab}}
\\small
\\begin{{tabular}}{{lrr}}
\\toprule
Metric & A: conservative & B: + allocation guard \\\\
\\midrule
Candidates / use-pass / use-blocked & {a['candidates']} / {data['safe_candidates']} / {data['blocked_candidates']} & {b['candidates']} / {data['safe_candidates']} / {data['blocked_candidates']} \\\\
Transformed objects & {a['transformed']} & {b['transformed']} \\\\
Positive / zero / negative & {a['positive']} / {a['zero']} / {a['negative']} & {b['positive']} / {b['zero']} / {b['negative']} \\\\
Declared-width reduction & {a['declared_width_reduction_bits']} bits & {b['declared_width_reduction_bits']} bits \\\\
Accepted-object allocation & {a['accepted_baseline_bytes']} $\\rightarrow$ {a['accepted_transformed_bytes']} B & {b['accepted_baseline_bytes']} $\\rightarrow$ {b['accepted_transformed_bytes']} B \\\\
Accepted-object saving & {a['accepted_saved_bytes']} B ({float(a['accepted_reduction_percent']):.2f}\\%) & {b['accepted_saved_bytes']} B ({float(b['accepted_reduction_percent']):.2f}\\%) \\\\
Allocation-benefit precision & {float(a['benefit_precision_percent']):.2f}\\% & {float(b['benefit_precision_percent']):.2f}\\% \\\\
Raw / O2 IR delta & {int(a['raw_ir_delta']):+d} / {int(a['o2_ir_delta']):+d} & {int(b['raw_ir_delta']):+d} / {int(b['o2_ir_delta']):+d} \\\\
Executable-size delta & {int(a['executable_size_delta_bytes']):+d} B & {int(b['executable_size_delta_bytes']):+d} B \\\\
Differential agreement & {a['differential_passed']}/32 & {b['differential_passed']}/32 \\\\
\\bottomrule
\\end{{tabular}}
\\end{{table*}}
"""
    (TAB / "ab_comparison.tex").write_text(ab_table, encoding="utf-8")

    by_method = defaultdict(dict)
    for row in comparison_categories:
        by_method[row["method"]][row["category"]] = row
    category_rows = []
    for category in sorted(by_method["A_current_conservative"]):
        ar = by_method["A_current_conservative"][category]
        br = by_method["B_target_allocation_guard"].get(category)
        if br is None:
            continue
        category_rows.append(
            f"{tex_escape(category)} & {ar['objects']} & {br['objects']} & "
            f"{float(ar['benefit_precision_percent']):.2f}\\% & "
            f"{float(br['benefit_precision_percent']):.2f}\\% \\\\"
        )
    ab_categories = """\\begin{table}[t]
\\centering
\\caption{Category-level transformation count and allocation-benefit precision.}
\\label{tab:ab-categories}
\\scriptsize
\\begin{tabular}{@{}lrrrr@{}}
\\toprule
Category & A n & B n & A positive & B positive \\\\
\\midrule
""" + "\n".join(category_rows) + "\n\\bottomrule\n\\end{tabular}\n\\end{table}\n"
    (TAB / "ab_categories.tex").write_text(ab_categories, encoding="utf-8")

    external_table = rf"""\begin{{table*}}[t]
\centering
\caption{{External validation on {external['programs_successfully_compiled']} MiBench programs. Allocation is compared on Method A's common opportunity set; accepted-set percentages have different denominators.}}
\label{{tab:external-mibench}}
\small
\setlength{{\tabcolsep}}{{5pt}}
\begin{{tabular}}{{lrr}}
\toprule
Metric & A: conservative & B: + allocation guard \\
\midrule
Candidates / use-pass / use-blocked & {external['total_candidates']} / {external['safety_safe']} / {external['safety_blocked']} & {external['total_candidates']} / {external['safety_safe']} / {external['safety_blocked']} \\
Transformed objects & {ext_a['transformed']} & {ext_b['transformed']} \\
Positive / neutral / negative & {ext_a['positive']} / {ext_a['zero']} / {ext_a['negative']} & {ext_b['positive']} / {ext_b['zero']} / {ext_b['negative']} \\
Allocation-benefit precision & {float(ext_a['allocation_benefit_precision_percent']):.2f}\% & {float(ext_b['allocation_benefit_precision_percent']):.2f}\% \\
Common-set allocation & {ext_common['baseline_bytes']} $\rightarrow$ {ext_common['method_a_result_bytes']} B & {ext_common['baseline_bytes']} $\rightarrow$ {ext_common['method_b_result_bytes']} B \\
Common-set saving & {ext_common['method_a_saved_bytes']} B ({float(ext_common['method_a_reduction_percent']):.2f}\%) & {ext_common['method_b_saved_bytes']} B ({float(ext_common['method_b_reduction_percent']):.2f}\%) \\
Raw / O2 IR assignment delta & {int(ext_a['raw_ir_delta']):+d} / {int(ext_a['o2_ir_delta']):+d} & {int(ext_b['raw_ir_delta']):+d} / {int(ext_b['o2_ir_delta']):+d} \\
Executable-size delta & {int(ext_a['executable_size_delta_bytes']):+d} B & {int(ext_b['executable_size_delta_bytes']):+d} B \\
Differential pass / fail / skip & {ext_a['differential_passed']} / {ext_a['differential_failed']} / {ext_a['differential_skipped']} & {ext_b['differential_passed']} / {ext_b['differential_failed']} / {ext_b['differential_skipped']} \\
\bottomrule
\end{{tabular}}
\end{{table*}}
"""
    (TAB / "external_mibench.tex").write_text(external_table, encoding="utf-8")


def main() -> None:
    from generate_width_choice_assets import generate
    from generate_expanded_corpus_assets import generate as generate_expanded
    FIG.mkdir(parents=True, exist_ok=True)
    TAB.mkdir(parents=True, exist_ok=True)
    data = json.loads(EVAL.read_text(encoding="utf-8"))
    comparison = json.loads(COMPARE.read_text(encoding="utf-8"))
    external = json.loads(EXTERNAL.read_text(encoding="utf-8"))
    comparison_categories = read_tsv(COMPARE_CATEGORIES)
    bench = read_tsv(BENCH)
    widths = read_tsv(WIDTHS)
    architecture()
    bar_chart(
        FIG / "transformation_coverage.pdf",
        "Transformation coverage",
        ["Candidates", "Safe", "Transformed", "Rejected"],
        [
            int(data["candidate_total"]),
            int(data["safe_candidates"]),
            int(data["transformed_total"]),
            int(data["blocked_candidates"]),
        ],
    )
    width_distribution(widths)
    category_chart(bench)
    artifact_effects(data)
    allocation_by_category(data)
    ab_selection(comparison)
    ab_ir_effects(comparison)
    tables(data, bench, widths, comparison, comparison_categories, external)
    generate()
    generate_expanded()
    print(FIG)
    print(TAB)


if __name__ == "__main__":
    main()
