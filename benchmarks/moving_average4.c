unsigned moving_average4(unsigned a, unsigned b, unsigned c, unsigned d) {
  unsigned short samples[4];
  samples[0] = (unsigned short)(a & 1023u);
  samples[1] = (unsigned short)(b & 1023u);
  samples[2] = (unsigned short)(c & 1023u);
  samples[3] = (unsigned short)(d & 1023u);
  return (samples[0] + samples[1] + samples[2] + samples[3]) >> 2;
}

