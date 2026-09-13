#!/usr/bin/env python3
"""Build the paper's authoritative evaluation snapshot from generated evidence."""

from __future__ import annotations

import csv
import hashlib
import json
import re
import statistics
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
BENCH_TSV = ROOT / "build/benchmark-metrics/benchmark-metrics.tsv"
RUNTIME_TSV = ROOT / "build/runtime-differential/runtime-differential.tsv"
LOG_DIR = ROOT / "build/benchmark-metrics/logs"
TEST_STATUS = ROOT / "build/final-test-status.tsv"
MANIFEST = ROOT / "benchmarks/manifest.tsv"
OUT_DIR = ROOT / "build/final-evaluation"


def read_tsv(path: Path) -> list[dict[str, str]]:
    if not path.exists():
        raise SystemExit(f"missing generated evidence: {path}")
    with path.open(encoding="utf-8", newline="") as stream:
        return list(csv.DictReader(stream, delimiter="\t"))


def isum(rows: list[dict[str, str]], key: str) -> int:
    return sum(int(row[key]) for row in rows)


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def allocation_summary(
    rows: list[dict[str, int | float | str]],
) -> dict[str, int | float]:
    baseline = sum(int(row["baseline_allocation_bytes"]) for row in rows)
    transformed = sum(int(row["transformed_allocation_bytes"]) for row in rows)
    reductions = [int(row["allocation_reduction_bytes"]) for row in rows]
    percentages = [float(row["allocation_reduction_percent"]) for row in rows]
    reduced = baseline - transformed
    return {
        "objects": len(rows),
        "baseline_bytes": baseline,
        "transformed_bytes": transformed,
        "reduction_bytes": reduced,
        "reduction_percent": round(100.0 * reduced / baseline, 2)
        if baseline
        else 0.0,
        "mean_object_reduction_bytes": round(statistics.fmean(reductions), 2)
        if reductions
        else 0.0,
        "median_object_reduction_bytes": round(statistics.median(reductions), 2)
        if reductions
        else 0.0,
        "mean_object_reduction_percent": round(statistics.fmean(percentages), 2)
        if percentages
        else 0.0,
        "median_object_reduction_percent": round(statistics.median(percentages), 2)
        if percentages
        else 0.0,
        "positive_reductions": sum(value > 0 for value in reductions),
        "zero_reductions": sum(value == 0 for value in reductions),
        "negative_reductions": sum(value < 0 for value in reductions),
    }


def parse_transforms() -> list[dict[str, int | float | str]]:
    categories = {
        row["benchmark"]: row["category"] for row in read_tsv(MANIFEST)
    }
    pattern = re.compile(
        r'transform (global|alloca) name=(\S+) original-bits=(\d+) narrowed-bits=(\d+) '
        r'original-type="([^"]+)" transformed-type="([^"]+)" '
        r'original-alloc-bytes=(\d+) transformed-alloc-bytes=(\d+) '
        r'original-abi-align=(\d+) transformed-abi-align=(\d+)'
    )
    transforms: list[dict[str, int | float | str]] = []
    for log in sorted(LOG_DIR.glob("*.log")):
        for match in pattern.finditer(
            log.read_text(encoding="utf-8", errors="replace")
        ):
            original_bits = int(match.group(3))
            transformed_bits = int(match.group(4))
            baseline_bytes = int(match.group(7))
            transformed_bytes = int(match.group(8))
            reduction_bytes = baseline_bytes - transformed_bytes
            transforms.append(
                {
                    "benchmark": log.stem,
                    "category": categories.get(log.stem, "uncategorized"),
                    "object_kind": match.group(1),
                    "object_name": match.group(2),
                    "original_type": match.group(5),
                    "transformed_type": match.group(6),
                    "original_bits": original_bits,
                    "transformed_bits": transformed_bits,
                    "declared_width_reduction_bits": original_bits
                    - transformed_bits,
                    "baseline_allocation_bytes": baseline_bytes,
                    "transformed_allocation_bytes": transformed_bytes,
                    "allocation_reduction_bytes": reduction_bytes,
                    "allocation_reduction_percent": round(
                        100.0 * reduction_bytes / baseline_bytes, 2
                    )
                    if baseline_bytes
                    else 0.0,
                    "original_abi_alignment_bytes": int(match.group(9)),
                    "transformed_abi_alignment_bytes": int(match.group(10)),
                }
            )
    return transforms


def write_rows(path: Path, rows: list[dict[str, object]]) -> None:
    with path.open("w", encoding="utf-8", newline="") as stream:
        fieldnames = list(rows[0].keys()) if rows else []
        writer = csv.DictWriter(
            stream, fieldnames=fieldnames, delimiter="\t", lineterminator="\n"
        )
        if rows:
            writer.writeheader()
            writer.writerows(rows)


def main() -> None:
    bench = read_tsv(BENCH_TSV)
    runtime = read_tsv(RUNTIME_TSV)
    transforms = parse_transforms()
    transformed_globals = isum(bench, "transformed_globals")
    transformed_allocas = isum(bench, "transformed_allocas")
    transformed_total = transformed_globals + transformed_allocas
    width_reductions = [
        int(row["declared_width_reduction_bits"]) for row in transforms
    ]
    if len(transforms) != transformed_total:
        raise SystemExit(
            f"inconsistent transformed count: TSV={transformed_total}, "
            f"logs={len(transforms)}"
        )
    if sum(width_reductions) != isum(bench, "bits_saved_per_element"):
        raise SystemExit("inconsistent static width reduction between TSV and logs")

    test_rows = read_tsv(TEST_STATUS)
    if len(test_rows) != 1 or test_rows[0].get("status") != "passed":
        raise SystemExit("final test suite status is missing or not passed")
    if len(bench) != len(runtime):
        raise SystemExit(
            f"benchmark/runtime count mismatch: metrics={len(bench)}, "
            f"runtime={len(runtime)}"
        )

    candidate_globals = isum(bench, "candidate_globals")
    candidate_allocas = isum(bench, "candidate_allocas")
    safe = isum(bench, "safe")
    blocked = isum(bench, "blocked")
    candidates = candidate_globals + candidate_allocas
    if safe + blocked != candidates:
        raise SystemExit(
            f"candidate classification mismatch: candidates={candidates}, "
            f"safe+blocked={safe + blocked}"
        )

    runtime_passed = sum(row["status"] == "PASS" for row in runtime)
    runtime_failed = sum(row["status"] != "PASS" for row in runtime)
    pass_times = [int(row["pass_wall_ms"]) for row in bench]
    baseline_binary = isum(runtime, "baseline_binary_bytes")
    transformed_binary = isum(runtime, "transformed_binary_bytes")
    binary_delta = isum(runtime, "binary_size_delta_bytes")

    allocation = allocation_summary(transforms)
    allocation_by_kind = {
        kind: allocation_summary(
            [row for row in transforms if row["object_kind"] == kind]
        )
        for kind in ("alloca", "global")
    }
    allocation_by_category = {
        category: allocation_summary(
            [row for row in transforms if row["category"] == category]
        )
        for category in sorted({str(row["category"]) for row in transforms})
    }

    summary: dict[str, object] = {
        "schema_version": 2,
        "implementation_status": "frozen-mvp",
        "benchmark_count": len(bench),
        "candidate_globals": candidate_globals,
        "candidate_allocas": candidate_allocas,
        "candidate_total": candidates,
        "safe_candidates": safe,
        "blocked_candidates": blocked,
        "unknown_width_candidates": isum(bench, "unknown_width"),
        "no_meaningful_reduction_candidates": isum(
            bench, "no_meaningful_reduction"
        ),
        "rewrite_blocked_candidates": isum(bench, "rewrite_blocked"),
        "transformed_globals": transformed_globals,
        "transformed_allocas": transformed_allocas,
        "transformed_total": transformed_total,
        "static_per_element_width_reduction_bits_sum": sum(width_reductions),
        "static_per_element_width_reduction_bits_mean": round(
            statistics.fmean(width_reductions), 2
        ),
        "static_per_element_width_reduction_bits_median": round(
            statistics.median(width_reductions), 2
        ),
        "data_layout_allocation_baseline_bytes": allocation["baseline_bytes"],
        "data_layout_allocation_transformed_bytes": allocation[
            "transformed_bytes"
        ],
        "data_layout_allocation_reduction_bytes": allocation["reduction_bytes"],
        "data_layout_allocation_reduction_percent": allocation[
            "reduction_percent"
        ],
        "data_layout_mean_object_reduction_bytes": allocation[
            "mean_object_reduction_bytes"
        ],
        "data_layout_median_object_reduction_bytes": allocation[
            "median_object_reduction_bytes"
        ],
        "data_layout_mean_object_reduction_percent": allocation[
            "mean_object_reduction_percent"
        ],
        "data_layout_median_object_reduction_percent": allocation[
            "median_object_reduction_percent"
        ],
        "data_layout_positive_reductions": allocation["positive_reductions"],
        "data_layout_zero_reductions": allocation["zero_reductions"],
        "data_layout_negative_reductions": allocation["negative_reductions"],
        "data_layout_allocation_by_kind": allocation_by_kind,
        "data_layout_allocation_by_category": allocation_by_category,
        "raw_ir_instruction_delta": isum(bench, "ir_instruction_delta"),
        "o2_ir_instruction_delta": isum(bench, "optimized_ir_instruction_delta"),
        "runtime_differential_total": len(runtime),
        "runtime_differential_passed": runtime_passed,
        "runtime_differential_failed": runtime_failed,
        "baseline_binary_bytes_sum": baseline_binary,
        "transformed_binary_bytes_sum": transformed_binary,
        "binary_size_delta_bytes_sum": binary_delta,
        "binary_size_delta_percent": round(
            (100.0 * binary_delta / baseline_binary) if baseline_binary else 0.0,
            3,
        ),
        "pass_process_wall_ms_mean": round(statistics.fmean(pass_times), 2),
        "pass_process_wall_ms_median": round(statistics.median(pass_times), 2),
        "compile_time_measured": False,
        "full_test_suite": "passed",
    }

    OUT_DIR.mkdir(parents=True, exist_ok=True)
    json_path = OUT_DIR / "final-evaluation.json"
    json_path.write_text(json.dumps(summary, indent=2) + "\n", encoding="utf-8")

    with (OUT_DIR / "final-evaluation.tsv").open(
        "w", encoding="utf-8", newline=""
    ) as stream:
        writer = csv.writer(stream, delimiter="\t", lineterminator="\n")
        writer.writerow(["metric", "value"])
        for key, value in summary.items():
            writer.writerow(
                [
                    key,
                    json.dumps(value, sort_keys=True)
                    if isinstance(value, dict)
                    else value,
                ]
            )

    transformed_path = OUT_DIR / "transformed-widths.tsv"
    allocation_path = OUT_DIR / "data-layout-allocations.tsv"
    write_rows(transformed_path, transforms)
    write_rows(allocation_path, transforms)
    for dimension, groups in (
        ("kind", allocation_by_kind),
        ("category", allocation_by_category),
    ):
        grouped_rows = [
            {dimension: name, **values} for name, values in groups.items()
        ]
        write_rows(OUT_DIR / f"data-layout-by-{dimension}.tsv", grouped_rows)

    source_rows = [
        ("coverage, IR deltas, pass timing", BENCH_TSV),
        ("runtime differential and binary sizes", RUNTIME_TSV),
        ("transformed object widths", transformed_path),
        ("DataLayout-derived allocation sizes", allocation_path),
        ("full test-suite status", TEST_STATUS),
    ]
    with (OUT_DIR / "claim-sources.tsv").open(
        "w", encoding="utf-8", newline=""
    ) as stream:
        writer = csv.writer(stream, delimiter="\t", lineterminator="\n")
        writer.writerow(["claim_family", "source", "sha256"])
        for claim, path in source_rows:
            writer.writerow([claim, path.relative_to(ROOT).as_posix(), sha256(path)])

    labels = {
        "benchmark_count": "Benchmarks",
        "candidate_globals": "Candidate globals",
        "candidate_allocas": "Candidate allocas",
        "candidate_total": "Total candidates",
        "safe_candidates": "Safe candidates",
        "blocked_candidates": "Rejected/blocked candidates",
        "transformed_globals": "Transformed globals",
        "transformed_allocas": "Transformed allocas",
        "transformed_total": "Total transformed objects",
        "static_per_element_width_reduction_bits_sum": "Summed declared per-element width reduction (bits)",
        "static_per_element_width_reduction_bits_mean": "Mean declared-width reduction per object (bits)",
        "static_per_element_width_reduction_bits_median": "Median declared-width reduction per object (bits)",
        "data_layout_allocation_baseline_bytes": "Baseline DataLayout allocation (bytes)",
        "data_layout_allocation_transformed_bytes": "Transformed DataLayout allocation (bytes)",
        "data_layout_allocation_reduction_bytes": "DataLayout allocation reduction (bytes)",
        "data_layout_allocation_reduction_percent": "DataLayout allocation reduction (%)",
        "data_layout_mean_object_reduction_bytes": "Mean object allocation reduction (bytes)",
        "data_layout_median_object_reduction_bytes": "Median object allocation reduction (bytes)",
        "data_layout_mean_object_reduction_percent": "Mean object allocation reduction (%)",
        "data_layout_median_object_reduction_percent": "Median object allocation reduction (%)",
        "data_layout_positive_reductions": "Objects with positive allocation reduction",
        "data_layout_zero_reductions": "Objects with zero allocation reduction",
        "data_layout_negative_reductions": "Objects with negative allocation reduction",
        "raw_ir_instruction_delta": "Raw IR instruction delta",
        "o2_ir_instruction_delta": "O2 IR instruction delta",
        "runtime_differential_total": "Runtime differential comparisons",
        "runtime_differential_passed": "Runtime comparisons passed",
        "runtime_differential_failed": "Runtime comparisons failed",
        "baseline_binary_bytes_sum": "Summed baseline executable bytes",
        "transformed_binary_bytes_sum": "Summed transformed executable bytes",
        "binary_size_delta_bytes_sum": "Summed executable-size delta (bytes)",
        "binary_size_delta_percent": "Summed executable-size delta (%)",
        "compile_time_measured": "End-to-end compile time measured",
        "full_test_suite": "Full test suite",
    }
    md = [
        "# Definitive Final Evaluation Summary",
        "",
        "This file is generated from current benchmark, runtime, per-object DataLayout, and test evidence. `final-evaluation.json` is the paper's authoritative numerical source.",
        "",
        "| Metric | Value |",
        "|---|---:|",
    ]
    for key, label in labels.items():
        md.append(f"| {label} | {summary[key]} |")
    md.extend(
        [
            "",
            "## Interpretation",
            "",
            "Level 1 is declared LLVM per-element width reduction. Level 2 is target-specific DataLayout-derived allocation-size reduction computed from each complete original and transformed object type. Neither is a whole-program physical-memory or runtime-speed measurement.",
            "",
            "## Consistency checks",
            "",
            f"- Transformed-object count agrees between the aggregate TSV and {len(transforms)} individual transformation records.",
            f"- Declared width reduction agrees between aggregate and individual evidence ({sum(width_reductions)} bits).",
            f"- DataLayout aggregation covers all objects: {allocation['baseline_bytes']} baseline bytes and {allocation['transformed_bytes']} transformed bytes.",
            f"- Candidate partition: {safe} safe + {blocked} blocked = {candidates} candidates.",
            f"- Runtime partition: {runtime_passed} passed + {runtime_failed} failed = {len(runtime)} comparisons.",
        ]
    )
    (OUT_DIR / "summary.md").write_text("\n".join(md) + "\n", encoding="utf-8")
    print(OUT_DIR / "summary.md")


if __name__ == "__main__":
    main()
