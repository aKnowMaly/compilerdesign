static unsigned small_global = 7u;
static unsigned char flag_byte = 0u;

unsigned use_globals(void) {
  return small_global + flag_byte;
}
