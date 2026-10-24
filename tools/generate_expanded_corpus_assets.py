#!/usr/bin/env python3
"""Build manuscript corpus macros/table from audited holdout evidence."""
import csv
import hashlib
import json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]


def generate():
    data=json.loads((ROOT/"build/expanded-corpus/results.json").read_text())
    source=(ROOT/"src/AdaptiveWidthMemoryPass.cpp").read_text(encoding="utf-8")
    assert hashlib.sha256(source.encode()).hexdigest()==data["pass_source_sha256"]
    with (ROOT/"build/expanded-corpus/families.tsv").open() as f:
        families=list(csv.DictReader(f,delimiter="\t"))
    with (ROOT/"build/expanded-corpus/programs.tsv").open() as f:
        programs=list(csv.DictReader(f,delimiter="\t"))
    eligible=[r for r in programs if r["status"]=="EVALUATED" and r["BC_allocation_matched"]=="True" and int(r["BC_changed_widths"])]
    instruction_delta=sum(int(r["C_machine_instructions"])-int(r["B_machine_instructions"]) for r in eligible)
    text_delta=sum(int(r["C_text_bytes"])-int(r["B_text_bytes"]) for r in eligible)
    values={"ExpandedPrograms":data["programs_evaluated"],"ExpandedUnits":data["compilation_units"],
            "ExpandedUniqueSources":data["unique_source_content_hashes"],"ExpandedUniquePrograms":data["unique_evaluated_source_sets"],
            "ExpandedCandidates":data["A"]["candidates"],"ExpandedATransformed":data["A"]["transformed"],
            "ExpandedBTransformed":data["B"]["transformed"],"ExpandedSavedBytes":data["B"]["saved_bytes"],
            "ExpandedPass":data["B"]["pass"],"ExpandedSkip":data["B"]["skip"],"ExpandedFail":data["B"]["fail"],
            "ExpandedObservablePass":data["B"]["observable_passes"],"ExpandedAffectedPrograms":data["B"]["programs_transformed"],
            "ExpandedWidthPrograms":data["width_choice_eligible_programs"],"ExpandedWidthBetter":data["width_instruction_better"],
            "ExpandedWidthEqual":data["width_instruction_equal"],"ExpandedWidthWorse":data["width_instruction_worse"],
            "ExpandedWidthValidated":data["runtime_validated_width_choice_programs"],
            "ExpandedInstructionDelta":f"{instruction_delta:+d}","ExpandedTextDelta":f"{text_delta:+d}",
            "AllExternalPrograms":17+data["programs_evaluated"],"AllExternalUnits":211+data["compilation_units"],
            "AllExternalCandidates":5003+data["A"]["candidates"],"AllPrograms":32+17+data["programs_evaluated"]}
    (ROOT/"paper/expanded_corpus_metrics.tex").write_text("% Generated holdout results.\n"+"".join(f"\\newcommand{{\\{k}}}{{{v}}}\n" for k,v in values.items()))
    table=r"""\begin{table*}[t]
\centering
\caption{Expanded external holdout corpus. Every configured C-only target is
included, including programs with zero transformations. Candidate counts denote
memory objects. MiBench and the controlled kernels are separate cohorts.}
\label{tab:expanded-corpus}
\small
\begin{tabular}{@{}lrrrrrr@{}}
\toprule
Family & Programs & C units & Candidates & A objects & B/C objects & B/C saved bytes \\
\midrule
"""
    for row in families:
        table+=" & ".join(str(row[k]) for k in ("family","evaluated","source_units","A_candidates","A_transformed","B_transformed","B_saved_bytes"))+r" \\"+"\n"
    table+=r"\midrule"+"\n"
    table+="Total & "+" & ".join(str(v) for v in (data["programs_evaluated"],data["compilation_units"],data["A"]["candidates"],data["A"]["transformed"],data["B"]["transformed"],data["B"]["saved_bytes"]))+r" \\"+"\n"
    table+=r"\bottomrule"+"\n"+r"\end{tabular}"+"\n"+r"\end{table*}"+"\n"
    (ROOT/"paper/tables/expanded_corpus.tex").write_text(table)


if __name__=="__main__":
    generate()
