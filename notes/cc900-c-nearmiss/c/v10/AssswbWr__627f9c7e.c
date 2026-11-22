/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_Q_20r1m291a.c (2026-11-21-2-p6-r58)
   sha256 627f9c7ea9eecb3760b0457c56cb1e66e3873ec0ea2168c7d281ea9b26b584b9 (tar-sha256); compiled at -Xr */
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
