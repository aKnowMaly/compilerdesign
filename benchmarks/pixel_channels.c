unsigned pixel_channels(unsigned rgba) {
  unsigned short channels[4];
  channels[0] = (unsigned short)(rgba & 255u);
  channels[1] = (unsigned short)((rgba >> 8) & 255u);
  channels[2] = (unsigned short)((rgba >> 16) & 255u);
  channels[3] = (unsigned short)((rgba >> 24) & 255u);
  return channels[0] + channels[1] + channels[2] + channels[3];
}

