#include <stdio.h>
#include <stdint.h>
#include "/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/benchmarks/small_state_machine.c"
int main(void) {
  unsigned long long acc = 1469598103934665603ull;
  #define MIX(v) do { acc ^= (unsigned long long)(unsigned int)(v); acc *= 1099511628211ull; } while (0)
  for (unsigned s = 0; s < 64; s += 3) for (unsigned e = 0; e < 16; e += 2) MIX(small_state_machine(s, e));
  printf("%llu\n", acc);
  return 0;
}
