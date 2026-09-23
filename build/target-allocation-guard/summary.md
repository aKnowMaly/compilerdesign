# Adaptive Width Benchmark Metrics

These measurements are generated from the C kernels in `benchmarks/`.

## Aggregate metrics

| metric | value |
|---|---:|
| benchmark inputs | 32 |
| candidate globals | 8 |
| candidate allocas | 31 |
| safe candidates | 35 |
| blocked candidates | 4 |
| unknown-width candidates | 5 |
| candidates with no meaningful width reduction | 4 |
| rewrite-blocked candidates | 0 |
| transformed globals | 5 |
| transformed allocas | 18 |
| loads rewritten | 67 |
| stores rewritten | 62 |
| summed bits saved per transformed element | 252 |
| baseline IR instruction count | 741 |
| transformed IR instruction count | 866 |
| IR instruction delta | +125 |
| optimized baseline IR instruction count | 217 |
| optimized transformed IR instruction count | 221 |
| optimized IR instruction delta | +4 |
| safe-candidate transform rate | 65.7% |
| candidate blocked rate | 10.3% |
| average pass wall time | 166.6 ms |

## Category summary

| category | inputs | transformed objects | bits saved per element |
|---|---:|---:|---:|
| signed_values | 4 | 2 | 16 |
| lookup_global | 3 | 5 | 67 |
| dsp_signal | 3 | 2 | 22 |
| image_pixel | 4 | 4 | 34 |
| unsigned_ranges | 2 | 2 | 19 |
| rejection | 6 | 0 | 0 |
| packet_header | 5 | 5 | 57 |
| embedded_state | 5 | 3 | 37 |

## Per-benchmark metrics

| benchmark | category | candidate globals | candidate allocas | safe | blocked | unknown width | no meaningful reduction | rewrite blocked | transformed globals | transformed allocas | loads rewritten | stores rewritten | bits saved per element | baseline IR inst | transformed IR inst | IR inst delta | optimized IR delta | pass wall ms |
|---|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| alias_pointer_reject | rejection | 0 | 1 | 0 | 1 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 14 | 14 | +0 | +0 | 146 |
| alpha_blend_weights | image_pixel | 0 | 1 | 1 | 0 | 0 | 0 | 0 | 0 | 1 | 4 | 3 | 8 | 27 | 34 | +7 | +0 | 198 |
| checksum_nibbles | packet_header | 0 | 1 | 1 | 0 | 0 | 0 | 0 | 0 | 1 | 4 | 4 | 12 | 31 | 39 | +8 | +0 | 174 |
| embedded_counters | embedded_state | 0 | 1 | 1 | 0 | 0 | 0 | 0 | 0 | 1 | 4 | 4 | 11 | 29 | 37 | +8 | +0 | 159 |
| fir4_coefficients | dsp_signal | 0 | 1 | 1 | 0 | 0 | 0 | 0 | 0 | 1 | 4 | 4 | 13 | 28 | 32 | +4 | +0 | 181 |
| global_constants | lookup_global | 3 | 0 | 2 | 1 | 0 | 0 | 0 | 2 | 0 | 2 | 0 | 25 | 11 | 13 | +2 | +0 | 237 |
| global_flag_table | lookup_global | 3 | 0 | 3 | 0 | 0 | 0 | 0 | 3 | 0 | 3 | 0 | 42 | 17 | 20 | +3 | +0 | 204 |
| global_lookup_small | lookup_global | 1 | 0 | 1 | 0 | 1 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 5 | 5 | +0 | +0 | 147 |
| grayscale_threshold | image_pixel | 0 | 1 | 1 | 0 | 0 | 0 | 0 | 0 | 1 | 4 | 4 | 8 | 36 | 44 | +8 | +0 | 179 |
| ipv4_header_fields | packet_header | 0 | 1 | 1 | 0 | 0 | 0 | 0 | 0 | 1 | 4 | 4 | 8 | 31 | 39 | +8 | +0 | 162 |
| mixed_signed_reject | rejection | 0 | 1 | 1 | 0 | 1 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 14 | 14 | +0 | +0 | 132 |
| moving_average4 | dsp_signal | 0 | 1 | 1 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 29 | 29 | +0 | +0 | 165 |
| overflow_uncertainty | rejection | 0 | 1 | 1 | 0 | 1 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 16 | 16 | +0 | +0 | 151 |
| packet_flags | packet_header | 0 | 1 | 1 | 0 | 0 | 0 | 0 | 0 | 1 | 4 | 4 | 11 | 30 | 38 | +8 | +0 | 163 |
| pixel_channels | image_pixel | 0 | 1 | 1 | 0 | 0 | 0 | 0 | 0 | 1 | 4 | 4 | 8 | 31 | 39 | +8 | +0 | 172 |
| protocol_version_table | packet_header | 0 | 1 | 1 | 0 | 0 | 0 | 0 | 0 | 1 | 5 | 3 | 11 | 30 | 38 | +8 | +0 | 177 |
| quantized_filter | dsp_signal | 0 | 1 | 1 | 0 | 0 | 0 | 0 | 0 | 1 | 3 | 3 | 9 | 20 | 26 | +6 | +0 | 148 |
| rejection_cases | rejection | 0 | 3 | 2 | 1 | 0 | 2 | 0 | 0 | 0 | 0 | 0 | 0 | 32 | 32 | +0 | +0 | 177 |
| rgb565_unpack | image_pixel | 0 | 1 | 1 | 0 | 0 | 0 | 0 | 0 | 1 | 3 | 3 | 10 | 26 | 32 | +6 | +0 | 173 |
| saturating_sensor | embedded_state | 0 | 1 | 1 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 15 | 15 | +0 | +0 | 165 |
| select_ranges | unsigned_ranges | 0 | 1 | 1 | 0 | 0 | 0 | 0 | 0 | 1 | 2 | 2 | 10 | 24 | 28 | +4 | +4 | 180 |
| sensor_bucket | embedded_state | 0 | 1 | 1 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 14 | 14 | +0 | +0 | 182 |
| signed_delta_pair | signed_values | 0 | 1 | 1 | 0 | 0 | 0 | 0 | 0 | 1 | 2 | 2 | 8 | 13 | 17 | +4 | +0 | 152 |
| signed_offsets | signed_values | 0 | 1 | 1 | 0 | 0 | 0 | 0 | 0 | 1 | 2 | 2 | 8 | 14 | 18 | +4 | +0 | 164 |
| signed_select_offsets | signed_values | 0 | 1 | 1 | 0 | 1 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 26 | 26 | +0 | +0 | 145 |
| signed_state_delta | signed_values | 0 | 1 | 1 | 0 | 0 | 1 | 0 | 0 | 0 | 0 | 0 | 0 | 19 | 19 | +0 | +0 | 148 |
| small_state_machine | embedded_state | 0 | 1 | 1 | 0 | 0 | 0 | 0 | 0 | 1 | 3 | 3 | 13 | 20 | 26 | +6 | +0 | 171 |
| status_flags | embedded_state | 0 | 1 | 1 | 0 | 0 | 0 | 0 | 0 | 1 | 3 | 3 | 13 | 25 | 31 | +6 | +0 | 171 |
| tcp_flag_decode | packet_header | 0 | 1 | 1 | 0 | 0 | 0 | 0 | 0 | 1 | 6 | 6 | 15 | 53 | 65 | +12 | +0 | 157 |
| unsigned_histogram | unsigned_ranges | 1 | 1 | 2 | 0 | 1 | 0 | 0 | 0 | 1 | 1 | 4 | 9 | 37 | 42 | +5 | +0 | 188 |
| volatile_reject | rejection | 0 | 1 | 0 | 1 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 10 | 10 | +0 | +0 | 120 |
| wide_unknown_reject | rejection | 0 | 1 | 1 | 0 | 0 | 1 | 0 | 0 | 0 | 0 | 0 | 0 | 14 | 14 | +0 | +0 | 144 |

## Interpretation guardrails

- Wall time is a coarse process-level measurement intended for regression tracking, not a rigorous compiler-performance result.
- Instruction counts are static LLVM IR assignment counts. The optimized delta is measured after LLVM's default O2 pipeline on baseline and transformed IR, but it is not machine-code size.
- The bit-savings metric is a static per-element width delta across transformed memory objects, not a measured runtime memory-footprint reduction.

