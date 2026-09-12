unsigned saturating_sensor(unsigned raw) {
  unsigned short s[2];
  unsigned v = raw & 511u;
  s[0] = (unsigned short)v;
  s[1] = (unsigned short)(v > 255u ? 255u : v);
  return s[0] + s[1];
}

