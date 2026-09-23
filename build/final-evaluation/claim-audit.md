# Final Claim Audit

All A/B claims resolve through generated macros sourced from the authoritative comparison JSON and underlying TSV/log evidence.

| Metric | A: conservative | B: allocation guard |
|---|---:|---:|
| Candidates / safe / blocked | 39 / 35 / 4 | 39 / 35 / 4 |
| Transformed | 26 | 23 |
| Positive / zero / negative | 23 / 3 / 0 | 23 / 0 / 0 |
| Declared-width reduction | 271 bits | 252 bits |
| Accepted-object allocation | 150 to 83 B | 134 to 67 B |
| Allocation-benefit precision | 88.46% | 100.00% |
| Raw / O2 IR delta | +141 / +4 | +125 / +4 |
| Executable delta | +0 B | +0 B |
| Differential | 32/32 | 32/32 |

Common 26-object set: 150 to 83 B, 67 B (44.67%) for both methods.

## External MiBench validation

Programs / compilation units: 17 / 211.
Candidates / safe / blocked: 5003 / 255 / 4748.
Method A: 42 transformed, 40 / 2 / 0 positive / neutral / negative, precision 95.24%.
Method B: 40 transformed, 40 / 0 / 0 positive / neutral / negative, precision 100.00%.
Common set: 2700 to 1448 B, 1252 B (46.37%) for both methods.
Raw / O2 deltas: A +109 / +119; B +100 / +53.
Executable deltas: A +216 B; B +208 B.
Differential: 16 pass, 0 fail, 1 skip.

## Document checks

- Pages: 12 (A4, 595.28 x 841.89 pt).
- Figures: 5.
- Tables: 8.
- Bibliography entries: 26.
- No stale 11-kernel or +37 result remains.
- The PDF states no physical-memory or runtime-performance improvement.
