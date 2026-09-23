#include <stdio.h>
#include <stdint.h>
#include "/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/benchmarks/unsigned_histogram.c"
int main(void) {
  unsigned long long acc = 1469598103934665603ull;
  #define MIX(v) do { acc ^= (unsigned long long)(unsigned int)(v); acc *= 1099511628211ull; } while (0)
  unsigned data[4];
  for (unsigned i = 0; i < 128; i += 13) { data[0] = i; data[1] = i * 3u; data[2] = i * 5u; data[3] = i * 7u; MIX(unsigned_histogram(data, 4)); }
  printf("%llu\n", acc);
  return 0;
}
