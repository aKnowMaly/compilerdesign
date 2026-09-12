unsigned overflow_uncertainty(unsigned x, unsigned y) {
  unsigned short values[2];
  unsigned short a = (unsigned short)(x & 255u);
  unsigned short b = (unsigned short)(y & 255u);
  values[0] = (unsigned short)(a + b);
  values[1] = values[0];
  return values[1];
}
