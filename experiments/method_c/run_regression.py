#!/usr/bin/env python3
"""Execute the frozen Method A/B regression suite from a CRLF checkout."""

from __future__ import annotations

import re
import subprocess
import tempfile
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
SCRIPT = ROOT / "tests" / "run_tests.sh"


def main() -> None:
    with tempfile.TemporaryDirectory(prefix="method-c-regression-") as temp:
        normalized_tools = Path(temp)
        for source in (ROOT / "tools").glob("*.sh"):
            content = source.read_text(encoding="utf-8")
            content = re.sub(
                r'^ROOT_DIR=.*$',
                f'ROOT_DIR="{ROOT}"',
                content,
                count=1,
                flags=re.MULTILINE,
            )
            content = content.replace(
                '"$ROOT_DIR/tools/', f'"{normalized_tools}/'
            )
            destination = normalized_tools / source.name
            destination.write_text(content, encoding="utf-8")
            destination.chmod(0o755)

        script = SCRIPT.read_text(encoding="utf-8")
        script = script.split('\n"$ROOT_DIR/tools/demo_report.sh"', 1)[0]
        script += '\nprintf "frozen Method A/B core tests passed\\n"\n'
        script = re.sub(
            r'^ROOT_DIR=.*$',
            f'ROOT_DIR="{ROOT}"',
            script,
            count=1,
            flags=re.MULTILINE,
        )
        script = script.replace('"$ROOT_DIR/tools/', f'"{normalized_tools}/')
        subprocess.run(["bash", "-c", script], cwd=ROOT, check=True)


if __name__ == "__main__":
    main()
