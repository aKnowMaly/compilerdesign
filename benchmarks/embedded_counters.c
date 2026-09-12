unsigned embedded_counters(unsigned events) {
  unsigned short counters[4];
  counters[0] = (unsigned short)(events & 15u);
  counters[1] = (unsigned short)((events >> 4) & 15u);
  counters[2] = (unsigned short)((events >> 8) & 15u);
  counters[3] = (unsigned short)((counters[0] + counters[1] + counters[2]) & 31u);
  return counters[3];
}

