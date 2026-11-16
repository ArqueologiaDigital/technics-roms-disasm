/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_7b.c (2026-11-16-53-p6-r11)
   sha256 055bb165f17e4ada5d5cffdf53f6b5255200d3f65d0bb47ed27a1f253a00f0f7 (tar-sha256); compiled at -O3 -Xr */
extern unsigned char Part_ReadByteDirect(unsigned char, unsigned int);
extern unsigned char __near PANEL_STYLE[];
extern unsigned char __near ram_f460[];
void SeqLoad_ApplySongTempo(void)
{
  unsigned char *t, *s;
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
