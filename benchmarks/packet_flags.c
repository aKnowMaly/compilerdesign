unsigned packet_flags(unsigned header, unsigned meta) {
  unsigned short fields[4];
  fields[0] = (unsigned short)(header & 3u);
  fields[1] = (unsigned short)((header >> 2) & 7u);
  fields[2] = (unsigned short)(meta & 15u);
  fields[3] = (unsigned short)((meta >> 4) & 31u);
  return fields[0] + fields[1] + fields[2] + fields[3];
}

