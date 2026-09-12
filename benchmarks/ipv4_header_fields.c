unsigned ipv4_header_fields(unsigned word0, unsigned word1) {
  unsigned short f[4];
  f[0] = (unsigned short)((word0 >> 28) & 15u);
  f[1] = (unsigned short)((word0 >> 24) & 15u);
  f[2] = (unsigned short)(word0 & 255u);
  f[3] = (unsigned short)((word1 >> 16) & 63u);
  return f[0] + f[1] + f[2] + f[3];
}

