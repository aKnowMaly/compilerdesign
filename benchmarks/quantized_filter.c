unsigned quantized_filter(unsigned x, unsigned y) {
  unsigned short q[3];
  q[0] = (unsigned short)(x & 63u);
  q[1] = (unsigned short)(y & 63u);
  q[2] = (unsigned short)((q[0] + q[1]) & 127u);
  return q[2];
}

