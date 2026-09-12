unsigned rgb565_unpack(unsigned packed) {
  unsigned short c[3];
  c[0] = (unsigned short)((packed >> 11) & 31u);
  c[1] = (unsigned short)((packed >> 5) & 63u);
  c[2] = (unsigned short)(packed & 31u);
  return c[0] * 3u + c[1] * 5u + c[2] * 7u;
}

