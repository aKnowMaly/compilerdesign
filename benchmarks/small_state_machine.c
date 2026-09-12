unsigned small_state_machine(unsigned state, unsigned event) {
  unsigned short trace[3];
  trace[0] = (unsigned short)(state & 7u);
  trace[1] = (unsigned short)(event & 3u);
  trace[2] = (unsigned short)((trace[0] | trace[1]) & 7u);
  return trace[2];
}

