#!/usr/bin/env python3
"""Compare minimum safe widths with allocation-equivalent conventional widths.

Method B and C share safety and allocation acceptance. C rounds to the next
width in {8,16,32,64} only when complete-object allocation is unchanged.
Machine instructions and .text bytes are static measures, not runtime results.
"""
from __future__ import annotations
import csv
import hashlib
import json
import os
from pathlib import Path
import re
import subprocess

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "build/width-choice"
TRANSFORM = re.compile(r'transform (global|alloca) name=(\S+) original-bits=(\d+) narrowed-bits=(\d+) original-type="([^"]+)" transformed-type="([^"]+)" original-alloc-bytes=(\d+) transformed-alloc-bytes=(\d+)')


def run(args, **kwargs):
    return subprocess.run(list(map(str, args)), cwd=ROOT, check=True, capture_output=True, text=True, **kwargs)


def rows(path):
    with path.open() as stream:
        return list(csv.DictReader(stream, delimiter="\t"))


def write_tsv(path, data):
    with path.open("w", newline="", encoding="utf-8") as stream:
        writer = csv.DictWriter(stream, fieldnames=list(data[0]), delimiter="\t", lineterminator="\n")
        writer.writeheader()
        writer.writerows(data)


def transform_rows(log):
    return {(m[1], m[2]): {"bits": int(m[4]), "bytes": int(m[8]), "original_bytes": int(m[7]),
                           "original_type": m[5], "type": m[6]}
            for m in TRANSFORM.finditer(log.read_text())}


def machine_metrics(ir, stem):
    obj = OUT / "machine" / f"{stem}.o"
    run(["clang-18", "-O2", "-c", ir, "-o", obj])
    disassembly = run(["llvm-objdump-18", "-d", "--no-show-raw-insn", obj]).stdout
    (obj.with_suffix(".asm")).write_text(disassembly)
    instructions = len(re.findall(r"^\s*[0-9a-f]+:\s+\S", disassembly, re.MULTILINE))
    sections = run(["llvm-size-18", "-A", obj]).stdout
    text_bytes = sum(int(m[1]) for m in re.finditer(r"^\.text(?:\.\S+)?\s+(\d+)\s+", sections, re.MULTILINE))
    return {"machine_instructions": instructions, "text_bytes": text_bytes}


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    (OUT / "machine").mkdir(exist_ok=True)
    minimum = ROOT / "build/target-allocation-guard"
    native = OUT / "native"
    native_runtime = OUT / "native-runtime"
    env = {**os.environ, "PASS_PIPELINE": "adaptive-width-mem-native-width", "BENCHMARK_OUT_DIR": str(native),
           "RUNTIME_OUT_DIR": str(native_runtime)}
    for script in ("benchmark_metrics.sh", "runtime_differential.sh"):
        result = run(["bash", ROOT / "tools" / script], env=env)
        (OUT / f"{script}.stdout").write_text(result.stdout)
    minimum_runtime = rows(ROOT / "build/target-allocation-guard-runtime/runtime-differential.tsv")
    conventional_runtime = rows(native_runtime / "runtime-differential.tsv")
    assert len(minimum_runtime) == len(conventional_runtime) == 32
    assert all(r["status"] == "PASS" for r in minimum_runtime + conventional_runtime)
    objects, benchmarks = [], []
    for source in sorted((ROOT / "benchmarks").glob("*.c")):
        name = source.stem
        b_objects = transform_rows(minimum / "logs" / f"{name}.log")
        c_objects = transform_rows(native / "logs" / f"{name}.log")
        assert b_objects.keys() == c_objects.keys(), name
        changed = 0
        for key, b in b_objects.items():
            c = c_objects[key]
            assert b["original_type"] == c["original_type"] and b["bytes"] == c["bytes"], (name, key)
            assert c["bits"] >= b["bits"]
            changed += c["bits"] != b["bits"]
            objects.append({"benchmark": name, "kind": key[0], "name": key[1], "minimum_bits": b["bits"],
                            "native_bits": c["bits"], "minimum_bytes": b["bytes"], "native_bytes": c["bytes"],
                            "original_bytes": b["original_bytes"]})
        metrics = {}
        for label, ir in (("original", minimum / "ir" / f"{name}.ll"),
                          ("minimum", minimum / "transformed-ir" / f"{name}.out.ll"),
                          ("native", native / "transformed-ir" / f"{name}.out.ll")):
            metrics[label] = machine_metrics(ir, f"{name}.{label}")
        benchmarks.append({"benchmark": name, "changed_objects": changed,
                           **{f"{label}_{k}": v for label, record in metrics.items() for k, v in record.items()},
                           "instruction_delta_c_minus_b": metrics["native"]["machine_instructions"] - metrics["minimum"]["machine_instructions"],
                           "text_delta_c_minus_b": metrics["native"]["text_bytes"] - metrics["minimum"]["text_bytes"]})
    eligible = [r for r in benchmarks if r["changed_objects"]]
    summary = {
        "schema_version": 1,
        "scope": "32 controlled C kernels; LLVM/Clang 18; x86-64; static O2 object-code metrics",
        "policy": "next conventional width in 8/16/32/64 only if complete-object DataLayout allocation equals minimum",
        "toolchain": run(["clang-18", "--version"]).stdout.strip(),
        "source_sha256": hashlib.sha256((ROOT / "src/AdaptiveWidthMemoryPass.cpp").read_bytes()).hexdigest(),
        "kernel_count": len(benchmarks), "accepted_objects": len(objects),
        "changed_objects": sum(r["minimum_bits"] != r["native_bits"] for r in objects),
        "changed_kernels": len(eligible), "differential_passed_per_method": len(conventional_runtime),
        "common_original_bytes": sum(r["original_bytes"] for r in objects),
        "common_result_bytes": sum(r["minimum_bytes"] for r in objects),
        "instruction_better": sum(r["instruction_delta_c_minus_b"] < 0 for r in eligible),
        "instruction_equal": sum(r["instruction_delta_c_minus_b"] == 0 for r in eligible),
        "instruction_worse": sum(r["instruction_delta_c_minus_b"] > 0 for r in eligible),
        "text_better": sum(r["text_delta_c_minus_b"] < 0 for r in eligible),
        "text_equal": sum(r["text_delta_c_minus_b"] == 0 for r in eligible),
        "text_worse": sum(r["text_delta_c_minus_b"] > 0 for r in eligible),
        "instruction_delta_c_minus_b": sum(r["instruction_delta_c_minus_b"] for r in benchmarks),
        "text_delta_c_minus_b": sum(r["text_delta_c_minus_b"] for r in benchmarks),
        "machine_instruction_sums": {label: sum(r[f"{label}_machine_instructions"] for r in benchmarks) for label in ("original", "minimum", "native")},
        "text_byte_sums": {label: sum(r[f"{label}_text_bytes"] for r in benchmarks) for label in ("original", "minimum", "native")},
        "limitations": "Static counts include alignment NOPs and all emitted functions. No timing, energy, dynamic instruction counts or independent external width-choice validation."
    }
    (OUT / "results.json").write_text(json.dumps(summary, indent=2) + "\n")
    write_tsv(OUT / "objects.tsv", objects)
    write_tsv(OUT / "benchmarks.tsv", benchmarks)
    lines = ["# Allocation-equivalent width comparison", "", "```json", json.dumps(summary, indent=2), "```", "",
             "All kernels are reported in benchmarks.tsv, including neutral and regressive outcomes. Negative deltas favor conventional widths; positive deltas favor minimum widths."]
    (OUT / "summary.md").write_text("\n".join(lines) + "\n")
    print(json.dumps(summary, indent=2))


if __name__ == "__main__":
    main()
