unsigned tcp_flag_decode(unsigned header) {
  unsigned short flags[6];
  flags[0] = (unsigned short)((header >> 0) & 1u);
  flags[1] = (unsigned short)((header >> 1) & 1u);
  flags[2] = (unsigned short)((header >> 2) & 1u);
  flags[3] = (unsigned short)((header >> 3) & 1u);
  flags[4] = (unsigned short)((header >> 4) & 1u);
  flags[5] = (unsigned short)((header >> 5) & 1u);
  return flags[0] + 2u * flags[1] + 3u * flags[2] + 4u * flags[3] + 5u * flags[4] + 6u * flags[5];
}

