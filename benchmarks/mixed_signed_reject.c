short mixed_signed_reject(signed char a, unsigned char b, int choose_a) {
  short values[2];
  short signed_value = (short)a;
  unsigned short unsigned_value = (unsigned short)b;
  values[0] = choose_a ? signed_value : (short)unsigned_value;
  values[1] = values[0];
  return values[1];
}

