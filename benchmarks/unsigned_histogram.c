static unsigned short bins[4] = {1u, 3u, 7u, 15u};

unsigned unsigned_histogram(unsigned *input, unsigned n) {
  unsigned short local[4];
  local[0] = (unsigned short)(input[0] & 15u);
  local[1] = (unsigned short)(input[1] & 31u);
  local[2] = (unsigned short)(input[2] & 63u);
  local[3] = (unsigned short)(input[3] & 127u);

  unsigned total = 0;
  for (unsigned i = 0; i < 4 && i < n; ++i)
    total += local[i] + bins[i];

  return total;
}

