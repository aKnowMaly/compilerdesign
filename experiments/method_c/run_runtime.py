#!/usr/bin/env python3
"""Run the existing 32-kernel differential harness for Method C unchanged."""

from __future__ import annotations

import csv
import json
import os
import re
import subprocess
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
SCRIPT = ROOT / "tools" / "runtime_differential.sh"
OUT = ROOT / "build" / "method-c" / "runtime"


def main() -> None:
    script = SCRIPT.read_text(encoding="utf-8")
    script = re.sub(
        r'^ROOT_DIR=.*$', f'ROOT_DIR="{ROOT}"', script, count=1, flags=re.MULTILINE
    )
    env = os.environ.copy()
    env["PASS_PIPELINE"] = "adaptive-width-mem-method-c"
    env["RUNTIME_OUT_DIR"] = str(OUT)
    subprocess.run(["bash", "-c", script], cwd=ROOT, env=env, check=True)

    with (OUT / "runtime-differential.tsv").open(encoding="utf-8") as stream:
        rows = list(csv.DictReader(stream, delimiter="\t"))
    summary = {
        "comparisons": len(rows),
        "passed": sum(row["status"] == "PASS" for row in rows),
        "failed": sum(row["status"] != "PASS" for row in rows),
        "summed_executable_size_delta_bytes": sum(
            int(row["binary_size_delta_bytes"]) for row in rows
        ),
    }
    (OUT / "result.json").write_text(
        json.dumps(summary, indent=2) + "\n", encoding="utf-8"
    )
    print(json.dumps(summary, indent=2))


if __name__ == "__main__":
    main()

