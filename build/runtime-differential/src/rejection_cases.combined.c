#include <stdio.h>
#include <stdint.h>
#include "/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/benchmarks/rejection_cases.c"
void escape_short_array(unsigned short *p) { if (p) p[1] = (unsigned short)(p[0] ^ 3u); }
int main(void) {
  unsigned long long acc = 1469598103934665603ull;
  #define MIX(v) do { acc ^= (unsigned long long)(unsigned int)(v); acc *= 1099511628211ull; } while (0)
  for (unsigned i = 0; i < 128; i += 9) MIX(rejection_cases(i * 37u + 11u));
  printf("%llu\n", acc);
  return 0;
}
