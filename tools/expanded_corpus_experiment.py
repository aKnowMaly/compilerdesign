#!/usr/bin/env python3
"""Outcome-independent external holdout evaluation of the unchanged A/B/C pass.

Sources are pinned, unmodified LLVM test-suite C programs. Program, source-set,
translation-unit, candidate and transformation counts are separate. Baseline
repeatability is checked, transformed failures are never converted to skips,
and zero-transformation programs remain in the corpus.
"""
from __future__ import annotations
import csv
import hashlib
import json
import os
from pathlib import Path
import re
import shlex
import shutil
import subprocess
from concurrent.futures import ThreadPoolExecutor, as_completed
import external_benchmark_experiment as old

ROOT = Path(__file__).resolve().parents[1]
CONFIG = json.loads((ROOT / "benchmarks/external-corpus.json").read_text())
OUT = ROOT / "build/expanded-corpus"
BUILD = ROOT / "build/expanded-suite-build"


def run(args, cwd=ROOT, check=True):
    result = subprocess.run(list(map(str, args)), cwd=cwd, capture_output=True, text=True)
    if check and result.returncode:
        raise RuntimeError(f"{shlex.join(list(map(str,args)))}\n{result.stdout[-2000:]}\n{result.stderr[-3000:]}")
    return result


def tsv(path, records):
    if not records:
        path.write_text("")
        return
    keys = list(dict.fromkeys(k for record in records for k in record))
    with path.open("w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, keys, delimiter="\t", lineterminator="\n")
        writer.writeheader()
        writer.writerows(records)


def sha(data):
    return hashlib.sha256(data).hexdigest()


def discover():
    grouped = {}
    for entry in json.loads((BUILD / "compile_commands.json").read_text()):
        tokens = shlex.split(entry["command"])
        output = Path(entry["directory"]) / tokens[tokens.index("-o") + 1]
        match = re.match(r"(.*)/CMakeFiles/([^/]+)\.dir/", output.as_posix())
        if not match:
            continue
        directory, target = Path(match[1]), match[2]
        rel = directory.relative_to(BUILD).as_posix()
        family = next((p for p in CONFIG["families"] if rel == p or rel.startswith(p + "/")), None)
        if family:
            key = (directory, target, family)
            grouped.setdefault(key, []).append(entry)
    return [(key, entries) for key, entries in sorted(grouped.items(), key=lambda x:str(x[0]))]


def source_identity(entries):
    hashes = sorted({sha(Path(e["file"]).read_bytes().replace(b"\r\n", b"\n")) for e in entries})
    return sha("\n".join(hashes).encode()), hashes


def machine(ir, output):
    run(["clang-18", "-O2", "-c", ir, "-o", output])
    asm = run(["llvm-objdump-18", "-d", "--no-show-raw-insn", output]).stdout
    output.with_suffix(".asm").write_text(asm)
    sections = run(["llvm-size-18", "-A", output]).stdout
    return {
        "machine_instructions": len(re.findall(r"^\s*[0-9a-f]+:\s+\S", asm, re.M)),
        "text_bytes": sum(int(m[1]) for m in re.finditer(r"^\.text(?:\.\S+)?\s+(\d+)\s+", sections,re.M)),
    }


def files_digest(directory):
    return {p.relative_to(directory).as_posix(): sha(p.read_bytes())
            for p in directory.rglob("*") if p.is_file()}


def execute(test, executable, destination):
    excluded = {p.stem for p in test.parent.glob("*.test")} | {"CMakeFiles", "Output", "cmake_install.cmake", "CTestTestfile.cmake"}
    shutil.copytree(test.parent, destination, ignore=lambda p,n:[x for x in n if x in excluded or x.endswith((".test", ".o"))])
    before = files_digest(destination)
    lines = [line[4:].strip() for line in test.read_text().splitlines() if line.startswith("RUN:")]
    if len(lines) != 1:
        return {"status":"SKIP", "reason":"unsupported-multiple-run-commands"}
    command = lines[0]
    command, replaced = re.subn(r"%S/[^\s;]+", shlex.quote(str(executable)), command, count=1)
    if replaced != 1:
        return {"status":"SKIP", "reason":"unsupported-run-command"}
    command = command.replace("%S", shlex.quote(str(destination)))
    if re.search(r"%[A-Za-z]", command):
        return {"status":"SKIP", "reason":"unsupported-run-substitution"}
    (destination.parent / (destination.name + ".command.txt")).write_text(command + "\n")
    try:
        process = subprocess.run(["bash","-o","pipefail","-c",command], cwd=destination,
                                 capture_output=True, timeout=CONFIG["runtime_timeout_seconds"])
    except subprocess.TimeoutExpired:
        return {"status":"SKIP", "reason":"baseline-or-method-timeout"}
    (destination.parent / (destination.name + ".stdout")).write_bytes(process.stdout)
    (destination.parent / (destination.name + ".stderr")).write_bytes(process.stderr)
    after = files_digest(destination)
    generated = {p:v for p,v in after.items() if before.get(p) != v}
    record = {"status":"OK" if process.returncode == 0 else "ERROR", "returncode":process.returncode,
              "stdout_sha256":sha(process.stdout), "stderr_sha256":sha(process.stderr),
              "stdout_bytes":len(process.stdout), "stderr_bytes":len(process.stderr), "generated_files":generated}
    if process.returncode:
        record["reason"] = f"exit-code-{process.returncode}: " + process.stderr.decode("utf-8",errors="replace")[:240]
    record["signature"] = sha(json.dumps({k:record[k] for k in ("stdout_sha256","stderr_sha256","generated_files")},sort_keys=True).encode())
    record["has_observable_output"] = bool(process.stdout or process.stderr or generated)
    return record


def evaluate(spec):
    (directory,target,family), entries = spec
    program = (directory.relative_to(BUILD) / target).as_posix()
    slug = program.replace("/","__")
    output = OUT / "programs" / slug
    output.mkdir(parents=True, exist_ok=True)
    identity, source_hashes = source_identity(entries)
    record = {"program":program,"family":family.split("/")[-1],"source_units":len(entries),
              "source_set_sha256":identity,"source_sha256_list":";".join(source_hashes)}
    if any(Path(e["file"]).suffix != ".c" for e in entries):
        return {**record,"status":"EXCLUDED_NON_C"}, []
    test = directory / f"{target}.test"
    if not test.exists() or not (directory / target).exists():
        return {**record,"status":"BASELINE_BUILD_FAILED"}, []
    try:
        modules = []
        for index, entry in enumerate(entries):
            module = output / f"source-{index}.bc"
            run(old.compiler_args(entry,module), cwd=Path(entry["directory"]))
            modules.append(module)
        linked, source_ir = output/"input.bc", output/"original.ll"
        run(["llvm-link-18",*modules,"-o",linked])
        run(["opt-18","-passes=mem2reg","-S",linked,"-o",source_ir])
        # Retain target-specific library and linker options from the official
        # link command; source files and object inputs are replaced by our IR.
        commands = run(["ninja","-C",BUILD,"-t","commands",str(directory.relative_to(BUILD)/target)]).stdout
        link = shlex.split(commands.strip().splitlines()[-1])
        libs = [t for t in link if t.startswith(("-l","-L","-Wl,")) or t in ("-pthread","-fopenmp") or t.endswith(".a")]
        irs = {"original":source_ir}
        decisions, summaries, candidates = {}, {}, []
        for method,pipeline in CONFIG["methods"].items():
            ir = output / f"{method}.ll"
            process = run(["opt-18",f"-load-pass-plugin={old.PLUGIN}",f"-passes={pipeline}","-verify-each","-S",source_ir,"-o",ir])
            log = output / f"{method}.log"
            log.write_text(process.stderr)
            values, summary = old.parse_pass_log(log)
            decisions[method], summaries[method], irs[method] = values, summary, ir
        if len({len(v) for v in decisions.values()}) != 1:
            raise RuntimeError("cross-method candidate enumeration mismatch")
        for i in range(len(decisions["A"])):
            item = {"program":program,"family":record["family"],"candidate_id":f"{slug}:{i}",
                    "kind":decisions["A"][i]["kind"],"name":decisions["A"][i].get("name","")}
            for method in CONFIG["methods"]:
                c = decisions[method][i]
                item[f"{method}_decision"] = "TRANSFORM" if c["transformed"] else "REJECT"
                item[f"{method}_reason"] = old.rejection_reason(c)
                item[f"{method}_width"] = c.get("transform",{}).get("narrowed-bits","")
                for key in ("original-alloc-bytes","transformed-alloc-bytes"):
                    item[f"{method}_{key}"] = c.get("transform",{}).get(key,"")
            candidates.append(item)
        binaries = {}
        for label, ir in irs.items():
            optimized = output / f"{label}.o2.ll"
            run(["opt-18","-passes=default<O2>","-verify-each","-S",ir,"-o",optimized])
            binary = output / f"{label}.exe"
            run(["clang-18","-O2",ir,*libs,"-o",binary])
            binaries[label] = binary
            record.update({f"{label}_{k}":v for k,v in machine(ir,output/f"{label}.o").items()})
            record[f"{label}_ir_assignments"] = old.count_assignments(optimized)
        baseline = execute(test,binaries["original"],output/"runtime-original")
        repeated = execute(test,binaries["original"],output/"runtime-repeat") if baseline["status"] == "OK" else baseline
        repeatable = baseline["status"] == repeated["status"] == "OK" and baseline["signature"] == repeated["signature"]
        (output/"baseline-runtime.json").write_text(json.dumps({"baseline":baseline,"repeat":repeated},indent=2))
        if baseline["status"] != "OK":
            official = execute(test,directory/target,output/"runtime-official")
            (output/"official-runtime.json").write_text(json.dumps(official,indent=2))
            record["official_runtime_status"] = official["status"]
            record["official_runtime_reason"] = official.get("reason","")
        record["baseline_repeatable"] = repeatable
        record["output_strength"] = "OBSERVABLE" if baseline.get("has_observable_output") else "EXIT_ONLY"
        record["baseline_runtime_reason"] = "" if repeatable else (
            "non-repeatable-baseline-output" if baseline["status"]==repeated["status"]=="OK"
            else baseline.get("reason",baseline.get("status","")))
        for method in CONFIG["methods"]:
            result = execute(test,binaries[method],output/f"runtime-{method}") if repeatable else {"status":"SKIP"}
            (output/f"runtime-{method}.json").write_text(json.dumps(result,indent=2))
            # An abnormal transformed execution against a valid repeatable
            # baseline is a failure, including a transformed-only timeout.
            status = ("PASS" if result.get("status") == "OK" and result.get("signature") == baseline.get("signature") else "FAIL") if repeatable else "SKIP"
            record[f"{method}_differential"] = status
            rows = decisions[method]
            transformed = [c["transform"] for c in rows if c["transformed"]]
            reductions = [int(t["original-alloc-bytes"])-int(t["transformed-alloc-bytes"]) for t in transformed]
            record.update({f"{method}_candidates":len(rows),f"{method}_use_pass":summaries[method]["safe"],
                           f"{method}_transformed":len(transformed),f"{method}_positive":sum(v>0 for v in reductions),
                           f"{method}_neutral":sum(v==0 for v in reductions),f"{method}_saved_bytes":sum(reductions)})
            if method != "A" and any(v<=0 for v in reductions):
                raise RuntimeError("allocation guard accepted a non-positive rewrite")
        b = {(i,c["transform"]["transformed-alloc-bytes"]) for i,c in enumerate(decisions["B"]) if c["transformed"]}
        c = {(i,c["transform"]["transformed-alloc-bytes"]) for i,c in enumerate(decisions["C"]) if c["transformed"]}
        record["BC_allocation_matched"] = b == c
        record["BC_changed_widths"] = sum(a.get("transform",{}).get("narrowed-bits") != b.get("transform",{}).get("narrowed-bits") for a,b in zip(decisions["B"],decisions["C"]))
        record["status"] = "EVALUATED"
        return record,candidates
    except Exception as error:
        (output/"error.txt").write_text(str(error))
        return {**record,"status":"EVALUATION_FAILED","reason":str(error).splitlines()[0]}, []


def main():
    OUT.mkdir(parents=True,exist_ok=True)
    old.require_tools()
    old.acquire_suite()
    if old.SUITE_COMMIT != CONFIG["commit"]:
        raise RuntimeError("corpus and source acquisition pins disagree")
    run(["git","sparse-checkout","set",*CONFIG["families"],"MultiSource/Benchmarks/MiBench","cmake","tools","litsupport"],cwd=old.SUITE)
    old.build_plugin()
    run(["cmake","-S",old.SUITE,"-B",BUILD,"-G","Ninja","-DCMAKE_C_COMPILER=clang-18",
         "-DCMAKE_CXX_COMPILER=clang++-18","-DCMAKE_BUILD_TYPE=Release",
         "-DTEST_SUITE_SUBDIRS="+";".join(CONFIG["families"]),"-DTEST_SUITE_BENCHMARKING_ONLY=OFF",
         "-DTEST_SUITE_RUN_TYPE=train","-DSMALL_PROBLEM_SIZE=ON","-DCMAKE_EXPORT_COMPILE_COMMANDS=ON"])
    built = run(["cmake","--build",BUILD,"-j",os.environ.get("JOBS","4"),"--","-k","0"],check=False)
    (OUT/"official-build.log").write_text(built.stdout+"\n"+built.stderr)
    specs = discover()
    records,candidates = [],[]
    with ThreadPoolExecutor(max_workers=3) as pool:
        jobs = {pool.submit(evaluate,s):s for s in specs}
        for future in as_completed(jobs):
            record,rows = future.result()
            records.append(record)
            candidates.extend(rows)
            print(f"[{len(records)}/{len(specs)}] {record['program']}: {record['status']}",flush=True)
    records.sort(key=lambda r:r["program"])
    candidates.sort(key=lambda r:r["candidate_id"])
    tsv(OUT/"programs.tsv",records)
    tsv(OUT/"candidates.tsv",candidates)
    evaluated = [r for r in records if r["status"] == "EVALUATED"]
    eligible = [r for r in evaluated if r["BC_allocation_matched"] and r["BC_changed_widths"]]
    summary = {"schema_version":1,"source_commit":CONFIG["commit"],"families_selected":CONFIG["families"],
               "toolchain":run(["clang-18","--version"]).stdout.strip(),
               "pass_source_sha256":sha((ROOT/"src/AdaptiveWidthMemoryPass.cpp").read_bytes()),
               "targets_discovered":len(records),"programs_evaluated":len(evaluated),
               "unique_evaluated_source_sets":len({r["source_set_sha256"] for r in evaluated}),
               "compilation_units":sum(r["source_units"] for r in evaluated),
               "unique_source_content_hashes":len({h for r in evaluated for h in r["source_sha256_list"].split(";")}),
               "status_counts":{s:sum(r["status"]==s for r in records) for s in sorted({r["status"] for r in records})},
               "width_choice_eligible_programs":len(eligible),
               "width_instruction_better":sum(r["C_machine_instructions"]<r["B_machine_instructions"] for r in eligible),
               "width_instruction_equal":sum(r["C_machine_instructions"]==r["B_machine_instructions"] for r in eligible),
               "width_instruction_worse":sum(r["C_machine_instructions"]>r["B_machine_instructions"] for r in eligible),
               "BC_allocation_mismatches":sum(not r["BC_allocation_matched"] for r in evaluated),
               "limitations":"Programs are clustered by family; source-set hashes detect exact source duplicates, not algorithmic similarity. No runtime speed or energy measurement. Raw output equivalence is tested only against repeatable successful baselines."}
    previous = {source_identity(entries)[0] for entries in old.compile_entries().values() if entries}
    current = {r["source_set_sha256"] for r in evaluated}
    summary["source_sets_shared_with_mibench"] = len(previous & current)
    summary["unique_external_source_sets_including_mibench"] = len(previous | current)
    summary["protocol_sha256"] = sha((ROOT/"benchmarks/external-corpus.json").read_bytes())
    for method in CONFIG["methods"]:
        summary[method]={k:sum(r[f"{method}_{k}"] for r in evaluated) for k in ("candidates","transformed","positive","neutral","saved_bytes")}
        summary[method].update({s.lower():sum(r[f"{method}_differential"]==s for r in evaluated) for s in ("PASS","FAIL","SKIP")})
        summary[method]["programs_transformed"]=sum(r[f"{method}_transformed"]>0 for r in evaluated)
        summary[method]["observable_passes"]=sum(r[f"{method}_differential"]=="PASS" and r["output_strength"]=="OBSERVABLE" for r in evaluated)
    summary["width_instruction_delta_C_minus_B"] = sum(r["C_machine_instructions"]-r["B_machine_instructions"] for r in eligible)
    summary["width_text_delta_C_minus_B"] = sum(r["C_text_bytes"]-r["B_text_bytes"] for r in eligible)
    summary["runtime_validated_width_choice_programs"] = sum(r["B_differential"]==r["C_differential"]=="PASS" for r in eligible)
    families=[]
    for family in sorted({r["family"] for r in records}):
        group=[r for r in evaluated if r["family"]==family]
        families.append({"family":family,"attempted":sum(r["family"]==family for r in records),"evaluated":len(group),
                         "source_units":sum(r["source_units"] for r in group),
                         **{f"{m}_{k}":sum(r[f"{m}_{k}"] for r in group) for m in CONFIG["methods"] for k in ("candidates","transformed","saved_bytes")}})
    tsv(OUT/"families.tsv",families)
    (OUT/"results.json").write_text(json.dumps(summary,indent=2)+"\n")
    (OUT/"summary.md").write_text("# Expanded external corpus\n\n```json\n"+json.dumps(summary,indent=2)+"\n```\n")
    run(["python3",ROOT/"tests/check_expanded_results.py",OUT])
    print(json.dumps(summary,indent=2),flush=True)
    if summary["status_counts"].get("EVALUATION_FAILED",0) or any(summary[m]["fail"] for m in CONFIG["methods"]):
        raise SystemExit("Evaluation failures preserved in reports; investigate before claiming validity")


if __name__=="__main__":
    main()
