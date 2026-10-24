#!/usr/bin/env python3
"""Independently reconcile expanded-corpus counts against individual TSV rows."""
import csv
import json
from pathlib import Path
import sys


def rows(path):
    with path.open(encoding="utf-8",newline="") as stream:
        return list(csv.DictReader(stream,delimiter="\t"))


def check(directory):
    result=json.loads((directory/"results.json").read_text())
    programs=rows(directory/"programs.tsv")
    candidates=rows(directory/"candidates.tsv")
    families=rows(directory/"families.tsv")
    evaluated=[p for p in programs if p["status"]=="EVALUATED"]
    assert len(programs)==result["targets_discovered"]
    assert len(evaluated)==result["programs_evaluated"]
    assert len({p["program"] for p in programs})==len(programs)
    assert len({p["source_set_sha256"] for p in evaluated})==result["unique_evaluated_source_sets"]
    assert sum(int(p["source_units"]) for p in evaluated)==result["compilation_units"]
    assert sum(int(f["evaluated"]) for f in families)==len(evaluated)
    for method in "ABC":
        metric=result[method]
        accepted=[c for c in candidates if c[f"{method}_decision"]=="TRANSFORM"]
        reductions=[int(c[f"{method}_original-alloc-bytes"])-int(c[f"{method}_transformed-alloc-bytes"]) for c in accepted]
        assert len(accepted)==metric["transformed"]
        assert sum(reductions)==metric["saved_bytes"]
        assert sum(v>0 for v in reductions)==metric["positive"]
        assert sum(v==0 for v in reductions)==metric["neutral"]
        assert len(candidates)==metric["candidates"]
        for label in ("PASS","FAIL","SKIP"):
            assert sum(p[f"{method}_differential"]==label for p in evaluated)==metric[label.lower()]
        assert sum(metric[label] for label in ("pass","fail","skip"))==len(evaluated)
        if method in "BC":
            assert all(v>0 for v in reductions)
        assert sum(int(f[f"{method}_transformed"]) for f in families)==metric["transformed"]
    assert sum(result["width_instruction_"+k] for k in ("better","equal","worse"))==result["width_choice_eligible_programs"]
    print(f"Expanded evidence reconciled: {len(evaluated)} programs, {len(candidates)} candidate objects, {len(families)} families")


if __name__=="__main__":
    check(Path(sys.argv[1]) if len(sys.argv)>1 else Path("build/expanded-corpus"))
