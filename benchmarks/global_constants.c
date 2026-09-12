static unsigned short lut_a = 5u;
static unsigned short lut_b = 12u;
static unsigned short lut_c[2] = {3u, 9u};

unsigned global_constants(void) {
  return lut_a + lut_b + lut_c[0] + lut_c[1];
}

