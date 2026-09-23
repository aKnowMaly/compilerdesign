#include <stdio.h>
#include <stdint.h>
#include "/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/benchmarks/grayscale_threshold.c"
int main(void) {
  unsigned long long acc = 1469598103934665603ull;
  #define MIX(v) do { acc ^= (unsigned long long)(unsigned int)(v); acc *= 1099511628211ull; } while (0)
  for (unsigned i = 0; i < 128; i += 5) MIX(grayscale_threshold(i, i * 2u, i * 3u, i * 4u));
  printf("%llu\n", acc);
  return 0;
}
