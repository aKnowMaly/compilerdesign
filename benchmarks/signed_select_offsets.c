short signed_select_offsets(signed char a, signed char b, int choose_a) {
  short values[3];
  short first = (short)a;
  short second = (short)b;
  values[0] = choose_a ? first : second;
  values[1] = choose_a ? second : first;
  values[2] = values[0];
  return values[1] + values[2];
}

