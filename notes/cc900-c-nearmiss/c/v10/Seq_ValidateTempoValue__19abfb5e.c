/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_m11.c (2026-11-16-24-p6-m11)
   sha256 19abfb5e2f4ed04430ff2017b72eeaea87d8ff831acead8c3dea854154bf1dde (name+funcs); compiled at -O3 -XS */
int Seq_ValidateTempoValue(unsigned int t) { if (t < 1 || t > 999) return -1; return 0; }
