unsigned volatile_reject(unsigned x) {
  volatile unsigned short values[2];
  values[0] = (unsigned short)(x & 31u);
  values[1] = values[0];
  return values[1];
}

