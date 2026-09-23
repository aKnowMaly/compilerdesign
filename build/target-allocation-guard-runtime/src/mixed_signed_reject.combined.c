#include <stdio.h>
#include <stdint.h>
#include "/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/benchmarks/mixed_signed_reject.c"
int main(void) {
  unsigned long long acc = 1469598103934665603ull;
  #define MIX(v) do { acc ^= (unsigned long long)(unsigned int)(v); acc *= 1099511628211ull; } while (0)
  for (int a = -64; a <= 63; a += 17) for (unsigned b = 0; b < 255; b += 29) for (int c = 0; c < 2; ++c) MIX((int)mixed_signed_reject((signed char)a, (unsigned char)b, c));
  printf("%llu\n", acc);
  return 0;
}
