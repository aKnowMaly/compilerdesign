# Target-Aware Allocation Guard Experiment

| Method | Candidates | Transformed | Positive | Zero | Negative | Declared bits | Accepted bytes | Saved | Precision | Raw IR delta | O2 delta | Differential | Executable delta |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| A_current_conservative | 39 | 26 | 23 | 3 | 0 | 271 | 150 to 83 B | 67 B (44.67%) | 88.46% | +141 | +4 | 32/32 | +0 B |
| B_target_allocation_guard | 39 | 23 | 23 | 0 | 0 | 252 | 134 to 67 B | 67 B (50.0%) | 100.0% | +125 | +4 | 32/32 | +0 B |

The accepted-object percentage changes denominator because Experiment B rejects allocation-neutral objects. On the common 26-object opportunity set, both methods reduce 150 to 83 bytes (67 bytes, 44.67%); the guard improves allocation-benefit precision and avoids neutral rewrites rather than increasing absolute allocation savings.

Experiment C was not implemented: a fair prior-art-style baseline would require substantial reconstruction of Heo et al.'s instruction-level and AVR-specific method.
