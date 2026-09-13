#!/usr/bin/env python3
"""Evaluate every minimum-allocation safe width for all 23 accepted objects."""

from __future__ import annotations

import csv
import json
from collections import Counter, defaultdict
from pathlib import Path

from run_method_c import OUT, PLUGIN, ROOT, TARGETS, run
from run_posthoc import (
    RESULTS_OUT,
    artifact_metrics,
    classify,
    load_categories,
    parse_accepted_objects,
    pearson,
    prediction_stats,
)


SWEEP_OUT = ROOT / "build" / "method-c-width-sweep"


def compile_width(
    target: str, benchmark: str, ordinal: int, width: int
) -> tuple[Path, Path, Path]:
    prepared = OUT / target / benchmark / "prepared.ll"
    work = SWEEP_OUT / target / benchmark / f"object-{ordinal}" / f"i{width}"
    work.mkdir(parents=True, exist_ok=True)
    raw_ir = work / "variant.ll"
    log = work / "variant.log"
    run(
        [
            "opt-18",
            f"-load-pass-plugin={PLUGIN}",
            f"-adaptive-width-method-c-object={ordinal}",
            f"-adaptive-width-method-c-bits={width}",
            "-passes=adaptive-width-mem-method-c",
            "-verify-each",
            "-S",
            str(prepared),
            "-o",
            str(raw_ir),
        ],
        stderr=log,
    )
    o2_ir = work / "variant.o2.ll"
    run(["opt-18", "-passes=default<O2>", "-S", str(raw_ir), "-o", str(o2_ir)])
    obj = work / "variant.o"
    run(["llc-18", "-O2", "-filetype=obj", str(o2_ir), "-o", str(obj)])
    (work / "variant.s").write_text(
        run(["llvm-objdump-18", "-d", str(obj)]), encoding="utf-8"
    )
    return raw_ir, o2_ir, obj


def main() -> None:
    categories = load_categories()
    rows: list[dict[str, object]] = []

    for target in TARGETS:
        for benchmark_dir in sorted(path for path in (OUT / target).iterdir() if path.is_dir()):
            benchmark = benchmark_dir.name
            objects = parse_accepted_objects(benchmark_dir / "c.log", method_c=True)
            if not objects:
                continue
            baseline = artifact_metrics(
                benchmark_dir / "b.ll", benchmark_dir / "b.o2.ll", benchmark_dir / "b.o"
            )
            for index, obj_meta in enumerate(objects):
                name = obj_meta.candidate_name
                if name == "<unnamed>":
                    name = f"alloca-{index}"
                object_id = f"{benchmark}:{obj_meta.kind}:{name}"
                widths = range(
                    obj_meta.proposed_bits,
                    obj_meta.proposed_bits + obj_meta.allocation_equivalent_widths,
                )
                for width in widths:
                    if width == obj_meta.proposed_bits:
                        variant = dict(baseline)
                    else:
                        raw_ir, o2_ir, obj = compile_width(
                            target, benchmark, obj_meta.candidate_ordinal, width
                        )
                        variant = artifact_metrics(raw_ir, o2_ir, obj)
                    row: dict[str, object] = {
                        "target": target,
                        "category": categories.get(benchmark, "unknown"),
                        "benchmark": benchmark,
                        "object_id": object_id,
                        "candidate_ordinal": obj_meta.candidate_ordinal,
                        "kind": obj_meta.kind,
                        "original_bits": obj_meta.original_bits,
                        "w_min": obj_meta.proposed_bits,
                        "candidate_bits": width,
                        "baseline_alloc_bytes": obj_meta.baseline_alloc_bytes,
                        "minimum_alloc_bytes": obj_meta.min_alloc_bytes,
                        "allocation_equivalent_widths": obj_meta.allocation_equivalent_widths,
                    }
                    for metric, b_value in baseline.items():
                        value = variant[metric]
                        row[f"b_{metric}"] = b_value
                        row[f"candidate_{metric}"] = value
                        row[f"delta_{metric}"] = value - b_value
                    row["outcome"] = classify(
                        int(row["delta_machine_instructions"]),
                        int(row["delta_text_bytes"]),
                    )
                    rows.append(row)

    result_path = RESULTS_OUT / "width_sweep.tsv"
    with result_path.open("w", encoding="utf-8", newline="") as stream:
        writer = csv.DictWriter(stream, fieldnames=list(rows[0]), delimiter="\t")
        writer.writeheader()
        writer.writerows(rows)

    by_target_object: dict[tuple[str, str], list[dict[str, object]]] = defaultdict(list)
    for row in rows:
        by_target_object[(str(row["target"]), str(row["object_id"]))].append(row)

    preferences: list[dict[str, object]] = []
    for (target, object_id), group in sorted(by_target_object.items()):
        baseline = next(row for row in group if row["candidate_bits"] == row["w_min"])
        preferred = min(
            group,
            key=lambda row: (
                int(row["candidate_machine_instructions"]),
                int(row["candidate_text_bytes"]),
                int(row["candidate_bits"]) != int(row["w_min"]),
                int(row["candidate_bits"]),
            ),
        )
        preferences.append(
            {
                "target": target,
                "object_id": object_id,
                "benchmark": preferred["benchmark"],
                "category": preferred["category"],
                "w_min": preferred["w_min"],
                "preferred_bits": preferred["candidate_bits"],
                "preferred_differs": int(preferred["candidate_bits"] != preferred["w_min"]),
                "machine_instruction_delta": int(preferred["candidate_machine_instructions"])
                - int(baseline["b_machine_instructions"]),
                "text_byte_delta": int(preferred["candidate_text_bytes"])
                - int(baseline["b_text_bytes"]),
            }
        )

    nonbaseline = [row for row in rows if row["candidate_bits"] != row["w_min"]]
    target_summary: dict[str, object] = {}
    for target in TARGETS:
        group = [row for row in rows if row["target"] == target]
        alternatives = [row for row in nonbaseline if row["target"] == target]
        prefs = [row for row in preferences if row["target"] == target]
        target_summary[target] = {
            "candidate_widths": len(group),
            "nonbaseline_alternatives": len(alternatives),
            "alternative_outcomes": dict(Counter(str(row["outcome"]) for row in alternatives)),
            "objects_preferring_nonminimum_width": sum(
                int(row["preferred_differs"]) for row in prefs
            ),
            "preferred_total_machine_instruction_delta": sum(
                int(row["machine_instruction_delta"]) for row in prefs
            ),
            "preferred_total_text_byte_delta": sum(int(row["text_byte_delta"]) for row in prefs),
            "tti_prediction": prediction_stats(alternatives, "delta_tti_cost"),
            "o2_assignment_prediction": prediction_stats(
                alternatives, "delta_o2_assignments"
            ),
            "tti_machine_delta_pearson": pearson(
                [int(row["delta_tti_cost"]) for row in alternatives],
                [int(row["delta_machine_instructions"]) for row in alternatives],
            ),
            "o2_assignment_machine_delta_pearson": pearson(
                [int(row["delta_o2_assignments"]) for row in alternatives],
                [int(row["delta_machine_instructions"]) for row in alternatives],
            ),
        }

    preferred_by_object: dict[str, list[dict[str, object]]] = defaultdict(list)
    for row in preferences:
        preferred_by_object[str(row["object_id"])].append(row)
    cross_target = {
        object_id: {
            str(row["target"]): int(row["preferred_bits"]) for row in group
        }
        for object_id, group in sorted(preferred_by_object.items())
    }
    summary = {
        "objects": len(preferred_by_object),
        "candidate_widths_per_target": len(rows) // len(TARGETS),
        "candidate_width_evaluations": len(rows),
        "target_summary": target_summary,
        "preferences": preferences,
        "cross_target_preferred_widths": cross_target,
        "improved_alternatives": [
            {
                "target": row["target"],
                "object_id": row["object_id"],
                "candidate_bits": row["candidate_bits"],
                "machine_instruction_delta": row["delta_machine_instructions"],
                "text_byte_delta": row["delta_text_bytes"],
                "o2_assignment_delta": row["delta_o2_assignments"],
                "tti_delta": row["delta_tti_cost"],
            }
            for row in nonbaseline
            if row["outcome"] == "improved"
        ],
        "regressed_alternatives": [
            {
                "target": row["target"],
                "object_id": row["object_id"],
                "candidate_bits": row["candidate_bits"],
                "machine_instruction_delta": row["delta_machine_instructions"],
                "text_byte_delta": row["delta_text_bytes"],
                "o2_assignment_delta": row["delta_o2_assignments"],
                "tti_delta": row["delta_tti_cost"],
                "vector_ir_line_delta": row["delta_o2_vector_ir_lines"],
            }
            for row in nonbaseline
            if row["outcome"] == "regressed"
        ],
    }
    (RESULTS_OUT / "width_sweep_summary.json").write_text(
        json.dumps(summary, indent=2) + "\n", encoding="utf-8"
    )
    print(json.dumps(summary, indent=2))


if __name__ == "__main__":
    main()
