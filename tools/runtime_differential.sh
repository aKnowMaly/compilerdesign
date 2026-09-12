#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PLUGIN="$ROOT_DIR/build/AdaptiveWidthMemoryPass.so"
LLVM_DIR="${LLVM_DIR:-/usr/lib/llvm-18/lib/cmake/llvm}"
BENCH_DIR="${1:-$ROOT_DIR/benchmarks}"
OUT_DIR="$ROOT_DIR/build/runtime-differential"
REPORT="$OUT_DIR/runtime-differential.tsv"
SUMMARY="$OUT_DIR/summary.md"

if [[ ! -d "$BENCH_DIR" ]]; then
  echo "benchmark directory not found: $BENCH_DIR" >&2
  exit 1
fi

if [[ ! -f "$ROOT_DIR/build/build.ninja" ]]; then
  cmake -S "$ROOT_DIR" -B "$ROOT_DIR/build" -G Ninja -DLLVM_DIR="$LLVM_DIR"
fi

cmake --build "$ROOT_DIR/build" >/dev/null
mkdir -p "$OUT_DIR/src" "$OUT_DIR/ir" "$OUT_DIR/bin" "$OUT_DIR/logs"

printf 'benchmark\tstatus\tbaseline_output\ttransformed_output\n' > "$REPORT"

emit_harness() {
  local name="$1"
  local source="$2"
  local combined="$OUT_DIR/src/$name.combined.c"

  {
    printf '#include <stdio.h>\n'
    printf '#include <stdint.h>\n'
    printf '#include "%s"\n' "$source"
    if [[ "$name" == "rejection_cases" ]]; then
      printf 'void escape_short_array(unsigned short *p) { if (p) p[1] = (unsigned short)(p[0] ^ 3u); }\n'
    fi
    printf 'int main(void) {\n'
    printf '  unsigned long long acc = 1469598103934665603ull;\n'
    printf '  #define MIX(v) do { acc ^= (unsigned long long)(unsigned int)(v); acc *= 1099511628211ull; } while (0)\n'
    case "$name" in
      global_constants)
        printf '  for (unsigned i = 0; i < 64; ++i) MIX(global_constants());\n'
        ;;
      alpha_blend_weights)
        printf '  for (unsigned i = 0; i < 128; i += 5) MIX(alpha_blend_weights(i * 3u, i * 17u, i * 29u));\n'
        ;;
      alias_pointer_reject)
        printf '  for (unsigned i = 0; i < 128; i += 9) for (int c = 0; c < 2; ++c) MIX(alias_pointer_reject(i * 13u, c));\n'
        ;;
      checksum_nibbles)
        printf '  for (unsigned i = 0; i < 256; i += 7) MIX(checksum_nibbles(i * 0x1111u));\n'
        ;;
      embedded_counters)
        printf '  for (unsigned i = 0; i < 256; i += 11) MIX(embedded_counters(i * 257u));\n'
        ;;
      fir4_coefficients)
        printf '  for (unsigned i = 0; i < 128; i += 13) MIX(fir4_coefficients(i, i * 2u, i * 3u, i * 4u));\n'
        ;;
      global_flag_table)
        printf '  for (unsigned i = 0; i < 32; ++i) MIX(global_flag_table(i));\n'
        ;;
      global_lookup_small)
        printf '  for (unsigned i = 0; i < 64; ++i) MIX(global_lookup_small(i));\n'
        ;;
      grayscale_threshold)
        printf '  for (unsigned i = 0; i < 128; i += 5) MIX(grayscale_threshold(i, i * 2u, i * 3u, i * 4u));\n'
        ;;
      ipv4_header_fields)
        printf '  for (unsigned i = 0; i < 128; i += 7) MIX(ipv4_header_fields(i * 0x1234567u, i * 0x7654321u));\n'
        ;;
      mixed_signed_reject)
        printf '  for (int a = -64; a <= 63; a += 17) for (unsigned b = 0; b < 255; b += 29) for (int c = 0; c < 2; ++c) MIX((int)mixed_signed_reject((signed char)a, (unsigned char)b, c));\n'
        ;;
      moving_average4)
        printf '  for (unsigned i = 0; i < 128; i += 7) MIX(moving_average4(i, i * 3u, i * 5u, i * 7u));\n'
        ;;
      overflow_uncertainty)
        printf '  for (unsigned i = 0; i < 128; i += 7) MIX(overflow_uncertainty(i * 19u, i * 23u));\n'
        ;;
      packet_flags)
        printf '  for (unsigned i = 0; i < 128; i += 7) MIX(packet_flags(i * 2654435761u, i ^ 0x5a5a5a5au));\n'
        ;;
      pixel_channels)
        printf '  for (unsigned i = 0; i < 128; i += 5) MIX(pixel_channels(i * 65793u + 0x80402010u));\n'
        ;;
      protocol_version_table)
        printf '  for (unsigned i = 0; i < 128; i += 9) MIX(protocol_version_table(i * 0x1020304u));\n'
        ;;
      quantized_filter)
        printf '  for (unsigned i = 0; i < 128; i += 5) MIX(quantized_filter(i * 11u, i * 17u));\n'
        ;;
      rejection_cases)
        printf '  for (unsigned i = 0; i < 128; i += 9) MIX(rejection_cases(i * 37u + 11u));\n'
        ;;
      rgb565_unpack)
        printf '  for (unsigned i = 0; i < 65536; i += 4093) MIX(rgb565_unpack(i));\n'
        ;;
      select_ranges)
        printf '  for (unsigned i = 0; i < 128; i += 11) for (int c = 0; c < 2; ++c) MIX(select_ranges(i * 13u, i * 17u + 3u, c));\n'
        ;;
      saturating_sensor)
        printf '  for (unsigned i = 0; i < 1024; i += 37) MIX(saturating_sensor(i * 13u));\n'
        ;;
      sensor_bucket)
        printf '  for (unsigned i = 0; i < 1024; i += 29) MIX(sensor_bucket(i * 17u));\n'
        ;;
      signed_offsets)
        printf '  for (int a = -96; a <= 96; a += 31) for (int b = -80; b <= 80; b += 29) for (int c = 0; c < 2; ++c) MIX((int)signed_offsets((signed char)a, (signed char)b, c));\n'
        ;;
      signed_delta_pair)
        printf '  for (int a = -96; a <= 96; a += 31) for (int b = -80; b <= 80; b += 29) MIX((int)signed_delta_pair((signed char)a, (signed char)b));\n'
        ;;
      signed_select_offsets)
        printf '  for (int a = -96; a <= 96; a += 31) for (int b = -80; b <= 80; b += 29) for (int c = 0; c < 2; ++c) MIX((int)signed_select_offsets((signed char)a, (signed char)b, c));\n'
        ;;
      signed_state_delta)
        printf '  for (int a = -64; a <= 64; a += 17) for (int b = -64; b <= 64; b += 19) for (int c = 0; c < 2; ++c) MIX((int)signed_state_delta((signed char)a, (signed char)b, c));\n'
        ;;
      small_state_machine)
        printf '  for (unsigned s = 0; s < 64; s += 3) for (unsigned e = 0; e < 16; e += 2) MIX(small_state_machine(s, e));\n'
        ;;
      status_flags)
        printf '  for (unsigned i = 0; i < 128; i += 3) MIX(status_flags(i));\n'
        ;;
      tcp_flag_decode)
        printf '  for (unsigned i = 0; i < 128; i += 5) MIX(tcp_flag_decode(i));\n'
        ;;
      unsigned_histogram)
        printf '  unsigned data[4];\n'
        printf '  for (unsigned i = 0; i < 128; i += 13) { data[0] = i; data[1] = i * 3u; data[2] = i * 5u; data[3] = i * 7u; MIX(unsigned_histogram(data, 4)); }\n'
        ;;
      volatile_reject)
        printf '  for (unsigned i = 0; i < 128; i += 7) MIX(volatile_reject(i * 31u));\n'
        ;;
      wide_unknown_reject)
        printf '  for (unsigned i = 0; i < 128; i += 7) MIX(wide_unknown_reject(i * 41u + 19u));\n'
        ;;
      *)
        printf '  return 77;\n'
        ;;
    esac
    printf '  printf("%%llu\\n", acc);\n'
    printf '  return 0;\n'
    printf '}\n'
  } > "$combined"
}

run_one() {
  local source="$1"
  local name
  name="$(basename "$source" .c)"
  local combined="$OUT_DIR/src/$name.combined.c"
  local raw_ir="$OUT_DIR/ir/$name.raw.ll"
  local input_ir="$OUT_DIR/ir/$name.ll"
  local transformed_ir="$OUT_DIR/ir/$name.transformed.ll"
  local baseline_bin="$OUT_DIR/bin/$name.baseline"
  local transformed_bin="$OUT_DIR/bin/$name.transformed"
  local log="$OUT_DIR/logs/$name.log"

  emit_harness "$name" "$source"
  clang-18 -O0 -S -emit-llvm -Xclang -disable-O0-optnone "$combined" -o "$raw_ir"
  opt-18 -passes=mem2reg -S "$raw_ir" -o "$input_ir"
  opt-18 -load-pass-plugin="$PLUGIN" -passes=adaptive-width-mem \
    -verify-each -S "$input_ir" -o "$transformed_ir" 2> "$log"
  opt-18 -passes=verify -disable-output "$transformed_ir"

  clang-18 "$input_ir" -O2 -Wno-override-module -o "$baseline_bin"
  clang-18 "$transformed_ir" -O2 -Wno-override-module -o "$transformed_bin"

  local baseline_output transformed_output status
  baseline_output="$("$baseline_bin")"
  transformed_output="$("$transformed_bin")"
  if [[ "$baseline_output" == "$transformed_output" ]]; then
    status="PASS"
  else
    status="FAIL"
  fi

  printf '%s\t%s\t%s\t%s\n' "$name" "$status" "$baseline_output" "$transformed_output" >> "$REPORT"
  [[ "$status" == "PASS" ]]
}

shopt -s nullglob
sources=("$BENCH_DIR"/*.c)
if [[ "${#sources[@]}" -eq 0 ]]; then
  echo "no .c benchmarks found in $BENCH_DIR" >&2
  exit 1
fi

for source in "${sources[@]}"; do
  run_one "$source"
done

awk -F '\t' '
NR == 1 { next }
{
  total += 1
  if ($2 == "PASS")
    passed += 1
  else
    failed += 1
  rows = rows sprintf("| %s | %s | `%s` | `%s` |\n", $1, $2, $3, $4)
}
END {
  print "# Runtime Differential Test Summary"
  print ""
  print "| metric | value |"
  print "|---|---:|"
  printf "| benchmark executables | %d |\n", total
  printf "| passed | %d |\n", passed
  printf "| failed | %d |\n", failed
  print ""
  print "## Per-benchmark outputs"
  print ""
  print "| benchmark | status | baseline output | transformed output |"
  print "|---|---|---:|---:|"
  printf "%s", rows
}
' "$REPORT" > "$SUMMARY"

printf 'summary=%s\n' "$SUMMARY"
printf 'report=%s\n' "$REPORT"
printf 'ir=%s\n' "$OUT_DIR/ir"
printf 'bin=%s\n' "$OUT_DIR/bin"
printf 'logs=%s\n' "$OUT_DIR/logs"
