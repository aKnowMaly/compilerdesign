unsigned sensor_bucket(unsigned raw) {
  unsigned short bucket[2];
  bucket[0] = (unsigned short)(raw & 1023u);
  bucket[1] = (unsigned short)((bucket[0] >> 5) & 31u);
  return bucket[1];
}

