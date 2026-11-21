/* Functions of audio/dsp_config_sysex.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/

extern unsigned int __near SWBTWR_WRITE_INDEX;
extern unsigned char __near SWBTWR_EVENT_QUEUE[];
extern void AssswbWr(unsigned char a, unsigned char c, unsigned char e, unsigned char d);
extern unsigned char __near PANEL_EVENT_QUEUE[];
extern void SwbtWr(unsigned char a, unsigned char c, unsigned char e, unsigned char d);

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

void SwbtWr(unsigned char a, unsigned char c, unsigned char e, unsigned char d)
{
  unsigned char *q;
  unsigned char *p;
  unsigned char *end;
  q = PANEL_EVENT_QUEUE;
  p = q;
  end = q + 60;
  if (*q != 0xff) {
    do
      p += 4;
    while (*p != 0xff);
  }
  if (p >= end) return;
  *p++ = a;
  *p++ = c;
  *p++ = e;
  *p++ = d;
  *p = 0xff;
}
