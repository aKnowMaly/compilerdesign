#include <stdio.h>
#include <stdint.h>
#include "/mnt/c/Users/admin/Documents/ChatGPT/compilerdesign/benchmarks/tcp_flag_decode.c"
int main(void) {
  unsigned long long acc = 1469598103934665603ull;
  #define MIX(v) do { acc ^= (unsigned long long)(unsigned int)(v); acc *= 1099511628211ull; } while (0)
  for (unsigned i = 0; i < 128; i += 5) MIX(tcp_flag_decode(i));
  printf("%llu\n", acc);
  return 0;
}
