unsigned masked_stack(unsigned x) {
  unsigned short values[2];
  values[0] = (unsigned short)(x & 31u);
  return values[0] + 1u;
}
