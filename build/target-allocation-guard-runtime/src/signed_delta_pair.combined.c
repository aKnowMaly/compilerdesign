#include <stdio.h>
#include <stdint.h>
#include "/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/benchmarks/signed_delta_pair.c"
int main(void) {
  unsigned long long acc = 1469598103934665603ull;
  #define MIX(v) do { acc ^= (unsigned long long)(unsigned int)(v); acc *= 1099511628211ull; } while (0)
  for (int a = -96; a <= 96; a += 31) for (int b = -80; b <= 80; b += 29) MIX((int)signed_delta_pair((signed char)a, (signed char)b));
  printf("%llu\n", acc);
  return 0;
}
