static int clampInt(int v, int min, int max) {
  return v < min ? min : (v > max ? max : v);
}

