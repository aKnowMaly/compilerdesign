short signed_state_delta(signed char old_state, signed char new_state, int choose_new) {
  short states[2];
  states[0] = (short)old_state;
  states[1] = choose_new ? (short)new_state : (short)old_state;
  return states[1] - states[0];
}

