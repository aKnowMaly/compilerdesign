#!/usr/bin/env python3
"""Compact cross-target Method B versus Method C feasibility experiment."""

from __future__ import annotations

import csv
import json
import os
import re
import subprocess
from dataclasses import asdict, dataclass
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
PLUGIN = ROOT / "build" / "AdaptiveWidthMemoryPass.so"
BENCHMARKS = ROOT / "benchmarks"
OUT = ROOT / "build" / "method-c"

TARGETS = {
    "x86_64": "x86_64-pc-linux-gnu",
    "aarch64": "aarch64-unknown-linux-gnu",
    "riscv64": "riscv64-unknown-linux-gnu",
}

TRANSFORM_RE = re.compile(
    r"transform (alloca|global) name=(\S+) original-bits=(\d+) "
    r"narrowed-bits=(\d+).*original-alloc-bytes=(\d+) "
    r"transformed-alloc-bytes=(\d+)"
)
CHOICE_RE = re.compile(
    r"method-c candidate=(\S+) w-min=(\d+) selected-bits=(\d+) "
    r"safe-widths=(\d+) allocation-positive-widths=(\d+) "
    r"min-allocation-equivalent-widths=(\d+) baseline-alloc-bytes=(\d+) "
    r"min-alloc-bytes=(\d+)"
)
ASM_RE = re.compile(r"^\s*[0-9a-f]+:\s+[0-9a-f]+(?:\s+[0-9a-f]+)*\s+\S", re.MULTILINE)
ASSIGN_RE = re.compile(r"^\s*%[-a-zA-Z$._0-9]+\s*=", re.MULTILINE)
COST_RE = re.compile(r"estimated cost of (\d+)")


@dataclass
class Row:
    target: str
    benchmark: str
    b_transforms: int
    c_transforms: int
    changed_widths: int
    allocation_nonunique: int
    b_raw_assignments: int
    c_raw_assignments: int
    b_o2_assignments: int
    c_o2_assignments: int
    b_tti_cost: int
    c_tti_cost: int
    b_machine_instructions: int
    c_machine_instructions: int
    b_text_bytes: int
    c_text_bytes: int
    b_object_bytes: int
    c_object_bytes: int


def run(args: list[str], *, stderr: Path | None = None) -> str:
    result = subprocess.run(
        args,
        check=True,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
    if stderr is not None:
        stderr.write_text(result.stderr, encoding="utf-8")
    return result.stdout


def count_assignments(path: Path) -> int:
    return len(ASSIGN_RE.findall(path.read_text(encoding="utf-8")))


def text_size(path: Path) -> int:
    output = run(["llvm-size-18", "-A", str(path)])
    for line in output.splitlines():
        fields = line.split()
        if fields and fields[0] == ".text":
            return int(fields[1])
    return 0


def tti_cost(path: Path) -> int:
    result = subprocess.run(
        ["opt-18", "-passes=print<cost-model>", "-disable-output", str(path)],
        check=True,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
    return sum(int(value) for value in COST_RE.findall(result.stdout + result.stderr))


def transforms(log: str) -> list[tuple[str, str, int, int, int, int]]:
    return [
        (kind, name.removesuffix(".narrow"), int(old), int(new), int(a0), int(a1))
        for kind, name, old, new, a0, a1 in TRANSFORM_RE.findall(log)
    ]


def choices(log: str) -> list[tuple[str, int, int, int, int, int, int, int]]:
    return [
        (name, *(int(value) for value in values))
        for name, *values in CHOICE_RE.findall(log)
    ]


def compile_variant(input_ir: Path, pipeline: str, output_ir: Path, log: Path) -> str:
    return run(
        [
            "opt-18",
            f"-load-pass-plugin={PLUGIN}",
            f"-passes={pipeline}",
            "-verify-each",
            "-S",
            str(input_ir),
            "-o",
            str(output_ir),
        ],
        stderr=log,
    )


def evaluate_one(target_name: str, triple: str, source: Path) -> Row:
    bench = source.stem
    work = OUT / target_name / bench
    work.mkdir(parents=True, exist_ok=True)
    raw = work / "raw.ll"
    prepared = work / "prepared.ll"

    run(
        [
            "clang-18",
            "-target",
            triple,
            "-O0",
            "-S",
            "-emit-llvm",
            "-Xclang",
            "-disable-O0-optnone",
            str(source),
            "-o",
            str(raw),
        ]
    )
    run(["opt-18", "-passes=mem2reg", "-S", str(raw), "-o", str(prepared)])

    artifacts: dict[str, dict[str, object]] = {}
    for label, pipeline in (
        ("b", "adaptive-width-mem-target-aware"),
        ("c", "adaptive-width-mem-method-c"),
    ):
        ir = work / f"{label}.ll"
        log = work / f"{label}.log"
        compile_variant(prepared, pipeline, ir, log)
        run(["opt-18", "-passes=verify", "-disable-output", str(ir)])
        o2 = work / f"{label}.o2.ll"
        run(["opt-18", "-passes=default<O2>", "-S", str(ir), "-o", str(o2)])
        obj = work / f"{label}.o"
        run(["llc-18", "-O2", "-filetype=obj", str(o2), "-o", str(obj)])
        disassembly = run(["llvm-objdump-18", "-d", str(obj)])
        log_text = log.read_text(encoding="utf-8")
        artifacts[label] = {
            "transforms": transforms(log_text),
            "choices": choices(log_text),
            "raw_assignments": count_assignments(ir),
            "o2_assignments": count_assignments(o2),
            "tti_cost": tti_cost(ir),
            "instructions": len(ASM_RE.findall(disassembly)),
            "text_bytes": text_size(obj),
            "object_bytes": obj.stat().st_size,
        }

    b = artifacts["b"]
    c = artifacts["c"]
    b_transforms = b["transforms"]
    c_transforms = c["transforms"]
    if len(b_transforms) != len(c_transforms):
        raise RuntimeError(f"accepted-set mismatch for {target_name}/{bench}")

    changed = 0
    for b_item, c_item in zip(b_transforms, c_transforms):
        if b_item[0] != c_item[0] or b_item[2] != c_item[2]:
            raise RuntimeError(f"transform-order mismatch for {target_name}/{bench}")
        changed += b_item[3] != c_item[3]

    accepted_c = len(c_transforms)
    allocation_nonunique = sum(
        1 for item in c["choices"] if item[5] > 1 and item[4] > 0
    )
    if accepted_c > len(c["choices"]):
        raise RuntimeError(f"missing Method C choice records for {target_name}/{bench}")

    return Row(
        target=target_name,
        benchmark=bench,
        b_transforms=len(b_transforms),
        c_transforms=len(c_transforms),
        changed_widths=changed,
        allocation_nonunique=allocation_nonunique,
        b_raw_assignments=int(b["raw_assignments"]),
        c_raw_assignments=int(c["raw_assignments"]),
        b_o2_assignments=int(b["o2_assignments"]),
        c_o2_assignments=int(c["o2_assignments"]),
        b_tti_cost=int(b["tti_cost"]),
        c_tti_cost=int(c["tti_cost"]),
        b_machine_instructions=int(b["instructions"]),
        c_machine_instructions=int(c["instructions"]),
        b_text_bytes=int(b["text_bytes"]),
        c_text_bytes=int(c["text_bytes"]),
        b_object_bytes=int(b["object_bytes"]),
        c_object_bytes=int(c["object_bytes"]),
    )


def summarize(rows: list[Row]) -> dict[str, object]:
    result: dict[str, object] = {}
    for target in TARGETS:
        group = [row for row in rows if row.target == target]
        summary: dict[str, object] = {
            "benchmarks": len(group),
            "method_b_transforms": sum(row.b_transforms for row in group),
            "method_c_transforms": sum(row.c_transforms for row in group),
            "different_width_objects": sum(row.changed_widths for row in group),
            "allocation_nonunique_objects": sum(row.allocation_nonunique for row in group),
        }
        for metric in (
            "raw_assignments",
            "o2_assignments",
            "tti_cost",
            "machine_instructions",
            "text_bytes",
            "object_bytes",
        ):
            b_total = sum(getattr(row, f"b_{metric}") for row in group)
            c_total = sum(getattr(row, f"c_{metric}") for row in group)
            summary[f"method_b_{metric}"] = b_total
            summary[f"method_c_{metric}"] = c_total
            summary[f"delta_{metric}"] = c_total - b_total
            summary[f"improved_benchmarks_{metric}"] = sum(
                getattr(row, f"c_{metric}") < getattr(row, f"b_{metric}")
                for row in group
            )
            summary[f"equal_benchmarks_{metric}"] = sum(
                getattr(row, f"c_{metric}") == getattr(row, f"b_{metric}")
                for row in group
            )
            summary[f"worse_benchmarks_{metric}"] = sum(
                getattr(row, f"c_{metric}") > getattr(row, f"b_{metric}")
                for row in group
            )
            summary[f"oracle_{metric}"] = sum(
                min(getattr(row, f"b_{metric}"), getattr(row, f"c_{metric}"))
                for row in group
            )
            summary[f"oracle_delta_vs_b_{metric}"] = (
                int(summary[f"oracle_{metric}"]) - b_total
            )
        result[target] = summary
    return result


def main() -> None:
    if not PLUGIN.exists():
        raise SystemExit(f"plugin not found: {PLUGIN}")
    OUT.mkdir(parents=True, exist_ok=True)
    sources = sorted(BENCHMARKS.glob("*.c"))
    rows = [
        evaluate_one(target_name, triple, source)
        for target_name, triple in TARGETS.items()
        for source in sources
    ]

    fieldnames = list(asdict(rows[0]).keys())
    with (OUT / "results.tsv").open("w", newline="", encoding="utf-8") as stream:
        writer = csv.DictWriter(stream, fieldnames=fieldnames, delimiter="\t")
        writer.writeheader()
        writer.writerows(asdict(row) for row in rows)

    summary = summarize(rows)
    (OUT / "summary.json").write_text(
        json.dumps(summary, indent=2) + "\n", encoding="utf-8"
    )
    print(json.dumps(summary, indent=2))


if __name__ == "__main__":
    main()
