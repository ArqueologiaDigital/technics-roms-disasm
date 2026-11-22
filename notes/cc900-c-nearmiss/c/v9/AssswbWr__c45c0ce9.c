/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/dsp_config_sysex_m291.c (2026-11-21-5-p6-r60)
   sha256 c45c0ce9f0e3a0d04d98da62d391775f76f9edfb9053d19e4da30e31d4aa81d6 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern unsigned int __near SWBTWR_WRITE_INDEX;
extern unsigned char __near SWBTWR_EVENT_QUEUE[];
void AssswbWr(unsigned char a, unsigned char c, unsigned char e, unsigned char d)
{
  unsigned char *p;
  unsigned int i;
  i = SWBTWR_WRITE_INDEX;
  if (i >= 0x1fc) return;
  p = SWBTWR_EVENT_QUEUE + i;
  *p++ = a;
  *p++ = c;
  *p++ = e;
  *p++ = d;
  *p = 0xff;
  SWBTWR_WRITE_INDEX += 4;
}
