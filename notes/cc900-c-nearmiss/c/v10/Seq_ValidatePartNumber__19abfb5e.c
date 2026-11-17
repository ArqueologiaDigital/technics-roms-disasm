/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_m11.c (2026-11-16-24-p6-m11)
   sha256 19abfb5e2f4ed04430ff2017b72eeaea87d8ff831acead8c3dea854154bf1dde (name+funcs); compiled at -O3 -XS */
extern unsigned char ram_28a1, ram_42d, ram_42e, PANEL_GM[];
int Seq_ValidatePartNumber(unsigned char a) { if (a < 1 || a > ram_28a1) return -1; return 0; }
