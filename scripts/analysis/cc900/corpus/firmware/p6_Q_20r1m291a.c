/* helper Q, round 20r1, module 291 (audio/dsp_config_sysex.s): four-byte event writers of the SWBT queues. */

extern unsigned int __near SWBTWR_WRITE_INDEX;
extern unsigned char __near SWBTWR_EVENT_QUEUE[];
extern unsigned char __near PANEL_EVENT_QUEUE[];

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
  unsigned char *p;
  unsigned char *end;
  p = PANEL_EVENT_QUEUE;
  end = PANEL_EVENT_QUEUE + 60;
  while (*p != 0xff)
    p += 4;
  if (p >= end) return;
  *p++ = a;
  *p++ = c;
  *p++ = e;
  *p++ = d;
  *p = 0xff;
}
