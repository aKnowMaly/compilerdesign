unsigned fir4_coefficients(unsigned x0, unsigned x1, unsigned x2, unsigned x3) {
  unsigned short c[4];
  c[0] = 1u;
  c[1] = 3u;
  c[2] = 5u;
  c[3] = 7u;
  return (x0 & 255u) * c[0] + (x1 & 255u) * c[1] + (x2 & 255u) * c[2] + (x3 & 255u) * c[3];
}

