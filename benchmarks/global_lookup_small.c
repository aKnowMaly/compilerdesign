static unsigned short small_lut[4] = {2u, 4u, 6u, 8u};

unsigned global_lookup_small(unsigned idx) {
  return small_lut[idx & 3u];
}

