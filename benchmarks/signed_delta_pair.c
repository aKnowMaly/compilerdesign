short signed_delta_pair(signed char a, signed char b) {
  short d[2];
  d[0] = (short)a;
  d[1] = (short)b;
  return d[0] - d[1];
}

