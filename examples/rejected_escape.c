extern void escape(unsigned short *);

unsigned rejected_escape(unsigned x) {
  unsigned short values[2];
  values[0] = (unsigned short)(x & 31u);
  escape(values);
  return values[0];
}
