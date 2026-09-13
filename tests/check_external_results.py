#!/usr/bin/env python3
"""Cross-check the generated external-validation JSON and TSV evidence."""

from __future__ import annotations

import csv
import json
import sys
from collections import Counter
from pathlib import Path


def read_tsv(path: Path) -> list[dict[str, str]]:
    with path.open(encoding="utf-8", newline="") as stream:
        return list(csv.DictReader(stream, delimiter="\t"))


def integer(row: dict[str, str], key: str) -> int:
    return int(row[key])


def main() -> int:
    evidence = Path(sys.argv[1]) if len(sys.argv) > 1 else Path(
        "build/external-benchmark-validation"
    )
    result = json.loads((evidence / "results.json").read_text(encoding="utf-8"))
    programs = read_tsv(evidence / "programs.tsv")
    candidates = read_tsv(evidence / "candidates.tsv")
    rejections = read_tsv(evidence / "rejection-reasons.tsv")

    compiled = [row for row in programs if row["status"] == "COMPILED"]
    assert len(programs) == result["programs_attempted"]
    assert len(compiled) == result["programs_successfully_compiled"]
    assert len(programs) - len(compiled) == result["programs_skipped"]
    assert sum(integer(row, "source_files") for row in compiled) == result[
        "mibench_c_compilation_units"
    ]
    assert len(candidates) == result["total_candidates"]
    assert sum(integer(row, "candidates") for row in compiled) == len(candidates)
    assert sum(integer(row, "safety_safe") for row in compiled) == result["safety_safe"]
    assert sum(integer(row, "safety_blocked") for row in compiled) == result["safety_blocked"]
    assert result["safety_safe"] + result["safety_blocked"] == len(candidates)

    for method in ("a", "b"):
        accepted = [
            row for row in candidates if row[f"method_{method}_decision"] == "TRANSFORM"
        ]
        reductions = [integer(row, "allocation_reduction_bytes") for row in accepted]
        metric = result[f"method_{method}"]
        assert len(accepted) == metric["transformed"]
        assert sum(value > 0 for value in reductions) == metric["positive"]
        assert sum(value == 0 for value in reductions) == metric["zero"]
        assert sum(value < 0 for value in reductions) == metric["negative"]
        assert metric["positive"] + metric["zero"] + metric["negative"] == metric["transformed"]
        assert sum(integer(row, "baseline_allocation_bytes") for row in accepted) == metric["baseline_allocation_bytes"]
        assert sum(integer(row, "transformed_allocation_bytes") for row in accepted) == metric["transformed_allocation_bytes"]
        assert metric["baseline_allocation_bytes"] - metric["transformed_allocation_bytes"] == metric["allocation_reduction_bytes"]
        assert sum(row[f"method_{method}_differential"] == "PASS" for row in compiled) == metric["differential_passed"]
        assert sum(row[f"method_{method}_differential"] == "FAIL" for row in compiled) == metric["differential_failed"]
        assert sum(row[f"method_{method}_differential"] == "SKIP" for row in compiled) == metric["differential_skipped"]

        expected_rejections = Counter(
            row[f"method_{method}_reason"]
            for row in candidates
            if row[f"method_{method}_decision"] == "REJECT"
        )
        actual_rejections = Counter(
            {
                row["reason"]: int(row["count"])
                for row in rejections
                if row["method"] == method.upper()
            }
        )
        assert actual_rejections == expected_rejections

    a_ids = {
        row["candidate_id"]
        for row in candidates
        if row["method_a_decision"] == "TRANSFORM"
    }
    b_ids = {
        row["candidate_id"]
        for row in candidates
        if row["method_b_decision"] == "TRANSFORM"
    }
    assert b_ids <= a_ids
    assert all(
        integer(row, "allocation_reduction_bytes") > 0
        for row in candidates
        if row["candidate_id"] in b_ids
    )
    removed = [row for row in candidates if row["candidate_id"] in a_ids - b_ids]
    assert all(row["method_b_reason"] == "no-target-allocation-benefit" for row in removed)
    assert sum(integer(row, "allocation_reduction_bytes") == 0 for row in removed) == result["neutral_transformations_eliminated"]
    assert sum(integer(row, "allocation_reduction_bytes") < 0 for row in removed) == result["negative_transformations_eliminated"]
    assert all(result["invariants"].values())

    print(
        "external evidence validated: "
        f"{len(programs)} programs, {len(candidates)} candidates, "
        f"A={len(a_ids)}, B={len(b_ids)}"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
