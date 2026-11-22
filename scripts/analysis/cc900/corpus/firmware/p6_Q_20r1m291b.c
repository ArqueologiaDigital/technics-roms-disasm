/* helper Q, round 20r1, module 291, form b: the queue index re-read from a volatile cell; the scan as a do-while
   after a first test. */

extern volatile unsigned int __near SWBTWR_WRITE_INDEX;
extern unsigned char __near SWBTWR_EVENT_QUEUE[];
extern unsigned char __near PANEL_EVENT_QUEUE[];

void AssswbWr(unsigned char a, unsigned char c, unsigned char e, unsigned char d)
{
  unsigned char *p;
  if (SWBTWR_WRITE_INDEX >= 0x1fc) return;
  p = &SWBTWR_EVENT_QUEUE[SWBTWR_WRITE_INDEX];
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
