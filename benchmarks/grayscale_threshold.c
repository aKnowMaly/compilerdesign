unsigned grayscale_threshold(unsigned p0, unsigned p1, unsigned p2, unsigned p3) {
  unsigned short pix[4];
  pix[0] = (unsigned short)(p0 & 255u);
  pix[1] = (unsigned short)(p1 & 255u);
  pix[2] = (unsigned short)(p2 & 255u);
  pix[3] = (unsigned short)(p3 & 255u);
  return (pix[0] > 127u) + (pix[1] > 127u) + (pix[2] > 127u) + (pix[3] > 127u);
}

