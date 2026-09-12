extern void escape_short_array(unsigned short *);

unsigned rejection_cases(unsigned x) {
  unsigned short escaped[2];
  unsigned short unknown[2];
  unsigned short mixed[2];

  unsigned short narrowed = (unsigned short)(x & 31u);
  signed char signed_byte = (signed char)x;
  unsigned char unsigned_byte = (unsigned char)x;

  escaped[0] = narrowed;
  escape_short_array(escaped);

  unknown[0] = (unsigned short)(x + 257u);
  mixed[0] = x & 1u ? (short)signed_byte : (unsigned short)unsigned_byte;

  return escaped[0] + unknown[0] + mixed[0];
}

