#include <stdio.h>
#include <stdint.h>
#include "/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/benchmarks/alias_pointer_reject.c"
int main(void) {
  unsigned long long acc = 1469598103934665603ull;
  #define MIX(v) do { acc ^= (unsigned long long)(unsigned int)(v); acc *= 1099511628211ull; } while (0)
  for (unsigned i = 0; i < 128; i += 9) for (int c = 0; c < 2; ++c) MIX(alias_pointer_reject(i * 13u, c));
  printf("%llu\n", acc);
  return 0;
}
