short signed_offsets(signed char a, signed char b, int choose_a) {
  short offsets[2];
  short first = (short)a;
  short second = (short)b;
  offsets[0] = first;
  offsets[1] = second;

  return choose_a ? offsets[0] : offsets[1];
}

