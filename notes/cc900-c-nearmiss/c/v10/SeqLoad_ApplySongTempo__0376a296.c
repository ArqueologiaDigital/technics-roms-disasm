/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_4b.c (2026-11-16-40-p6-r8)
   sha256 0376a2964c573ce15297eb22e016ddee3a48777d9bcdc1cb9292bc07c50265c4 (tar-sha256); compiled at -O3 -XS -Xr */
extern unsigned char Part_ReadByteDirect(int, int);
extern unsigned char __near PANEL_STYLE[];
extern unsigned char __near ram_f460[];
void SeqLoad_ApplySongTempo(void)
{
  unsigned char *s, *t;
  unsigned int o;
  unsigned char v;
  if (Part_ReadByteDirect(0, 5) != 1) return;
  v = Part_ReadByteDirect(0, 6);
  if (v != 7 && v != 8) return;
  s = PANEL_STYLE;
  t = s + 8;
  o = t - (unsigned char *)0xf980;
  *t = ram_f460[o];
  s[9] = ram_f460[o + 1];
}
