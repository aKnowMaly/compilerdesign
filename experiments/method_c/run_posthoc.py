#!/usr/bin/env python3
"""Per-object post-hoc analysis for the isolated Method C prototype.

For each Method-B accepted object, this script changes only that object's
allocation-equivalent width choice to Method C and leaves every other object at
Method B's minimum safe width.  It then evaluates the isolated change on the
three targets used by the original feasibility experiment.
"""

from __future__ import annotations

import csv
import json
import math
import re
from collections import Counter, defaultdict
from dataclasses import asdict, dataclass
from pathlib import Path

from run_method_c import (
    ASM_RE,
    BENCHMARKS,
    OUT,
    PLUGIN,
    ROOT,
    TARGETS,
    count_assignments,
    run,
    text_size,
    tti_cost,
)


POSTHOC_OUT = ROOT / "build" / "method-c-posthoc"
RESULTS_OUT = ROOT / "experiments" / "method_c" / "results"

CANDIDATE_RE = re.compile(
    r"candidate (alloca|global)(?: function=(\S+))? name=(\S*)"
    r"(?: linkage=\S+)? type=(.*?) "
    r"safety=safe reason=(\S+) supported-uses=(\d+) unsupported-uses=0 "
    r"original-bits=(\d+) proposed-bits=(\d+) width-reason=(\S+) "
    r"extend=(\S+) loads=(\d+) stores=(\d+)"
)
CHOICE_RE = re.compile(
    r"method-c candidate=(\S+) w-min=(\d+) selected-bits=(\d+) "
    r"safe-widths=(\d+) allocation-positive-widths=(\d+) "
    r"min-allocation-equivalent-widths=(\d+) baseline-alloc-bytes=(\d+) "
    r"min-alloc-bytes=(\d+)"
)
TRANSFORM_RE = re.compile(
    r"transform (alloca|global) name=(\S+) original-bits=(\d+) "
    r"narrowed-bits=(\d+) original-type=\"([^\"]+)\" "
    r"transformed-type=\"([^\"]+)\" original-alloc-bytes=(\d+) "
    r"transformed-alloc-bytes=(\d+) original-abi-align=(\d+) "
    r"transformed-abi-align=(\d+)"
)
ASSIGNMENT_LINE_RE = re.compile(r"^\s*%[-a-zA-Z$._0-9]+\s*=", re.MULTILINE)
VECTOR_TYPE_RE = re.compile(r"<\s*\d+\s+x\s+[^>]+>")
OPS = (
    "load",
    "store",
    "trunc",
    "zext",
    "sext",
    "select",
    "phi",
    "extractelement",
    "insertelement",
    "shufflevector",
    "add",
    "and",
)


@dataclass
class ParsedObject:
    candidate_ordinal: int
    kind: str
    candidate_name: str
    function: str
    original_type: str
    supported_uses: int
    original_bits: int
    proposed_bits: int
    width_reason: str
    extension: str
    loads: int
    stores: int
    transform_name: str
    narrowed_bits: int
    transformed_type: str
    baseline_alloc_bytes: int
    transformed_alloc_bytes: int
    original_abi_align: int
    transformed_abi_align: int
    safe_widths: int = 0
    allocation_positive_widths: int = 0
    allocation_equivalent_widths: int = 0
    min_alloc_bytes: int = 0


def parse_accepted_objects(path: Path, *, method_c: bool) -> list[ParsedObject]:
    accepted: list[ParsedObject] = []
    current: dict[str, object] | None = None
    choice_ordinal = -1

    for line in path.read_text(encoding="utf-8").splitlines():
        candidate = CANDIDATE_RE.search(line)
        if candidate:
            (
                kind,
                function,
                name,
                original_type,
                _reason,
                supported_uses,
                original_bits,
                proposed_bits,
                width_reason,
                extension,
                loads,
                stores,
            ) = candidate.groups()
            current = {
                "candidate_ordinal": -1,
                "kind": kind,
                "candidate_name": name or "<unnamed>",
                "function": function or "",
                "original_type": original_type,
                "supported_uses": int(supported_uses),
                "original_bits": int(original_bits),
                "proposed_bits": int(proposed_bits),
                "width_reason": width_reason,
                "extension": extension,
                "loads": int(loads),
                "stores": int(stores),
            }
            continue

        choice = CHOICE_RE.search(line)
        if choice and current is not None:
            choice_ordinal += 1
            (
                _name,
                w_min,
                _selected,
                safe_widths,
                positive_widths,
                equivalent_widths,
                baseline_alloc,
                min_alloc,
            ) = choice.groups()
            current.update(
                candidate_ordinal=choice_ordinal,
                proposed_bits=int(w_min),
                safe_widths=int(safe_widths),
                allocation_positive_widths=int(positive_widths),
                allocation_equivalent_widths=int(equivalent_widths),
                baseline_alloc_bytes=int(baseline_alloc),
                min_alloc_bytes=int(min_alloc),
            )
            continue

        transform = TRANSFORM_RE.search(line)
        if transform and current is not None:
            (
                kind,
                transform_name,
                original_bits,
                narrowed_bits,
                original_type,
                transformed_type,
                baseline_alloc,
                transformed_alloc,
                original_align,
                transformed_align,
            ) = transform.groups()
            if kind != current["kind"] or int(original_bits) != current["original_bits"]:
                raise RuntimeError(f"candidate/transform mismatch in {path}: {line}")
            if not method_c:
                current.update(
                    candidate_ordinal=len(accepted),
                    safe_widths=int(original_bits) - int(narrowed_bits),
                    allocation_positive_widths=0,
                    allocation_equivalent_widths=0,
                    min_alloc_bytes=int(transformed_alloc),
                )
            current.update(
                transform_name=transform_name.removesuffix(".narrow"),
                narrowed_bits=int(narrowed_bits),
                original_type=original_type,
                transformed_type=transformed_type,
                baseline_alloc_bytes=int(baseline_alloc),
                transformed_alloc_bytes=int(transformed_alloc),
                original_abi_align=int(original_align),
                transformed_abi_align=int(transformed_align),
            )
            accepted.append(ParsedObject(**current))
            current = None

    return accepted


def ir_features(path: Path) -> dict[str, int]:
    text = path.read_text(encoding="utf-8")
    instruction_lines = [
        line
        for line in text.splitlines()
        if ASSIGNMENT_LINE_RE.match(line) or re.match(r"^\s*store\b", line)
    ]
    features = {
        "assignments": count_assignments(path),
        "vector_ir_lines": sum(bool(VECTOR_TYPE_RE.search(line)) for line in instruction_lines),
    }
    for op in OPS:
        features[op] = sum(bool(re.search(rf"\b{op}\b", line)) for line in instruction_lines)
    return features


def artifact_metrics(raw_ir: Path, o2_ir: Path, obj: Path) -> dict[str, int]:
    disassembly = run(["llvm-objdump-18", "-d", str(obj)])
    raw = ir_features(raw_ir)
    o2 = ir_features(o2_ir)
    metrics: dict[str, int] = {
        "raw_assignments": raw["assignments"],
        "o2_assignments": o2["assignments"],
        "tti_cost": tti_cost(raw_ir),
        "machine_instructions": len(ASM_RE.findall(disassembly)),
        "text_bytes": text_size(obj),
        "object_bytes": obj.stat().st_size,
    }
    for key, value in o2.items():
        if key != "assignments":
            metrics[f"o2_{key}"] = value
    return metrics


def compile_isolated(target: str, benchmark: str, ordinal: int) -> tuple[Path, Path, Path]:
    source = OUT / target / benchmark / "prepared.ll"
    work = POSTHOC_OUT / target / benchmark / f"object-{ordinal}"
    work.mkdir(parents=True, exist_ok=True)
    raw_ir = work / "isolated.ll"
    log = work / "isolated.log"
    run(
        [
            "opt-18",
            f"-load-pass-plugin={PLUGIN}",
            f"-adaptive-width-method-c-object={ordinal}",
            "-passes=adaptive-width-mem-method-c",
            "-verify-each",
            "-S",
            str(source),
            "-o",
            str(raw_ir),
        ],
        stderr=log,
    )
    o2_ir = work / "isolated.o2.ll"
    run(["opt-18", "-passes=default<O2>", "-S", str(raw_ir), "-o", str(o2_ir)])
    obj = work / "isolated.o"
    run(["llc-18", "-O2", "-filetype=obj", str(o2_ir), "-o", str(obj)])
    (work / "isolated.s").write_text(
        run(["llvm-objdump-18", "-d", str(obj)]), encoding="utf-8"
    )
    return raw_ir, o2_ir, obj


def load_categories() -> dict[str, str]:
    with (BENCHMARKS / "manifest.tsv").open(encoding="utf-8", newline="") as stream:
        return {
            row["benchmark"]: row["category"]
            for row in csv.DictReader(stream, delimiter="\t")
        }


def classify(delta_instructions: int, delta_text: int) -> str:
    if delta_instructions < 0 or (delta_instructions == 0 and delta_text < 0):
        return "improved"
    if delta_instructions > 0 or (delta_instructions == 0 and delta_text > 0):
        return "regressed"
    return "neutral"


def pearson(xs: list[int], ys: list[int]) -> float | None:
    if not xs or len(set(xs)) < 2 or len(set(ys)) < 2:
        return None
    mx = sum(xs) / len(xs)
    my = sum(ys) / len(ys)
    numerator = sum((x - mx) * (y - my) for x, y in zip(xs, ys))
    dx = math.sqrt(sum((x - mx) ** 2 for x in xs))
    dy = math.sqrt(sum((y - my) ** 2 for y in ys))
    return numerator / (dx * dy) if dx and dy else None


def prediction_stats(rows: list[dict[str, object]], feature: str) -> dict[str, object]:
    # Negative deltas predict a strict generated-instruction improvement.
    tp = fp = tn = fn = 0
    for row in rows:
        predicted = int(row[feature]) < 0
        actual = int(row["delta_machine_instructions"]) < 0
        if predicted and actual:
            tp += 1
        elif predicted:
            fp += 1
        elif actual:
            fn += 1
        else:
            tn += 1
    return {
        "true_positive": tp,
        "false_positive": fp,
        "true_negative": tn,
        "false_negative": fn,
        "precision": tp / (tp + fp) if tp + fp else None,
        "recall": tp / (tp + fn) if tp + fn else None,
    }


def main() -> None:
    if not PLUGIN.exists():
        raise SystemExit(f"plugin not found: {PLUGIN}")
    categories = load_categories()
    rows: list[dict[str, object]] = []

    for target in TARGETS:
        target_dir = OUT / target
        for benchmark_dir in sorted(path for path in target_dir.iterdir() if path.is_dir()):
            benchmark = benchmark_dir.name
            b_objects = parse_accepted_objects(benchmark_dir / "b.log", method_c=False)
            c_objects = parse_accepted_objects(benchmark_dir / "c.log", method_c=True)
            if len(b_objects) != len(c_objects):
                raise RuntimeError(f"accepted-object mismatch: {target}/{benchmark}")
            if not b_objects:
                continue

            baseline = artifact_metrics(
                benchmark_dir / "b.ll", benchmark_dir / "b.o2.ll", benchmark_dir / "b.o"
            )
            for index, (b_obj, c_obj) in enumerate(zip(b_objects, c_objects)):
                if b_obj.kind != c_obj.kind or b_obj.original_bits != c_obj.original_bits:
                    raise RuntimeError(f"object-order mismatch: {target}/{benchmark}/{index}")
                changed = b_obj.narrowed_bits != c_obj.narrowed_bits
                if changed:
                    raw_ir, o2_ir, obj = compile_isolated(
                        target, benchmark, c_obj.candidate_ordinal
                    )
                    isolated = artifact_metrics(raw_ir, o2_ir, obj)
                else:
                    isolated = dict(baseline)

                name = c_obj.candidate_name
                if name == "<unnamed>":
                    name = f"alloca-{index}"
                object_id = f"{benchmark}:{c_obj.kind}:{name}"
                row: dict[str, object] = {
                    "target": target,
                    "category": categories.get(benchmark, "unknown"),
                    "benchmark": benchmark,
                    "object_id": object_id,
                    "object_index": index,
                    "candidate_ordinal": c_obj.candidate_ordinal,
                    "kind": c_obj.kind,
                    "name": name,
                    "function": c_obj.function,
                    "original_type": c_obj.original_type,
                    "method_b_type": b_obj.transformed_type,
                    "method_c_type": c_obj.transformed_type,
                    "original_bits": c_obj.original_bits,
                    "w_min": b_obj.narrowed_bits,
                    "method_c_bits": c_obj.narrowed_bits,
                    "width_changed": int(changed),
                    "safe_widths": c_obj.safe_widths,
                    "allocation_positive_widths": c_obj.allocation_positive_widths,
                    "allocation_equivalent_widths": c_obj.allocation_equivalent_widths,
                    "baseline_alloc_bytes": c_obj.baseline_alloc_bytes,
                    "minimum_alloc_bytes": c_obj.min_alloc_bytes,
                    "supported_uses": c_obj.supported_uses,
                    "loads": c_obj.loads,
                    "stores": c_obj.stores,
                    "extension": c_obj.extension,
                    "width_reason": c_obj.width_reason,
                }
                for metric, b_value in baseline.items():
                    c_value = isolated[metric]
                    row[f"b_{metric}"] = b_value
                    row[f"c_{metric}"] = c_value
                    row[f"delta_{metric}"] = c_value - b_value
                row["outcome"] = classify(
                    int(row["delta_machine_instructions"]), int(row["delta_text_bytes"])
                )
                rows.append(row)

    RESULTS_OUT.mkdir(parents=True, exist_ok=True)
    result_path = RESULTS_OUT / "posthoc_objects.tsv"
    with result_path.open("w", encoding="utf-8", newline="") as stream:
        writer = csv.DictWriter(stream, fieldnames=list(rows[0]), delimiter="\t")
        writer.writeheader()
        writer.writerows(rows)

    by_object: dict[str, list[dict[str, object]]] = defaultdict(list)
    for row in rows:
        by_object[str(row["object_id"])].append(row)
    classifications: list[dict[str, object]] = []
    for object_id, group in sorted(by_object.items()):
        outcomes = Counter(str(row["outcome"]) for row in group)
        if outcomes["improved"] and outcomes["regressed"]:
            cross = "mixed"
        elif outcomes["improved"]:
            cross = "consistent-improvement" if outcomes["improved"] == len(group) else "target-specific-improvement"
        elif outcomes["regressed"]:
            cross = "consistent-regression" if outcomes["regressed"] == len(group) else "target-specific-regression"
        else:
            cross = "neutral"
        first = group[0]
        classifications.append(
            {
                "object_id": object_id,
                "benchmark": first["benchmark"],
                "category": first["category"],
                "kind": first["kind"],
                "original_bits": first["original_bits"],
                "w_min": first["w_min"],
                "method_c_bits": first["method_c_bits"],
                "allocation_equivalent_widths": first["allocation_equivalent_widths"],
                "cross_target_class": cross,
                "target_outcomes": {str(row["target"]): row["outcome"] for row in group},
                "machine_instruction_deltas": {
                    str(row["target"]): row["delta_machine_instructions"] for row in group
                },
                "text_byte_deltas": {
                    str(row["target"]): row["delta_text_bytes"] for row in group
                },
            }
        )

    target_summary: dict[str, object] = {}
    for target in TARGETS:
        group = [row for row in rows if row["target"] == target]
        target_summary[target] = {
            "objects": len(group),
            "width_changed_objects": sum(int(row["width_changed"]) for row in group),
            "outcomes": dict(Counter(str(row["outcome"]) for row in group)),
            "summed_isolated_machine_instruction_delta": sum(
                int(row["delta_machine_instructions"]) for row in group
            ),
            "summed_isolated_text_byte_delta": sum(int(row["delta_text_bytes"]) for row in group),
            "tti_prediction": prediction_stats(group, "delta_tti_cost"),
            "o2_assignment_prediction": prediction_stats(group, "delta_o2_assignments"),
            "tti_machine_delta_pearson": pearson(
                [int(row["delta_tti_cost"]) for row in group],
                [int(row["delta_machine_instructions"]) for row in group],
            ),
            "o2_assignment_machine_delta_pearson": pearson(
                [int(row["delta_o2_assignments"]) for row in group],
                [int(row["delta_machine_instructions"]) for row in group],
            ),
        }

    summary = {
        "objects": len(by_object),
        "target_object_observations": len(rows),
        "cross_target_classifications": dict(
            Counter(item["cross_target_class"] for item in classifications)
        ),
        "target_summary": target_summary,
        "objects_detail": classifications,
    }
    (RESULTS_OUT / "posthoc_summary.json").write_text(
        json.dumps(summary, indent=2) + "\n", encoding="utf-8"
    )
    print(json.dumps(summary, indent=2))


if __name__ == "__main__":
    main()
