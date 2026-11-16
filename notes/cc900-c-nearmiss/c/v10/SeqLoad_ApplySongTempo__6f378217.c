/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_5a.c (2026-11-16-45-p6-r9)
   sha256 6f3782173ed786acb5b8f0b9571ad10fbd5c29c845f28fb8a50c793a4f9e1a23 (tar-sha256); compiled at -Xr */
extern unsigned char Part_ReadByteDirect(unsigned char, unsigned int);
extern unsigned char __near PANEL_STYLE[];
extern unsigned char __near ram_f460[];
void SeqLoad_ApplySongTempo(void)
{
  unsigned char *s, *q, *t;
  unsigned int o;
  unsigned char v;
  if (Part_ReadByteDirect(0, 5) != 1) return;
  v = Part_ReadByteDirect(0, 6);
  if (v != 7 && v != 8) return;
  s = PANEL_STYLE;
  t = s + 8;
  o = t - (unsigned char *)0xf980;
  q = ram_f460;
  *t = q[o];
  s[9] = q[o + 1];
}
