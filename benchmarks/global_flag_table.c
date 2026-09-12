static unsigned short flags_a = 1u;
static unsigned short flags_b = 2u;
static unsigned short flags_c = 4u;

unsigned global_flag_table(unsigned mask) {
  return ((mask & 1u) ? flags_a : 0u) |
         ((mask & 2u) ? flags_b : 0u) |
         ((mask & 4u) ? flags_c : 0u);
}

