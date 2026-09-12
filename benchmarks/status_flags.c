unsigned status_flags(unsigned status) {
  unsigned short flags[3];
  flags[0] = (unsigned short)(status & 1u);
  flags[1] = (unsigned short)((status >> 1) & 3u);
  flags[2] = (unsigned short)((status >> 3) & 7u);
  return flags[0] | (flags[1] << 1) | (flags[2] << 3);
}

