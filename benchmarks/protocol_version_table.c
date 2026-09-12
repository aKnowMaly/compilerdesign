unsigned protocol_version_table(unsigned header) {
  unsigned short v[3];
  v[0] = (unsigned short)((header >> 29) & 7u);
  v[1] = (unsigned short)((header >> 24) & 31u);
  v[2] = (unsigned short)((v[0] | v[1]) & 31u);
  return v[0] + v[1] + v[2];
}

