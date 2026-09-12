unsigned select_ranges(unsigned x, unsigned y, int choose_x) {
  unsigned short selected[2];
  unsigned short a = (unsigned short)(x & 63u);
  unsigned short b = (unsigned short)(y & 31u);
  selected[0] = choose_x ? a : b;
  selected[1] = choose_x ? b : a;
  return selected[0] + selected[1];
}

