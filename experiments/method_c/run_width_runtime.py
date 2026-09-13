#!/usr/bin/env python3
"""Host differential validation for every swept Method C object width."""

from __future__ import annotations

import csv
import json
import subprocess
from pathlib import Path

from run_method_c import OUT, PLUGIN, ROOT, run
from run_posthoc import RESULTS_OUT, parse_accepted_objects


RUNTIME_ROOT = OUT / "runtime"
VARIANT_ROOT = ROOT / "build" / "method-c-width-runtime"


def execute(path: Path) -> str:
    result = subprocess.run(
        [str(path)], check=True, text=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE
    )
    return result.stdout.strip()


def main() -> None:
    if not (RUNTIME_ROOT / "runtime-differential.tsv").exists():
        raise SystemExit("run experiments/method_c/run_runtime.py first")

    rows: list[dict[str, object]] = []
    for benchmark_dir in sorted(path for path in (OUT / "x86_64").iterdir() if path.is_dir()):
        benchmark = benchmark_dir.name
        objects = parse_accepted_objects(benchmark_dir / "c.log", method_c=True)
        if not objects:
            continue
        input_ir = RUNTIME_ROOT / "ir" / f"{benchmark}.ll"
        baseline_bin = RUNTIME_ROOT / "bin" / f"{benchmark}.baseline"
        if not input_ir.exists() or not baseline_bin.exists():
            raise RuntimeError(f"missing runtime artifact for {benchmark}")
        baseline_output = execute(baseline_bin)

        for index, obj in enumerate(objects):
            name = obj.candidate_name if obj.candidate_name != "<unnamed>" else f"alloca-{index}"
            object_id = f"{benchmark}:{obj.kind}:{name}"
            widths = range(obj.proposed_bits, obj.proposed_bits + obj.allocation_equivalent_widths)
            for width in widths:
                work = VARIANT_ROOT / benchmark / f"object-{obj.candidate_ordinal}" / f"i{width}"
                work.mkdir(parents=True, exist_ok=True)
                transformed_ir = work / "variant.ll"
                log = work / "variant.log"
                run(
                    [
                        "opt-18",
                        f"-load-pass-plugin={PLUGIN}",
                        f"-adaptive-width-method-c-object={obj.candidate_ordinal}",
                        f"-adaptive-width-method-c-bits={width}",
                        "-passes=adaptive-width-mem-method-c",
                        "-verify-each",
                        "-S",
                        str(input_ir),
                        "-o",
                        str(transformed_ir),
                    ],
                    stderr=log,
                )
                binary = work / "variant"
                run(
                    [
                        "clang-18",
                        str(transformed_ir),
                        "-O2",
                        "-Wno-override-module",
                        "-o",
                        str(binary),
                    ]
                )
                output = execute(binary)
                rows.append(
                    {
                        "benchmark": benchmark,
                        "object_id": object_id,
                        "candidate_ordinal": obj.candidate_ordinal,
                        "w_min": obj.proposed_bits,
                        "candidate_bits": width,
                        "status": "PASS" if output == baseline_output else "FAIL",
                        "baseline_output": baseline_output,
                        "variant_output": output,
                        "baseline_binary_bytes": baseline_bin.stat().st_size,
                        "variant_binary_bytes": binary.stat().st_size,
                        "binary_size_delta_bytes": binary.stat().st_size
                        - baseline_bin.stat().st_size,
                    }
                )

    with (RESULTS_OUT / "width_sweep_runtime.tsv").open(
        "w", encoding="utf-8", newline=""
    ) as stream:
        writer = csv.DictWriter(stream, fieldnames=list(rows[0]), delimiter="\t")
        writer.writeheader()
        writer.writerows(rows)
    summary = {
        "comparisons": len(rows),
        "passed": sum(row["status"] == "PASS" for row in rows),
        "failed": sum(row["status"] != "PASS" for row in rows),
        "objects": len({str(row["object_id"]) for row in rows}),
        "summed_binary_size_delta_bytes": sum(
            int(row["binary_size_delta_bytes"]) for row in rows
        ),
        "positive_binary_size_deltas": sum(
            int(row["binary_size_delta_bytes"]) > 0 for row in rows
        ),
        "zero_binary_size_deltas": sum(
            int(row["binary_size_delta_bytes"]) == 0 for row in rows
        ),
        "negative_binary_size_deltas": sum(
            int(row["binary_size_delta_bytes"]) < 0 for row in rows
        ),
    }
    (RESULTS_OUT / "width_sweep_runtime_summary.json").write_text(
        json.dumps(summary, indent=2) + "\n", encoding="utf-8"
    )
    print(json.dumps(summary, indent=2))


if __name__ == "__main__":
    main()
