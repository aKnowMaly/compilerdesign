#include <stdio.h>
#include <stdint.h>
#include "/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/benchmarks/signed_state_delta.c"
int main(void) {
  unsigned long long acc = 1469598103934665603ull;
  #define MIX(v) do { acc ^= (unsigned long long)(unsigned int)(v); acc *= 1099511628211ull; } while (0)
  for (int a = -64; a <= 64; a += 17) for (int b = -64; b <= 64; b += 19) for (int c = 0; c < 2; ++c) MIX((int)signed_state_delta((signed char)a, (signed char)b, c));
  printf("%llu\n", acc);
  return 0;
}
