unsigned wide_unknown_reject(unsigned x) {
  unsigned short values[2];
  values[0] = (unsigned short)(x + 1025u);
  values[1] = (unsigned short)(x ^ 257u);
  return values[0] + values[1];
}
