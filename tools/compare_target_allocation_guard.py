#!/usr/bin/env python3
"""Compare the frozen pass with the isolated DataLayout benefit guard."""

from __future__ import annotations

import csv
import json
import re
from collections import Counter
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
BASE_DIR = ROOT / "build/final-evaluation"
GUARD_DIR = ROOT / "build/target-allocation-guard"
GUARD_RUNTIME_DIR = ROOT / "build/target-allocation-guard-runtime"
OUT_DIR = ROOT / "build/target-allocation-comparison"


def read_tsv(path: Path) -> list[dict[str, str]]:
    if not path.exists():
        raise SystemExit(f"missing experiment evidence: {path}")
    with path.open(encoding="utf-8", newline="") as stream:
        return list(csv.DictReader(stream, delimiter="\t"))


def write_tsv(path: Path, rows: list[dict[str, object]]) -> None:
    with path.open("w", encoding="utf-8", newline="") as stream:
        writer = csv.DictWriter(
            stream,
            fieldnames=list(rows[0]) if rows else [],
            delimiter="\t",
            lineterminator="\n",
        )
        if rows:
            writer.writeheader()
            writer.writerows(rows)


def summarize_allocations(rows: list[dict[str, str]]) -> dict[str, object]:
    baseline = sum(int(row["baseline_allocation_bytes"]) for row in rows)
    transformed = sum(int(row["transformed_allocation_bytes"]) for row in rows)
    reductions = [int(row["allocation_reduction_bytes"]) for row in rows]
    saved = baseline - transformed
    return {
        "objects": len(rows),
        "positive": sum(value > 0 for value in reductions),
        "zero": sum(value == 0 for value in reductions),
        "negative": sum(value < 0 for value in reductions),
        "baseline_bytes": baseline,
        "transformed_bytes": transformed,
        "saved_bytes": saved,
        "reduction_percent": round(100.0 * saved / baseline, 2)
        if baseline
        else 0.0,
        "benefit_precision_percent": round(
            100.0 * sum(value > 0 for value in reductions) / len(rows), 2
        )
        if rows
        else 0.0,
    }


def parse_guard_transforms() -> list[dict[str, str]]:
    categories = {
        row["benchmark"]: row["category"]
        for row in read_tsv(ROOT / "benchmarks/manifest.tsv")
    }
    pattern = re.compile(
        r'transform (global|alloca) name=(\S+) original-bits=(\d+) narrowed-bits=(\d+) '
        r'original-type="([^"]+)" transformed-type="([^"]+)" '
        r'original-alloc-bytes=(\d+) transformed-alloc-bytes=(\d+) '
        r'original-abi-align=(\d+) transformed-abi-align=(\d+)'
    )
    rows: list[dict[str, str]] = []
    for log in sorted((GUARD_DIR / "logs").glob("*.log")):
        for match in pattern.finditer(log.read_text(encoding="utf-8")):
            baseline = int(match.group(7))
            transformed = int(match.group(8))
            saved = baseline - transformed
            rows.append(
                {
                    "benchmark": log.stem,
                    "category": categories.get(log.stem, "uncategorized"),
                    "object_kind": match.group(1),
                    "object_name": match.group(2),
                    "original_type": match.group(5),
                    "transformed_type": match.group(6),
                    "original_bits": match.group(3),
                    "transformed_bits": match.group(4),
                    "baseline_allocation_bytes": str(baseline),
                    "transformed_allocation_bytes": str(transformed),
                    "allocation_reduction_bytes": str(saved),
                    "allocation_reduction_percent": (
                        f"{100.0 * saved / baseline:.2f}" if baseline else "0.00"
                    ),
                    "original_abi_alignment_bytes": match.group(9),
                    "transformed_abi_alignment_bytes": match.group(10),
                }
            )
    return rows


def rejection_reasons(log_dir: Path, metrics: list[dict[str, str]]) -> Counter[str]:
    reasons: Counter[str] = Counter()
    blocked_pattern = re.compile(
        r"\[adaptive-width-mem\] candidate (?:global|alloca).* "
        r"safety=blocked reason=([^\s]+)"
    )
    target_pattern = re.compile(
        r"\[adaptive-width-mem\] reject candidate=.* "
        r"reason=(no-target-allocation-benefit)"
    )
    for log in log_dir.glob("*.log"):
        text = log.read_text(encoding="utf-8")
        reasons.update(blocked_pattern.findall(text))
        reasons.update(target_pattern.findall(text))
    reasons["unknown-stored-value"] = sum(int(row["unknown_width"]) for row in metrics)
    reasons["no-meaningful-width-reduction"] = sum(
        int(row["no_meaningful_reduction"]) for row in metrics
    )
    return +reasons


def method_row(
    name: str,
    metrics: list[dict[str, str]],
    runtime: list[dict[str, str]],
    allocation_rows: list[dict[str, str]],
) -> dict[str, object]:
    allocation = summarize_allocations(allocation_rows)
    candidates = sum(
        int(row["candidate_globals"]) + int(row["candidate_allocas"])
        for row in metrics
    )
    transformed = sum(
        int(row["transformed_globals"]) + int(row["transformed_allocas"])
        for row in metrics
    )
    if transformed != allocation["objects"]:
        raise SystemExit(
            f"{name}: transformation/allocation row mismatch: "
            f"{transformed} != {allocation['objects']}"
        )
    return {
        "method": name,
        "candidates": candidates,
        "transformed": transformed,
        "positive": allocation["positive"],
        "zero": allocation["zero"],
        "negative": allocation["negative"],
        "accepted_baseline_bytes": allocation["baseline_bytes"],
        "accepted_transformed_bytes": allocation["transformed_bytes"],
        "accepted_saved_bytes": allocation["saved_bytes"],
        "accepted_reduction_percent": allocation["reduction_percent"],
        "benefit_precision_percent": allocation["benefit_precision_percent"],
        "declared_width_reduction_bits": sum(
            int(row["bits_saved_per_element"]) for row in metrics
        ),
        "differential_passed": sum(row["status"] == "PASS" for row in runtime),
        "differential_failed": sum(row["status"] != "PASS" for row in runtime),
        "raw_ir_delta": sum(int(row["ir_instruction_delta"]) for row in metrics),
        "o2_ir_delta": sum(
            int(row["optimized_ir_instruction_delta"]) for row in metrics
        ),
        "executable_size_delta_bytes": sum(
            int(row["binary_size_delta_bytes"]) for row in runtime
        ),
    }


def category_rows(method: str, rows: list[dict[str, str]]) -> list[dict[str, object]]:
    result: list[dict[str, object]] = []
    for category in sorted({row["category"] for row in rows}):
        summary = summarize_allocations(
            [row for row in rows if row["category"] == category]
        )
        result.append({"method": method, "category": category, **summary})
    return result


def main() -> None:
    baseline_data = json.loads(
        (BASE_DIR / "final-evaluation.json").read_text(encoding="utf-8")
    )
    baseline_metrics = read_tsv(ROOT / "build/benchmark-metrics/benchmark-metrics.tsv")
    baseline_runtime = read_tsv(
        ROOT / "build/runtime-differential/runtime-differential.tsv"
    )
    baseline_allocations = read_tsv(BASE_DIR / "data-layout-allocations.tsv")
    guard_metrics = read_tsv(GUARD_DIR / "benchmark-metrics.tsv")
    guard_runtime = read_tsv(GUARD_RUNTIME_DIR / "runtime-differential.tsv")
    guard_allocations = parse_guard_transforms()

    baseline = method_row(
        "A_current_conservative",
        baseline_metrics,
        baseline_runtime,
        baseline_allocations,
    )
    guard = method_row(
        "B_target_allocation_guard",
        guard_metrics,
        guard_runtime,
        guard_allocations,
    )
    if int(guard["zero"]) or int(guard["negative"]):
        raise SystemExit("target-aware guard accepted a non-beneficial transformation")
    if int(baseline_data["transformed_total"]) != int(baseline["transformed"]):
        raise SystemExit("authoritative baseline and comparison baseline disagree")

    base_keys = {
        (row["benchmark"], row["object_kind"], row["object_name"]): row
        for row in baseline_allocations
    }
    guard_keys = {
        (row["benchmark"], row["object_kind"], row["object_name"]): row
        for row in guard_allocations
    }
    omitted = [row for key, row in base_keys.items() if key not in guard_keys]
    common_baseline = sum(
        int(row["baseline_allocation_bytes"]) for row in baseline_allocations
    )
    common_guard = sum(
        int(row["transformed_allocation_bytes"]) for row in guard_allocations
    ) + sum(int(row["baseline_allocation_bytes"]) for row in omitted)
    common_saved = common_baseline - common_guard

    baseline_reasons = rejection_reasons(ROOT / "build/benchmark-metrics/logs", baseline_metrics)
    guard_reasons = rejection_reasons(GUARD_DIR / "logs", guard_metrics)
    comparison = {
        "schema_version": 1,
        "baseline_a": baseline,
        "experiment_b": guard,
        "common_26_object_opportunity_set": {
            "baseline_bytes": common_baseline,
            "baseline_a_result_bytes": int(baseline["accepted_transformed_bytes"]),
            "experiment_b_result_bytes": common_guard,
            "saved_bytes_both_methods": common_saved,
            "reduction_percent_both_methods": round(
                100.0 * common_saved / common_baseline, 2
            ),
        },
        "guard_rejected_objects": omitted,
        "baseline_a_rejection_reasons": dict(baseline_reasons),
        "experiment_b_rejection_reasons": dict(guard_reasons),
        "experiment_c": {
            "implemented": False,
            "assessment": "not feasible as a fair small extension",
            "reason": "A faithful comparison would require reconstructing instruction-level bit-usage propagation, conversion cleanup, byte-oriented width selection, AVR lowering, and the original MiBench setup; the current object-level suite cannot establish equivalence to Heo et al.'s implementation.",
        },
    }

    OUT_DIR.mkdir(parents=True, exist_ok=True)
    (OUT_DIR / "comparison.json").write_text(
        json.dumps(comparison, indent=2) + "\n", encoding="utf-8"
    )
    write_tsv(OUT_DIR / "methods.tsv", [baseline, guard])
    write_tsv(OUT_DIR / "target-aware-objects.tsv", guard_allocations)
    write_tsv(
        OUT_DIR / "categories.tsv",
        category_rows("A_current_conservative", baseline_allocations)
        + category_rows("B_target_allocation_guard", guard_allocations),
    )
    rejection_rows = [
        {"method": method, "reason": reason, "count": count}
        for method, reasons in (
            ("A_current_conservative", baseline_reasons),
            ("B_target_allocation_guard", guard_reasons),
        )
        for reason, count in sorted(reasons.items())
    ]
    write_tsv(OUT_DIR / "rejection-reasons.tsv", rejection_rows)

    md = [
        "# Target-Aware Allocation Guard Experiment",
        "",
        "| Method | Candidates | Transformed | Positive | Zero | Negative | Declared bits | Accepted bytes | Saved | Precision | Raw IR delta | O2 delta | Differential | Executable delta |",
        "|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|",
    ]
    for row in (baseline, guard):
        md.append(
            f"| {row['method']} | {row['candidates']} | {row['transformed']} | "
            f"{row['positive']} | {row['zero']} | {row['negative']} | "
            f"{row['declared_width_reduction_bits']} | "
            f"{row['accepted_baseline_bytes']} to {row['accepted_transformed_bytes']} B | "
            f"{row['accepted_saved_bytes']} B ({row['accepted_reduction_percent']}%) | "
            f"{row['benefit_precision_percent']}% | {int(row['raw_ir_delta']):+d} | "
            f"{int(row['o2_ir_delta']):+d} | {row['differential_passed']}/"
            f"{int(row['differential_passed']) + int(row['differential_failed'])} | "
            f"{int(row['executable_size_delta_bytes']):+d} B |"
        )
    md.extend(
        [
            "",
            "The accepted-object percentage changes denominator because Experiment B rejects allocation-neutral objects. On the common 26-object opportunity set, both methods reduce 150 to 83 bytes (67 bytes, 44.67%); the guard improves allocation-benefit precision and avoids neutral rewrites rather than increasing absolute allocation savings.",
            "",
            "Experiment C was not implemented: a fair prior-art-style baseline would require substantial reconstruction of Heo et al.'s instruction-level and AVR-specific method.",
        ]
    )
    (OUT_DIR / "summary.md").write_text("\n".join(md) + "\n", encoding="utf-8")
    print(OUT_DIR / "summary.md")


if __name__ == "__main__":
    main()
