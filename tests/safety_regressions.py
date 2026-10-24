#!/usr/bin/env python3
"""Check representation safety and all 256 inputs of the extension regression."""
from pathlib import Path
import json
import subprocess

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "build/safety-regressions"


def run(*args):
    return subprocess.run(list(map(str, args)), check=True, capture_output=True, text=True)


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    source = ROOT / "tests/safety_regressions.ll"
    harness = OUT / "harness.c"
    harness.write_text(r'''
#include <stdint.h>
#include <stdio.h>
extern uint32_t nested_extensions(int8_t);
extern uint16_t second_element(uint16_t), byte_gep(uint16_t), struct_gep(uint16_t);
extern uint16_t dynamic_count(uint64_t, uint16_t);
int main(void) {
  for (unsigned x = 0; x < 256; ++x) {
    int8_t s = (int8_t)x;
    uint32_t expected = (uint16_t)(int16_t)s;
    if (nested_extensions(s) != expected) return 1;
  }
  for (unsigned x = 0; x < 65536; ++x) {
    unsigned expected = x & 31u;
    if (second_element(x) != expected || byte_gep(x) != expected ||
        struct_gep(x) != expected || dynamic_count(2, x) != expected) return 2;
  }
  puts("PASS: 256 nested-extension inputs; 65536 inputs per addressing case");
  return 0;
}
''', encoding="utf-8")
    records = []
    for pipeline in ("baseline", "adaptive-width-mem", "adaptive-width-mem-target-aware", "adaptive-width-mem-native-width"):
        ir = source
        if pipeline != "baseline":
            ir = OUT / f"{pipeline}.ll"
            result = run("opt-18", f"-load-pass-plugin={ROOT / 'build/AdaptiveWidthMemoryPass.so'}",
                         f"-passes={pipeline}", "-verify-each", "-S", source, "-o", ir)
            (OUT / f"{pipeline}.log").write_text(result.stderr, encoding="utf-8")
            prefix = "NATIVE" if pipeline.endswith("native-width") else "CHECK"
            run("FileCheck-18", source, f"--check-prefix={prefix}", f"--input-file={ir}")
            # Native mode must also retain all explicitly rejected addressing cases.
            text = ir.read_text()
            for name in ("byte_gep", "struct_gep", "dynamic_count"):
                body = text.split(f"@{name}(", 1)[1].split("}", 1)[0]
                assert "%a = alloca [2 x i16]" in body, (pipeline, name)
        for level in ("-O0", "-O2"):
            binary = OUT / f"{pipeline}{level}.exe"
            run("clang-18", level, ir, harness, "-o", binary)
            output = run(binary).stdout.strip()
            records.append({"pipeline": pipeline, "optimization": level, "status": "PASS", "output": output})
    (OUT / "results.json").write_text(json.dumps(records, indent=2) + "\n")
    print(f"Safety regressions passed: {len(records)} executables")


if __name__ == "__main__":
    main()
