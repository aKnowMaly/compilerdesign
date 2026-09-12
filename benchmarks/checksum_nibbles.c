unsigned checksum_nibbles(unsigned word) {
  unsigned short n[4];
  n[0] = (unsigned short)(word & 15u);
  n[1] = (unsigned short)((word >> 4) & 15u);
  n[2] = (unsigned short)((word >> 8) & 15u);
  n[3] = (unsigned short)((word >> 12) & 15u);
  return n[0] + n[1] + n[2] + n[3];
}

