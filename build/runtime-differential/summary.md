# Runtime Differential Test Summary

| metric | value |
|---|---:|
| benchmark executables | 32 |
| passed | 32 |
| failed | 0 |
| summed baseline binary bytes | 514144 |
| summed transformed binary bytes | 514144 |
| summed binary-size delta | +0 bytes |

## Per-benchmark outputs

| benchmark | status | baseline output | transformed output | baseline bytes | transformed bytes | delta bytes |
|---|---|---:|---:|---:|---:|---:|
| alias_pointer_reject | PASS | `6467194374679382613` | `6467194374679382613` | 16072 | 16072 | +0 |
| alpha_blend_weights | PASS | `11652595099211307512` | `11652595099211307512` | 16072 | 16072 | +0 |
| checksum_nibbles | PASS | `11100237344878503709` | `11100237344878503709` | 16064 | 16064 | +0 |
| embedded_counters | PASS | `663129724967315100` | `663129724967315100` | 16064 | 16064 | +0 |
| fir4_coefficients | PASS | `6730593776571069081` | `6730593776571069081` | 16064 | 16064 | +0 |
| global_constants | PASS | `4784069539259601603` | `4784069539259601603` | 16064 | 16064 | +0 |
| global_flag_table | PASS | `18169454884862608771` | `18169454884862608771` | 16064 | 16064 | +0 |
| global_lookup_small | PASS | `13233066642452467843` | `13233066642452467843` | 16104 | 16104 | +0 |
| grayscale_threshold | PASS | `15196759134710337269` | `15196759134710337269` | 16072 | 16072 | +0 |
| ipv4_header_fields | PASS | `17706556889791868333` | `17706556889791868333` | 16064 | 16064 | +0 |
| mixed_signed_reject | PASS | `4987492419021181891` | `4987492419021181891` | 16072 | 16072 | +0 |
| moving_average4 | PASS | `8480394682139806949` | `8480394682139806949` | 16064 | 16064 | +0 |
| overflow_uncertainty | PASS | `7467371280380081043` | `7467371280380081043` | 16072 | 16072 | +0 |
| packet_flags | PASS | `7362379069970332242` | `7362379069970332242` | 16056 | 16056 | +0 |
| pixel_channels | PASS | `5617247536681234698` | `5617247536681234698` | 16056 | 16056 | +0 |
| protocol_version_table | PASS | `17397733255187038277` | `17397733255187038277` | 16072 | 16072 | +0 |
| quantized_filter | PASS | `14854562191646612399` | `14854562191646612399` | 16064 | 16064 | +0 |
| rejection_cases | PASS | `7769472843746882826` | `7769472843746882826` | 16104 | 16104 | +0 |
| rgb565_unpack | PASS | `10189336662765720865` | `10189336662765720865` | 16056 | 16056 | +0 |
| saturating_sensor | PASS | `949377728748136091` | `949377728748136091` | 16064 | 16064 | +0 |
| select_ranges | PASS | `7998733617250549699` | `7998733617250549699` | 16056 | 16056 | +0 |
| sensor_bucket | PASS | `14903144236978763942` | `14903144236978763942` | 16056 | 16056 | +0 |
| signed_delta_pair | PASS | `2956207696096966770` | `2956207696096966770` | 16064 | 16064 | +0 |
| signed_offsets | PASS | `10128374022974651990` | `10128374022974651990` | 16056 | 16056 | +0 |
| signed_select_offsets | PASS | `14233097682603816881` | `14233097682603816881` | 16072 | 16072 | +0 |
| signed_state_delta | PASS | `7258950473545215491` | `7258950473545215491` | 16064 | 16064 | +0 |
| small_state_machine | PASS | `13486108852676906275` | `13486108852676906275` | 16072 | 16072 | +0 |
| status_flags | PASS | `14382830793877550248` | `14382830793877550248` | 16056 | 16056 | +0 |
| tcp_flag_decode | PASS | `4057542403704604356` | `4057542403704604356` | 16064 | 16064 | +0 |
| unsigned_histogram | PASS | `11103202929777246947` | `11103202929777246947` | 16064 | 16064 | +0 |
| volatile_reject | PASS | `720025746448504742` | `720025746448504742` | 16064 | 16064 | +0 |
| wide_unknown_reject | PASS | `12959593850123480699` | `12959593850123480699` | 16072 | 16072 | +0 |

Binary sizes are host- and toolchain-specific executable file sizes. They are reported as generated-artifact evidence, not as runtime-memory or performance measurements.
