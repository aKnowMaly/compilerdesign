unsigned alpha_blend_weights(unsigned alpha, unsigned src, unsigned dst) {
  unsigned short w[3];
  w[0] = (unsigned short)(alpha & 255u);
  w[1] = (unsigned short)(src & 255u);
  w[2] = (unsigned short)(dst & 255u);
  return (w[0] * w[1] + (255u - w[0]) * w[2]) >> 8;
}

