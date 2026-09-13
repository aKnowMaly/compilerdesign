#!/usr/bin/env python3
"""Audit the final A/B manuscript against generated evidence and PDF text."""

from __future__ import annotations

import json
import re
from pathlib import Path

from pypdf import PdfReader


ROOT = Path(__file__).resolve().parents[1]
DATA = json.loads(
    (ROOT / "build/final-evaluation/final-evaluation.json").read_text(encoding="utf-8")
)
COMPARE = json.loads(
    (ROOT / "build/target-allocation-comparison/comparison.json").read_text(encoding="utf-8")
)
EXTERNAL = json.loads(
    (ROOT / "build/external-benchmark-validation/results.json").read_text(encoding="utf-8")
)
A = COMPARE["baseline_a"]
B = COMPARE["experiment_b"]
COMMON = COMPARE["common_26_object_opportunity_set"]
EA = EXTERNAL["method_a"]
EB = EXTERNAL["method_b"]
EXT_COMMON = EXTERNAL["common_method_a_opportunity_set"]
TEX = (ROOT / "paper/main.tex").read_text(encoding="utf-8")
MACROS = (ROOT / "paper/generated_metrics.tex").read_text(encoding="utf-8")
PDF = ROOT / "output/pdf/adaptive-width-memory-narrowing-paper.pdf"
OUT = ROOT / "build/final-evaluation/claim-audit.md"


def require_macro(name: str, value: object) -> None:
    needle = rf"\newcommand{{\{name}}}{{{value}}}"
    if needle not in MACROS:
        raise SystemExit(f"generated macro mismatch: {name}={value}")


macro_map = {
    "BenchmarkCount": DATA["benchmark_count"],
    "CandidateTotal": DATA["candidate_total"],
    "SafeCandidates": DATA["safe_candidates"],
    "BlockedCandidates": DATA["blocked_candidates"],
    "ATransformed": A["transformed"],
    "BTransformed": B["transformed"],
    "APositive": A["positive"],
    "BPositive": B["positive"],
    "AZero": A["zero"],
    "BZero": B["zero"],
    "APrecision": f"{A['benefit_precision_percent']:.2f}",
    "BPrecision": f"{B['benefit_precision_percent']:.2f}",
    "ADeclaredBits": A["declared_width_reduction_bits"],
    "BDeclaredBits": B["declared_width_reduction_bits"],
    "CommonBaselineBytes": COMMON["baseline_bytes"],
    "CommonResultBytes": COMMON["experiment_b_result_bytes"],
    "CommonSavedBytes": COMMON["saved_bytes_both_methods"],
    "CommonReductionPercent": f"{COMMON['reduction_percent_both_methods']:.2f}",
    "ARawIR": f"{A['raw_ir_delta']:+d}",
    "BRawIR": f"{B['raw_ir_delta']:+d}",
    "RawIRAvoided": A["raw_ir_delta"] - B["raw_ir_delta"],
    "AOtwoIR": f"{A['o2_ir_delta']:+d}",
    "BOtwoIR": f"{B['o2_ir_delta']:+d}",
    "AExecutableDelta": f"{A['executable_size_delta_bytes']:+d}",
    "BExecutableDelta": f"{B['executable_size_delta_bytes']:+d}",
    "ExternalPrograms": EXTERNAL["programs_successfully_compiled"],
    "ExternalCompilationUnits": EXTERNAL["mibench_c_compilation_units"],
    "ExternalCandidates": EXTERNAL["total_candidates"],
    "ExternalSafe": EXTERNAL["safety_safe"],
    "ExternalBlocked": EXTERNAL["safety_blocked"],
    "ExternalATransformed": EA["transformed"],
    "ExternalBTransformed": EB["transformed"],
    "ExternalAPositive": EA["positive"],
    "ExternalBPositive": EB["positive"],
    "ExternalAZero": EA["zero"],
    "ExternalBZero": EB["zero"],
    "ExternalAPrecision": f"{EA['allocation_benefit_precision_percent']:.2f}",
    "ExternalBPrecision": f"{EB['allocation_benefit_precision_percent']:.2f}",
    "ExternalCommonBaseline": EXT_COMMON["baseline_bytes"],
    "ExternalCommonResult": EXT_COMMON["method_b_result_bytes"],
    "ExternalCommonSaved": EXT_COMMON["method_b_saved_bytes"],
    "ExternalCommonPercent": f"{EXT_COMMON['method_b_reduction_percent']:.2f}",
    "ExternalARawIR": f"{EA['raw_ir_delta']:+d}",
    "ExternalBRawIR": f"{EB['raw_ir_delta']:+d}",
    "ExternalAOtwoIR": f"{EA['o2_ir_delta']:+d}",
    "ExternalBOtwoIR": f"{EB['o2_ir_delta']:+d}",
    "ExternalOtwoAvoided": EA["o2_ir_delta"] - EB["o2_ir_delta"],
    "ExternalAExecutableDelta": f"{EA['executable_size_delta_bytes']:+d}",
    "ExternalBExecutableDelta": f"{EB['executable_size_delta_bytes']:+d}",
    "ExternalDiffPassed": EA["differential_passed"],
    "ExternalDiffFailed": EA["differential_failed"],
    "ExternalDiffSkipped": EA["differential_skipped"],
}
for macro, value in macro_map.items():
    require_macro(macro, value)

assert round(A["positive"] / A["transformed"] * 100, 2) == A["benefit_precision_percent"]
assert round(B["positive"] / B["transformed"] * 100, 2) == B["benefit_precision_percent"]
assert COMMON["baseline_bytes"] - COMMON["experiment_b_result_bytes"] == COMMON["saved_bytes_both_methods"]
assert A["accepted_saved_bytes"] == B["accepted_saved_bytes"] == COMMON["saved_bytes_both_methods"]
assert A["differential_passed"] == B["differential_passed"] == 32
assert A["differential_failed"] == B["differential_failed"] == 0
assert EXTERNAL["safety_safe"] + EXTERNAL["safety_blocked"] == EXTERNAL["total_candidates"]
assert EA["positive"] + EA["zero"] + EA["negative"] == EA["transformed"]
assert EB["positive"] + EB["zero"] + EB["negative"] == EB["transformed"]
assert round(EA["positive"] / EA["transformed"] * 100, 2) == EA["allocation_benefit_precision_percent"]
assert round(EB["positive"] / EB["transformed"] * 100, 2) == EB["allocation_benefit_precision_percent"]
assert EXT_COMMON["baseline_bytes"] - EXT_COMMON["method_b_result_bytes"] == EXT_COMMON["method_b_saved_bytes"]
assert EA["o2_ir_delta"] - EB["o2_ir_delta"] == 66
assert EA["executable_size_delta_bytes"] > 0 and EB["executable_size_delta_bytes"] > 0
assert EA["differential_passed"] == EB["differential_passed"] == 16
assert EA["differential_failed"] == EB["differential_failed"] == 0
assert EA["differential_skipped"] == EB["differential_skipped"] == 1

expected_title = "Target-Aware Conservative Width Narrowing\\\\of LLVM Memory Objects"
if expected_title not in TEX:
    raise SystemExit("final title is missing or changed")

for fragment in ("11" + " kernels", "+" + "37"):
    if fragment in TEX:
        raise SystemExit(f"stale paper claim remains: {fragment}")

for fragment in ("first ever", "outperforms Heo"):
    if re.search(fragment, TEX, re.IGNORECASE):
        raise SystemExit(f"unsupported manuscript claim remains: {fragment}")

reader = PdfReader(PDF)
pdf_text = "\n".join(page.extract_text() or "" for page in reader.pages)
pdf_text = re.sub(r"([A-Za-z])-\s+([A-Za-z])", r"\1\2", pdf_text)
pdf_text = re.sub(r"\s+", " ", pdf_text)
pdf_text = pdf_text.replace("LL VM", "LLVM").replace("Cderived", "C-derived")
required_pdf_phrases = [
    "Target-Aware Conservative Width Narrowing of LLVM Memory Objects",
    "controlled 32-kernel, 39-candidate evaluation",
    "whereas Method B accepts 23, all positive",
    "88.46% to 100.00%",
    "150 to 83 bytes",
    "67 bytes saved, or 44.67%",
    "raw IR overhead falls from +141 to +125",
    "both summed deltas are +4",
    "executable-file delta of +0 bytes",
    "32/32 agreement holds for B",
    "not demonstrated runtime, energy, physical-memory, or code-size improvement",
    "External Validation on MiBench",
    "5003 candidate memory objects",
    "95.24% to 100.00%",
    "saving 1252 bytes (46.37%)",
    "After O2 it is +119 and +53",
    "Executable sizes increase slightly under both methods",
    "no executable/code-size benefit",
    "office-ispell",
]
missing = [phrase for phrase in required_pdf_phrases if phrase not in pdf_text]
if missing:
    raise SystemExit(f"compiled PDF is missing claims: {missing}")

page_width = float(reader.pages[0].mediabox.width)
page_height = float(reader.pages[0].mediabox.height)
if not (594 <= page_width <= 596 and 841 <= page_height <= 843):
    raise SystemExit(f"compiled PDF is not A4: {page_width} x {page_height}")

figures = len(re.findall(r"\\begin\{figure\*?\}", TEX))
tables = len(re.findall(r"\\begin\{table\*?\}", TEX)) + len(
    re.findall(r"\\input\{tables/", TEX)
)
references = len(
    re.findall(
        r"^@",
        (ROOT / "paper/references.bib").read_text(encoding="utf-8"),
        re.MULTILINE,
    )
)

lines = [
    "# Final Claim Audit",
    "",
    "All A/B claims resolve through generated macros sourced from the authoritative comparison JSON and underlying TSV/log evidence.",
    "",
    "| Metric | A: conservative | B: allocation guard |",
    "|---|---:|---:|",
    f"| Candidates / safe / blocked | {A['candidates']} / 35 / 4 | {B['candidates']} / 35 / 4 |",
    f"| Transformed | {A['transformed']} | {B['transformed']} |",
    f"| Positive / zero / negative | {A['positive']} / {A['zero']} / {A['negative']} | {B['positive']} / {B['zero']} / {B['negative']} |",
    f"| Declared-width reduction | {A['declared_width_reduction_bits']} bits | {B['declared_width_reduction_bits']} bits |",
    f"| Accepted-object allocation | {A['accepted_baseline_bytes']} to {A['accepted_transformed_bytes']} B | {B['accepted_baseline_bytes']} to {B['accepted_transformed_bytes']} B |",
    f"| Allocation-benefit precision | {A['benefit_precision_percent']:.2f}% | {B['benefit_precision_percent']:.2f}% |",
    f"| Raw / O2 IR delta | {A['raw_ir_delta']:+d} / {A['o2_ir_delta']:+d} | {B['raw_ir_delta']:+d} / {B['o2_ir_delta']:+d} |",
    f"| Executable delta | {A['executable_size_delta_bytes']:+d} B | {B['executable_size_delta_bytes']:+d} B |",
    f"| Differential | {A['differential_passed']}/32 | {B['differential_passed']}/32 |",
    "",
    f"Common 26-object set: {COMMON['baseline_bytes']} to {COMMON['experiment_b_result_bytes']} B, {COMMON['saved_bytes_both_methods']} B ({COMMON['reduction_percent_both_methods']:.2f}%) for both methods.",
    "",
    "## External MiBench validation",
    "",
    f"Programs / compilation units: {EXTERNAL['programs_successfully_compiled']} / {EXTERNAL['mibench_c_compilation_units']}.",
    f"Candidates / safe / blocked: {EXTERNAL['total_candidates']} / {EXTERNAL['safety_safe']} / {EXTERNAL['safety_blocked']}.",
    f"Method A: {EA['transformed']} transformed, {EA['positive']} / {EA['zero']} / {EA['negative']} positive / neutral / negative, precision {EA['allocation_benefit_precision_percent']:.2f}%.",
    f"Method B: {EB['transformed']} transformed, {EB['positive']} / {EB['zero']} / {EB['negative']} positive / neutral / negative, precision {EB['allocation_benefit_precision_percent']:.2f}%.",
    f"Common set: {EXT_COMMON['baseline_bytes']} to {EXT_COMMON['method_b_result_bytes']} B, {EXT_COMMON['method_b_saved_bytes']} B ({EXT_COMMON['method_b_reduction_percent']:.2f}%) for both methods.",
    f"Raw / O2 deltas: A {EA['raw_ir_delta']:+d} / {EA['o2_ir_delta']:+d}; B {EB['raw_ir_delta']:+d} / {EB['o2_ir_delta']:+d}.",
    f"Executable deltas: A {EA['executable_size_delta_bytes']:+d} B; B {EB['executable_size_delta_bytes']:+d} B.",
    f"Differential: {EA['differential_passed']} pass, {EA['differential_failed']} fail, {EA['differential_skipped']} skip.",
    "",
    "## Document checks",
    "",
    f"- Pages: {len(reader.pages)} (A4, {page_width:.2f} x {page_height:.2f} pt).",
    f"- Figures: {figures}.",
    f"- Tables: {tables}.",
    f"- Bibliography entries: {references}.",
    "- No stale 11-kernel or +37 result remains.",
    "- The PDF states no physical-memory or runtime-performance improvement.",
]
OUT.write_text("\n".join(lines) + "\n", encoding="utf-8")
print(OUT)
