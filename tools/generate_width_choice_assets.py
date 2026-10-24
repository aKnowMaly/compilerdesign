#!/usr/bin/env python3
"""Generate the width-choice table and macros only from reconciled run evidence."""
import json
import hashlib
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def generate():
    data = json.loads((ROOT / "build/width-choice/results.json").read_text())
    source = (ROOT / "src/AdaptiveWidthMemoryPass.cpp").read_text(encoding="utf-8")
    if hashlib.sha256(source.encode("utf-8")).hexdigest() != data["source_sha256"]:
        raise ValueError("paper evidence does not match the current pass source")
    if data["instruction_better"] + data["instruction_equal"] + data["instruction_worse"] != data["changed_kernels"]:
        raise ValueError("width-choice instruction partitions disagree")
    if data["text_better"] + data["text_equal"] + data["text_worse"] != data["changed_kernels"]:
        raise ValueError("width-choice text partitions disagree")
    values = {
        "WidthKernels": data["kernel_count"], "WidthObjects": data["accepted_objects"],
        "WidthChangedObjects": data["changed_objects"], "WidthChangedKernels": data["changed_kernels"],
        "WidthInstructionBetter": data["instruction_better"], "WidthInstructionEqual": data["instruction_equal"],
        "WidthInstructionWorse": data["instruction_worse"], "WidthTextBetter": data["text_better"],
        "WidthTextEqual": data["text_equal"], "WidthTextWorse": data["text_worse"],
        "WidthInstructionDelta": f"{data['instruction_delta_c_minus_b']:+d}",
        "WidthTextDelta": f"{data['text_delta_c_minus_b']:+d}",
        "WidthRuntimePassed": data["differential_passed_per_method"],
    }
    (ROOT / "paper/width_choice_metrics.tex").write_text(
        "% Generated from build/width-choice/results.json.\n" +
        "".join(f"\\newcommand{{\\{key}}}{{{value}}}\n" for key, value in values.items()), encoding="utf-8")
    b_inst, c_inst = (data["machine_instruction_sums"][key] for key in ("minimum", "native"))
    b_text, c_text = (data["text_byte_sums"][key] for key in ("minimum", "native"))
    table = r"""\begin{table}[t]
\centering
\caption{Controlled allocation-equivalent width comparison. Machine instructions
and text bytes are static object-code totals over all 32 kernels; outcome
partitions include only kernels with a changed representation.}
\label{tab:width-choice}
\scriptsize
\begin{tabular}{@{}lrr@{}}
\toprule
Metric & B: minimum & C: conventional \\
\midrule
"""
    table += f"Accepted objects & {data['accepted_objects']} & {data['accepted_objects']} \\\\\n"
    table += f"Common original allocation & {data['common_original_bytes']} B & {data['common_original_bytes']} B \\\\\n"
    table += f"Common result allocation & {data['common_result_bytes']} B & {data['common_result_bytes']} B \\\\\n"
    table += f"Machine instructions & {b_inst} & {c_inst} \\\\\n"
    table += f"Text-section bytes & {b_text} & {c_text} \\\\\n"
    table += f"Differential agreement & {data['differential_passed_per_method']}/32 & {data['differential_passed_per_method']}/32 \\\\\n"
    table += r"\bottomrule" + "\n" + r"\end{tabular}" + "\n" + r"\end{table}" + "\n"
    (ROOT / "paper/tables/width_choice.tex").write_text(table, encoding="utf-8")


if __name__ == "__main__":
    generate()
