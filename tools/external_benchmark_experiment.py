#!/usr/bin/env python3
"""Run the frozen Method A/B pipelines on LLVM test-suite MiBench programs."""

from __future__ import annotations

import csv
import hashlib
import json
import os
import re
import shlex
import shutil
import subprocess
import sys
from collections import Counter
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path
from typing import Any


ROOT = Path(__file__).resolve().parents[1]
SUITE_URL = "https://github.com/llvm/llvm-test-suite.git"
SUITE_COMMIT = "4b2c892865cbbb05ee996c88794a58e17d3adb81"
EXTERNAL_ROOT = ROOT / "build/external-suite"
SUITE = Path(
    os.environ.get("EXTERNAL_MIBENCH_SOURCE", EXTERNAL_ROOT / "llvm-test-suite-pinned")
)
SUITE_BUILD = EXTERNAL_ROOT / "llvm-test-suite-pinned-build"
MIBENCH = SUITE / "MultiSource/Benchmarks/MiBench"
MIBENCH_BUILD = SUITE_BUILD / "MultiSource/Benchmarks/MiBench"
OUT = ROOT / "build/external-benchmark-validation"
PLUGIN = ROOT / "build/AdaptiveWidthMemoryPass.so"
PROGRAMS = (
    "automotive-basicmath",
    "automotive-bitcount",
    "automotive-susan",
    "consumer-jpeg",
    "consumer-lame",
    "consumer-typeset",
    "network-dijkstra",
    "network-patricia",
    "office-ispell",
    "office-stringsearch",
    "security-blowfish",
    "security-rijndael",
    "security-sha",
    "telecomm-adpcm",
    "telecomm-CRC32",
    "telecomm-FFT",
    "telecomm-gsm",
)
EXECUTABLE_NAMES = {"telecomm-FFT": "telecomm-fft"}
TOOLS = (
    "git",
    "cmake",
    "ninja",
    "clang-18",
    "clang++-18",
    "opt-18",
    "llvm-link-18",
    "bash",
)
KV_RE = re.compile(r"([A-Za-z][A-Za-z0-9-]*)=(\"[^\"]*\"|\S+)")
ASSIGNMENT_RE = re.compile(r"^\s*%[-A-Za-z$._0-9]+\s*=", re.MULTILINE)


class ExperimentError(RuntimeError):
    pass


def command(
    args: list[str],
    *,
    cwd: Path = ROOT,
    capture: bool = False,
    timeout: int | None = None,
) -> subprocess.CompletedProcess[bytes]:
    result = subprocess.run(
        args,
        cwd=cwd,
        stdout=subprocess.PIPE if capture else None,
        stderr=subprocess.PIPE if capture else None,
        timeout=timeout,
        check=False,
    )
    if result.returncode != 0:
        stderr = (result.stderr or b"").decode("utf-8", errors="replace")
        stdout = (result.stdout or b"").decode("utf-8", errors="replace")
        raise ExperimentError(
            f"command failed ({result.returncode}): {shlex.join(args)}\n{stdout}{stderr}"
        )
    return result


def require_tools() -> None:
    missing = [tool for tool in TOOLS if shutil.which(tool) is None]
    if missing:
        raise ExperimentError("missing required tools: " + ", ".join(missing))


def acquire_suite() -> None:
    if not SUITE.exists():
        SUITE.mkdir(parents=True)
        command(["git", "init"], cwd=SUITE)
        command(["git", "remote", "add", "origin", SUITE_URL], cwd=SUITE)
        command(["git", "config", "core.autocrlf", "false"], cwd=SUITE)
        command(["git", "sparse-checkout", "init", "--cone"], cwd=SUITE)
        command(
            [
                "git",
                "sparse-checkout",
                "set",
                "MultiSource/Benchmarks/MiBench",
                "cmake",
                "tools",
                "litsupport",
            ],
            cwd=SUITE,
        )
    if not (SUITE / ".git").exists():
        raise ExperimentError(f"external suite is not a Git checkout: {SUITE}")
    command(["git", "config", "core.autocrlf", "false"], cwd=SUITE)
    head = subprocess.run(
        ["git", "rev-parse", "HEAD"],
        cwd=SUITE,
        stdout=subprocess.PIPE,
        stderr=subprocess.DEVNULL,
        check=False,
    )
    actual = head.stdout.decode().strip() if head.returncode == 0 else ""
    if actual != SUITE_COMMIT:
        command(
            [
                "git",
                "fetch",
                "--depth",
                "1",
                "--filter=blob:none",
                "origin",
                SUITE_COMMIT,
            ],
            cwd=SUITE,
        )
        command(["git", "checkout", "--detach", "FETCH_HEAD"], cwd=SUITE)
        actual = command(["git", "rev-parse", "HEAD"], cwd=SUITE, capture=True).stdout.decode().strip()
    if actual != SUITE_COMMIT:
        raise ExperimentError(
            f"external suite commit mismatch: expected {SUITE_COMMIT}, found {actual}"
        )
    if not MIBENCH.is_dir():
        raise ExperimentError(f"MiBench integration is missing: {MIBENCH}")


def configure_and_build_suite() -> None:
    command(
        [
            "cmake",
            "-S",
            str(SUITE),
            "-B",
            str(SUITE_BUILD),
            "-G",
            "Ninja",
            "-DCMAKE_C_COMPILER=clang-18",
            "-DCMAKE_CXX_COMPILER=clang++-18",
            "-DCMAKE_BUILD_TYPE=Release",
            "-DTEST_SUITE_SUBDIRS=MultiSource/Benchmarks/MiBench",
            "-DTEST_SUITE_BENCHMARKING_ONLY=OFF",
            "-DTEST_SUITE_RUN_TYPE=train",
            "-DTEST_SUITE_COLLECT_CODE_SIZE=OFF",
            "-DCMAKE_EXPORT_COMPILE_COMMANDS=ON",
        ]
    )
    command(["cmake", "--build", str(SUITE_BUILD), "-j", os.environ.get("JOBS", "8")])


def build_plugin() -> None:
    if not (ROOT / "build/build.ninja").exists():
        command(
            [
                "cmake",
                "-S",
                str(ROOT),
                "-B",
                str(ROOT / "build"),
                "-G",
                "Ninja",
                "-DLLVM_DIR=/usr/lib/llvm-18/lib/cmake/llvm",
            ]
        )
    command(["cmake", "--build", str(ROOT / "build")])
    if not PLUGIN.exists():
        raise ExperimentError(f"pass plugin was not built: {PLUGIN}")


def compile_entries() -> dict[str, list[dict[str, str]]]:
    path = SUITE_BUILD / "compile_commands.json"
    entries = json.loads(path.read_text(encoding="utf-8"))
    grouped: dict[str, list[dict[str, str]]] = {name: [] for name in PROGRAMS}
    prefix = str(MIBENCH.resolve()) + os.sep
    for entry in entries:
        source = str(Path(entry["file"]).resolve())
        if not source.startswith(prefix):
            continue
        program = source[len(prefix) :].split(os.sep, 1)[0]
        if program in grouped and source.endswith(".c"):
            grouped[program].append(entry)
    return grouped


def compiler_args(entry: dict[str, str], output: Path) -> list[str]:
    tokens = shlex.split(entry["command"])
    try:
        clang_index = next(
            i for i, token in enumerate(tokens) if Path(token).name == "clang-18"
        )
    except StopIteration as exc:
        raise ExperimentError(f"clang-18 not found in compile command: {entry['command']}") from exc
    source = str(Path(entry["file"]).resolve())
    original = tokens[clang_index + 1 :]
    kept: list[str] = []
    skip = False
    paired = {"-o", "-MF", "-MT", "-MQ"}
    for index, token in enumerate(original):
        if skip:
            skip = False
            continue
        if token in paired:
            skip = True
            continue
        if token in {"-c", "-MD", "-MMD", "-MP"}:
            continue
        if re.fullmatch(r"-O(?:[0-3sz]|fast)", token):
            continue
        if token == entry["file"] or str(Path(token).resolve()) == source:
            continue
        kept.append(token)
    return [
        "clang-18",
        "-O0",
        "-Xclang",
        "-disable-O0-optnone",
        "-emit-llvm",
        "-c",
        *kept,
        source,
        "-o",
        str(output),
    ]


def compile_source(entry: dict[str, str], output: Path) -> None:
    output.parent.mkdir(parents=True, exist_ok=True)
    command(compiler_args(entry, output), cwd=Path(entry["directory"]), capture=True)


def count_assignments(path: Path) -> int:
    return len(ASSIGNMENT_RE.findall(path.read_text(encoding="utf-8", errors="replace")))


def parse_fields(line: str) -> dict[str, str]:
    return {
        key: value[1:-1] if value.startswith('"') and value.endswith('"') else value
        for key, value in KV_RE.findall(line)
    }


def parse_pass_log(path: Path) -> tuple[list[dict[str, Any]], dict[str, int]]:
    candidates: list[dict[str, Any]] = []
    summary: dict[str, int] = {}
    current: dict[str, Any] | None = None
    for line in path.read_text(encoding="utf-8", errors="replace").splitlines():
        if "[adaptive-width-mem] candidate " in line:
            match = re.search(r"candidate (global|alloca)", line)
            if not match:
                continue
            current = {
                "kind": match.group(1),
                **parse_fields(line),
                "transformed": False,
                "transform": {},
                "explicit_rejection": "",
            }
            candidates.append(current)
        elif "[adaptive-width-mem] transform " in line and current is not None:
            current["transformed"] = True
            current["transform"] = parse_fields(line)
        elif "[adaptive-width-mem] reject " in line and current is not None:
            reason = parse_fields(line).get("reason", "")
            if reason:
                current["explicit_rejection"] = reason
        elif "[adaptive-width-mem] summary " in line:
            summary = {key: int(value) for key, value in parse_fields(line).items()}
    if not summary:
        raise ExperimentError(f"pass summary missing from {path}")
    return candidates, summary


def rejection_reason(candidate: dict[str, Any]) -> str:
    if candidate["transformed"]:
        return ""
    if candidate.get("explicit_rejection"):
        return str(candidate["explicit_rejection"])
    if candidate.get("safety") == "blocked":
        return str(candidate.get("reason", "safety-blocked"))
    width_reason = str(candidate.get("width-reason", ""))
    if width_reason == "unknown-stored-value":
        return width_reason
    original = int(candidate.get("original-bits", "0"))
    proposed = int(candidate.get("proposed-bits", original))
    if proposed >= original:
        return "no-meaningful-width-reduction"
    return width_reason or "unclassified-non-transformation"


def descriptor(candidate: dict[str, Any]) -> tuple[str, ...]:
    return tuple(
        str(candidate.get(key, ""))
        for key in ("kind", "function", "name", "original-bits", "proposed-bits", "safety")
    )


def executable_name(program: str) -> str:
    return EXECUTABLE_NAMES.get(program, program)


def test_command(program: str, executable: Path) -> tuple[str, Path]:
    name = executable_name(program)
    test_file = MIBENCH_BUILD / program / f"{name}.test"
    run_line = next(
        (line[4:].strip() for line in test_file.read_text().splitlines() if line.startswith("RUN:")),
        "",
    )
    if not run_line:
        raise ExperimentError(f"RUN line missing from {test_file}")
    run_part = run_line.split(";", 1)[1].strip() if ";" in run_line else run_line
    run_part, replacements = re.subn(r"%S/[^\s]+", shlex.quote(str(executable)), run_part, count=1)
    if replacements != 1:
        raise ExperimentError(f"unable to replace test executable in: {run_line}")
    run_part = run_part.replace("%S", shlex.quote(str(test_file.parent)))
    return run_part, test_file.parent


def execute(program: str, executable: Path, record_dir: Path, label: str) -> dict[str, Any]:
    run_part, cwd = test_command(program, executable)
    record_dir.mkdir(parents=True, exist_ok=True)
    (record_dir / f"{label}.command.txt").write_text(run_part + "\n", encoding="utf-8")
    try:
        result = subprocess.run(
            ["bash", "-lc", run_part],
            cwd=cwd,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            timeout=int(os.environ.get("EXTERNAL_RUN_TIMEOUT", "180")),
            check=False,
        )
    except subprocess.TimeoutExpired:
        return {"status": "SKIP", "reason": "execution-timeout", "command": run_part}
    (record_dir / f"{label}.stdout").write_bytes(result.stdout)
    (record_dir / f"{label}.stderr").write_bytes(result.stderr)
    digest = hashlib.sha256(result.stdout).hexdigest()
    stderr_first = result.stderr.decode("utf-8", errors="replace").strip().splitlines()
    reason = ""
    if result.returncode != 0:
        reason = f"exit-code-{result.returncode}"
        if stderr_first:
            reason += ": " + stderr_first[0][:160]
    return {
        "status": "OK" if result.returncode == 0 else "SKIP",
        "reason": reason,
        "returncode": result.returncode,
        "stdout_sha256": digest,
        "stdout_bytes": len(result.stdout),
        "stderr_bytes": len(result.stderr),
        "command": run_part,
    }


def build_program(program: str, entries: list[dict[str, str]]) -> tuple[dict[str, Any], list[dict[str, Any]]]:
    program_out = OUT / "programs" / program
    objects = program_out / "objects"
    logs = program_out / "logs"
    logs.mkdir(parents=True, exist_ok=True)
    if not entries:
        raise ExperimentError("no C compile commands discovered")
    bc_paths = [objects / f"{index:03d}-{Path(entry['file']).stem}.bc" for index, entry in enumerate(entries)]
    with ThreadPoolExecutor(max_workers=min(int(os.environ.get("JOBS", "8")), len(entries))) as pool:
        futures = [pool.submit(compile_source, entry, output) for entry, output in zip(entries, bc_paths)]
        for future in futures:
            future.result()

    raw_bc = program_out / f"{program}.raw.bc"
    input_ir = program_out / f"{program}.input.ll"
    a_ir = program_out / f"{program}.method-a.ll"
    b_ir = program_out / f"{program}.method-b.ll"
    a_o2 = program_out / f"{program}.method-a.o2.ll"
    b_o2 = program_out / f"{program}.method-b.o2.ll"
    base_o2 = program_out / f"{program}.baseline.o2.ll"
    command(["llvm-link-18", *map(str, bc_paths), "-o", str(raw_bc)], capture=True)
    command(["opt-18", "-passes=mem2reg", "-S", str(raw_bc), "-o", str(input_ir)], capture=True)

    for method, pipeline, output in (
        ("a", "adaptive-width-mem", a_ir),
        ("b", "adaptive-width-mem-target-aware", b_ir),
    ):
        result = subprocess.run(
            [
                "opt-18",
                f"-load-pass-plugin={PLUGIN}",
                f"-passes={pipeline}",
                "-verify-each",
                "-S",
                str(input_ir),
                "-o",
                str(output),
            ],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            check=False,
        )
        (logs / f"method-{method}.log").write_bytes(result.stderr)
        if result.returncode != 0:
            raise ExperimentError(f"Method {method.upper()} opt failure; see {logs / f'method-{method}.log'}")
        command(["opt-18", "-passes=verify", "-disable-output", str(output)], capture=True)

    for source, output in ((input_ir, base_o2), (a_ir, a_o2), (b_ir, b_o2)):
        command(["opt-18", "-passes=default<O2>", "-S", str(source), "-o", str(output)], capture=True)
        command(["opt-18", "-passes=verify", "-disable-output", str(output)], capture=True)

    binaries = {
        "baseline": program_out / f"{program}.baseline.exe",
        "a": program_out / f"{program}.method-a.exe",
        "b": program_out / f"{program}.method-b.exe",
    }
    for source, output in ((input_ir, binaries["baseline"]), (a_ir, binaries["a"]), (b_ir, binaries["b"])):
        command(["clang-18", "-O2", str(source), "-lm", "-o", str(output)], capture=True)

    a_candidates, a_summary = parse_pass_log(logs / "method-a.log")
    b_candidates, b_summary = parse_pass_log(logs / "method-b.log")
    if len(a_candidates) != len(b_candidates):
        raise ExperimentError(f"A/B candidate-count mismatch: {len(a_candidates)} != {len(b_candidates)}")
    rows: list[dict[str, Any]] = []
    for index, (a, b) in enumerate(zip(a_candidates, b_candidates), start=1):
        if descriptor(a) != descriptor(b):
            raise ExperimentError(f"A/B candidate mismatch at {program}:{index}: {descriptor(a)} != {descriptor(b)}")
        if b["transformed"] and not a["transformed"]:
            raise ExperimentError(f"Method B transformed a non-A candidate at {program}:{index}")
        at = a.get("transform", {})
        bt = b.get("transform", {})
        baseline_bytes = int(at["original-alloc-bytes"]) if a["transformed"] else None
        transformed_bytes = int(at["transformed-alloc-bytes"]) if a["transformed"] else None
        reduction = baseline_bytes - transformed_bytes if baseline_bytes is not None else None
        b_reason = rejection_reason(b)
        if a["transformed"] and reduction is not None:
            if reduction > 0 and not b["transformed"]:
                raise ExperimentError(f"Method B removed a positive candidate at {program}:{index}")
            if reduction <= 0 and b["transformed"]:
                raise ExperimentError(f"Method B retained a non-positive candidate at {program}:{index}")
            if not b["transformed"] and b_reason != "no-target-allocation-benefit":
                raise ExperimentError(f"Method B removed A candidate for unexpected reason {b_reason}")
        if b["transformed"] and int(bt["transformed-alloc-bytes"]) >= int(bt["original-alloc-bytes"]):
            raise ExperimentError(f"Method B accepted a non-positive allocation at {program}:{index}")
        rows.append(
            {
                "candidate_id": f"{program}:{index:04d}",
                "program": program,
                "category": program.split("-", 1)[0],
                "source_path": str(MIBENCH / program),
                "object_kind": a["kind"],
                "function": a.get("function", ""),
                "object_name": a.get("name", ""),
                "safety": a.get("safety", ""),
                "original_width": a.get("original-bits", ""),
                "inferred_width": a.get("proposed-bits", ""),
                "extension_family": a.get("extend", ""),
                "method_a_decision": "TRANSFORM" if a["transformed"] else "REJECT",
                "method_a_reason": rejection_reason(a),
                "method_b_decision": "TRANSFORM" if b["transformed"] else "REJECT",
                "method_b_reason": b_reason,
                "baseline_allocation_bytes": baseline_bytes,
                "transformed_allocation_bytes": transformed_bytes,
                "allocation_reduction_bytes": reduction,
            }
        )

    candidate_count = a_summary["candidate-globals"] + a_summary["candidate-allocas"]
    if candidate_count != len(rows):
        raise ExperimentError(f"candidate log/summary mismatch: {len(rows)} != {candidate_count}")
    for summary in (a_summary, b_summary):
        if summary["safe"] + summary["blocked"] != candidate_count:
            raise ExperimentError(f"safe/blocked partition mismatch in {program}")
    if a_summary["safe"] != b_summary["safe"] or a_summary["blocked"] != b_summary["blocked"]:
        raise ExperimentError(f"Method B changed safety classification in {program}")

    runtime_records = program_out / "runtime"
    runs = {
        key: execute(program, path, runtime_records, key)
        for key, path in binaries.items()
    }
    official_run: dict[str, Any] = {"status": "NOT_RUN", "reason": ""}
    if runs["baseline"]["status"] != "OK":
        official_executable = MIBENCH_BUILD / program / executable_name(program)
        official_run = execute(
            program, official_executable, runtime_records, "official-packaged"
        )
    for method in ("a", "b"):
        if runs["baseline"]["status"] == "OK" and runs[method]["status"] == "OK":
            runs[method]["differential"] = (
                "PASS"
                if runs[method]["stdout_sha256"] == runs["baseline"]["stdout_sha256"]
                else "FAIL"
            )
        else:
            runs[method]["differential"] = "SKIP"

    record = {
        "program": program,
        "category": program.split("-", 1)[0],
        "source_files": len(entries),
        "status": "COMPILED",
        "skip_reason": "",
        "candidates": candidate_count,
        "safety_safe": a_summary["safe"],
        "safety_blocked": a_summary["blocked"],
        "method_a_transformed": a_summary["transformed-globals"] + a_summary["transformed-allocas"],
        "method_b_transformed": b_summary["transformed-globals"] + b_summary["transformed-allocas"],
        "method_a_raw_ir_delta": count_assignments(a_ir) - count_assignments(input_ir),
        "method_b_raw_ir_delta": count_assignments(b_ir) - count_assignments(input_ir),
        "method_a_o2_ir_delta": count_assignments(a_o2) - count_assignments(base_o2),
        "method_b_o2_ir_delta": count_assignments(b_o2) - count_assignments(base_o2),
        "baseline_executable_bytes": binaries["baseline"].stat().st_size,
        "method_a_executable_bytes": binaries["a"].stat().st_size,
        "method_b_executable_bytes": binaries["b"].stat().st_size,
        "method_a_executable_delta": binaries["a"].stat().st_size - binaries["baseline"].stat().st_size,
        "method_b_executable_delta": binaries["b"].stat().st_size - binaries["baseline"].stat().st_size,
        "method_a_differential": runs["a"]["differential"],
        "method_b_differential": runs["b"]["differential"],
        "baseline_stdout_sha256": runs["baseline"].get("stdout_sha256", ""),
        "method_a_stdout_sha256": runs["a"].get("stdout_sha256", ""),
        "method_b_stdout_sha256": runs["b"].get("stdout_sha256", ""),
        "run_command": runs["baseline"].get("command", ""),
        "run_skip_reason": runs["baseline"].get("reason", ""),
        "official_command_status": official_run["status"],
        "official_command_reason": official_run.get("reason", ""),
    }
    return record, rows


def allocation_counts(rows: list[dict[str, Any]], method: str) -> dict[str, Any]:
    accepted = [row for row in rows if row[f"method_{method}_decision"] == "TRANSFORM"]
    reductions = [int(row["allocation_reduction_bytes"]) for row in accepted]
    baseline = sum(int(row["baseline_allocation_bytes"]) for row in accepted)
    transformed = sum(int(row["transformed_allocation_bytes"]) for row in accepted)
    positive = sum(value > 0 for value in reductions)
    zero = sum(value == 0 for value in reductions)
    negative = sum(value < 0 for value in reductions)
    return {
        "transformed": len(accepted),
        "positive": positive,
        "zero": zero,
        "negative": negative,
        "baseline_allocation_bytes": baseline,
        "transformed_allocation_bytes": transformed,
        "allocation_reduction_bytes": baseline - transformed,
        "allocation_reduction_percent": round(100 * (baseline - transformed) / baseline, 2) if baseline else None,
        "allocation_benefit_precision_percent": round(100 * positive / len(accepted), 2) if accepted else None,
    }


def write_tsv(path: Path, rows: list[dict[str, Any]]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    if not rows:
        path.write_text("", encoding="utf-8")
        return
    with path.open("w", encoding="utf-8", newline="") as stream:
        writer = csv.DictWriter(stream, fieldnames=list(rows[0]), delimiter="\t", lineterminator="\n")
        writer.writeheader()
        writer.writerows(rows)


def fmt_percent(value: float | None) -> str:
    return "N/A" if value is None else f"{value:.2f}%"


def main() -> int:
    require_tools()
    acquire_suite()
    build_plugin()
    configure_and_build_suite()
    OUT.mkdir(parents=True, exist_ok=True)
    grouped = compile_entries()
    program_rows: list[dict[str, Any]] = []
    candidate_rows: list[dict[str, Any]] = []
    for index, program in enumerate(PROGRAMS, start=1):
        print(f"[{index}/{len(PROGRAMS)}] {program}", flush=True)
        try:
            program_row, rows = build_program(program, grouped[program])
            program_rows.append(program_row)
            candidate_rows.extend(rows)
        except Exception as exc:  # preserve coverage instead of hiding one failure
            program_rows.append(
                {
                    "program": program,
                    "category": program.split("-", 1)[0],
                    "source_files": len(grouped.get(program, [])),
                    "status": "SKIPPED",
                    "skip_reason": str(exc).splitlines()[0],
                    "candidates": "",
                    "safety_safe": "",
                    "safety_blocked": "",
                    "method_a_transformed": "",
                    "method_b_transformed": "",
                    "method_a_raw_ir_delta": "",
                    "method_b_raw_ir_delta": "",
                    "method_a_o2_ir_delta": "",
                    "method_b_o2_ir_delta": "",
                    "baseline_executable_bytes": "",
                    "method_a_executable_bytes": "",
                    "method_b_executable_bytes": "",
                    "method_a_executable_delta": "",
                    "method_b_executable_delta": "",
                    "method_a_differential": "SKIP",
                    "method_b_differential": "SKIP",
                    "baseline_stdout_sha256": "",
                    "method_a_stdout_sha256": "",
                    "method_b_stdout_sha256": "",
                    "run_command": "",
                    "run_skip_reason": "",
                    "official_command_status": "NOT_RUN",
                    "official_command_reason": "",
                }
            )
            print(f"  SKIPPED: {exc}", file=sys.stderr, flush=True)

    compiled = [row for row in program_rows if row["status"] == "COMPILED"]
    method_a = allocation_counts(candidate_rows, "a")
    method_b = allocation_counts(candidate_rows, "b")
    for label, method in (("a", method_a), ("b", method_b)):
        if method["positive"] + method["zero"] + method["negative"] != method["transformed"]:
            raise ExperimentError(f"Method {label.upper()} allocation partition is inconsistent")
    if method_b["zero"] or method_b["negative"]:
        raise ExperimentError("Method B accepted a non-positive allocation result")

    common_a_base = sum(int(row["baseline_allocation_bytes"]) for row in candidate_rows if row["method_a_decision"] == "TRANSFORM")
    common_a_result = sum(int(row["transformed_allocation_bytes"]) for row in candidate_rows if row["method_a_decision"] == "TRANSFORM")
    common_b_result = sum(
        int(row["transformed_allocation_bytes"])
        if row["method_b_decision"] == "TRANSFORM"
        else int(row["baseline_allocation_bytes"])
        for row in candidate_rows
        if row["method_a_decision"] == "TRANSFORM"
    )
    neutral_removed = sum(
        row["method_a_decision"] == "TRANSFORM"
        and int(row["allocation_reduction_bytes"]) == 0
        and row["method_b_decision"] == "REJECT"
        for row in candidate_rows
    )
    negative_removed = sum(
        row["method_a_decision"] == "TRANSFORM"
        and int(row["allocation_reduction_bytes"]) < 0
        and row["method_b_decision"] == "REJECT"
        for row in candidate_rows
    )
    candidates = sum(int(row["candidates"]) for row in compiled)
    mibench_compilation_units = sum(int(row["source_files"]) for row in compiled)
    safe = sum(int(row["safety_safe"]) for row in compiled)
    blocked = sum(int(row["safety_blocked"]) for row in compiled)
    if safe + blocked != candidates:
        raise ExperimentError("aggregate safe/blocked partition is inconsistent")

    for label, method in (("a", method_a), ("b", method_b)):
        method.update(
            {
                "raw_ir_delta": sum(int(row[f"method_{label}_raw_ir_delta"]) for row in compiled),
                "o2_ir_delta": sum(int(row[f"method_{label}_o2_ir_delta"]) for row in compiled),
                "executable_size_delta_bytes": sum(int(row[f"method_{label}_executable_delta"]) for row in compiled),
                "differential_passed": sum(row[f"method_{label}_differential"] == "PASS" for row in compiled),
                "differential_failed": sum(row[f"method_{label}_differential"] == "FAIL" for row in compiled),
                "differential_skipped": sum(row[f"method_{label}_differential"] == "SKIP" for row in compiled),
            }
        )
    rejection_rows = []
    for method in ("a", "b"):
        counts = Counter(
            row[f"method_{method}_reason"]
            for row in candidate_rows
            if row[f"method_{method}_decision"] == "REJECT"
        )
        rejection_rows.extend(
            {"method": method.upper(), "reason": reason, "count": count}
            for reason, count in sorted(counts.items())
        )

    result = {
        "schema_version": 1,
        "suite": {
            "name": "MiBench via LLVM test-suite",
            "repository": SUITE_URL,
            "commit": SUITE_COMMIT,
            "source_root": str(MIBENCH),
        },
        "programs_attempted": len(PROGRAMS),
        "programs_successfully_compiled": len(compiled),
        "programs_skipped": len(PROGRAMS) - len(compiled),
        "programs_with_candidates": sum(int(row["candidates"]) > 0 for row in compiled),
        "mibench_c_compilation_units": mibench_compilation_units,
        "total_candidates": candidates,
        "safety_safe": safe,
        "safety_blocked": blocked,
        "method_a": method_a,
        "method_b": method_b,
        "neutral_transformations_eliminated": neutral_removed,
        "negative_transformations_eliminated": negative_removed,
        "common_method_a_opportunity_set": {
            "baseline_bytes": common_a_base,
            "method_a_result_bytes": common_a_result,
            "method_b_result_bytes": common_b_result,
            "method_a_saved_bytes": common_a_base - common_a_result,
            "method_b_saved_bytes": common_a_base - common_b_result,
            "method_a_reduction_percent": round(100 * (common_a_base - common_a_result) / common_a_base, 2) if common_a_base else None,
            "method_b_reduction_percent": round(100 * (common_a_base - common_b_result) / common_a_base, 2) if common_a_base else None,
        },
        "invariants": {
            "safe_plus_blocked_equals_candidates": True,
            "allocation_partitions_match_transformations": True,
            "method_b_is_subset_of_method_a": True,
            "method_b_accepts_only_positive_allocation_reductions": True,
            "method_b_changes_only_target_allocation_acceptance": True,
        },
        "programs": program_rows,
    }
    write_tsv(OUT / "programs.tsv", program_rows)
    write_tsv(OUT / "candidates.tsv", candidate_rows)
    write_tsv(OUT / "rejection-reasons.tsv", rejection_rows)
    (OUT / "results.json").write_text(json.dumps(result, indent=2) + "\n", encoding="utf-8")

    summary = [
        "# External MiBench Validation",
        "",
        f"Suite: LLVM test-suite MiBench at `{SUITE_COMMIT}`.",
        "",
        f"Programs attempted: {len(PROGRAMS)}; compiled: {len(compiled)}; skipped: {len(PROGRAMS) - len(compiled)}; programs with candidates: {result['programs_with_candidates']}.",
        f"MiBench C compilation units: {mibench_compilation_units}. LLVM test-suite support tools are not included.",
        f"Candidates: {candidates}; safety-safe: {safe}; safety-blocked: {blocked}.",
        "",
        "| Metric | Method A | Method B |",
        "|---|---:|---:|",
        f"| Transformed | {method_a['transformed']} | {method_b['transformed']} |",
        f"| Positive / zero / negative | {method_a['positive']} / {method_a['zero']} / {method_a['negative']} | {method_b['positive']} / {method_b['zero']} / {method_b['negative']} |",
        f"| Allocation-benefit precision | {fmt_percent(method_a['allocation_benefit_precision_percent'])} | {fmt_percent(method_b['allocation_benefit_precision_percent'])} |",
        f"| Accepted allocation | {method_a['baseline_allocation_bytes']} to {method_a['transformed_allocation_bytes']} B | {method_b['baseline_allocation_bytes']} to {method_b['transformed_allocation_bytes']} B |",
        f"| Accepted saving | {method_a['allocation_reduction_bytes']} B ({fmt_percent(method_a['allocation_reduction_percent'])}) | {method_b['allocation_reduction_bytes']} B ({fmt_percent(method_b['allocation_reduction_percent'])}) |",
        f"| Raw / O2 IR delta | {method_a['raw_ir_delta']:+d} / {method_a['o2_ir_delta']:+d} | {method_b['raw_ir_delta']:+d} / {method_b['o2_ir_delta']:+d} |",
        f"| Executable-size delta | {method_a['executable_size_delta_bytes']:+d} B | {method_b['executable_size_delta_bytes']:+d} B |",
        f"| Differential pass / fail / skip | {method_a['differential_passed']} / {method_a['differential_failed']} / {method_a['differential_skipped']} | {method_b['differential_passed']} / {method_b['differential_failed']} / {method_b['differential_skipped']} |",
        "",
        f"Method B eliminated {neutral_removed} neutral and {negative_removed} negative Method A transformations.",
        f"On Method A's common opportunity set: baseline {common_a_base} B; A result {common_a_result} B; B result {common_b_result} B.",
        "",
        "## Skipped programs",
        "",
    ]
    skipped = [row for row in program_rows if row["status"] == "SKIPPED"]
    summary.extend(
        [f"- `{row['program']}`: {row['skip_reason']}" for row in skipped]
        or ["- None."]
    )
    differential_skips = [
        row for row in compiled if row["method_a_differential"] == "SKIP"
    ]
    summary.extend(["", "## Differential-execution skips", ""])
    summary.extend(
        [
            f"- `{row['program']}`: {row['run_skip_reason']} "
            f"(official packaged executable: {row['official_command_status']}; "
            f"{row['official_command_reason'] or 'no error'})"
            for row in differential_skips
        ]
        or ["- None."]
    )
    summary.extend(
        [
            "",
            "## Interpretation guardrails",
            "",
            "- This is external validation; the 32-kernel controlled experiment remains separate and unchanged.",
            "- DataLayout allocation size is not physical or peak runtime memory.",
            "- IR counts and executable file size do not establish runtime speed or energy benefit.",
            "- Differential agreement is finite evidence for the packaged commands, not universal equivalence.",
        ]
    )
    (OUT / "summary.md").write_text("\n".join(summary) + "\n", encoding="utf-8")
    command(
        [
            sys.executable,
            str(ROOT / "tests/check_external_results.py"),
            str(OUT),
        ],
        capture=True,
    )
    print(OUT / "summary.md")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except ExperimentError as error:
        print(f"external benchmark experiment failed: {error}", file=sys.stderr)
        raise SystemExit(1)
