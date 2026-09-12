unsigned alias_pointer_reject(unsigned x, int choose_second) {
  unsigned short values[2];
  unsigned short *p = choose_second ? &values[1] : &values[0];
  *p = (unsigned short)(x & 31u);
  return values[choose_second ? 1 : 0];
}

