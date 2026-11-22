/* helper U, round 21r1, module 270, form b: UI_Post* with an int parameter and an (unsigned char) cast; the switch
   of ResetSlotsIfEmpty with a return in case 0 and the call after it; BoxLeftCheck through a result local;
   _Read_VGA_Register with the pointer advanced before the read. */
/* cc900-module: ClearAllSongSlots FindFirstEmptySlot */

extern long ApPostEvent(long, long, long);
extern int FindFirstEmptySlot(void);
extern void ClearAllSongSlots(void);

#define EVT_AICEN_SET 0x1e0006eL
#define EVT_VALEN_SET 0x1e0006fL
#define EVT_EDIT_UP_SET 0x1e00071L

void UI_PostDialEnable(int v)
{
  ApPostEvent(-1L, EVT_VALEN_SET, (unsigned char)v);
}

void UI_PostEvent_0x6E(int v)
{
  ApPostEvent(-1L, EVT_AICEN_SET, (unsigned char)v);
}

void UI_PostDialValueEvent(int v)
{
  ApPostEvent(-1L, EVT_EDIT_UP_SET, (unsigned char)v);
}

void ResetSlotsIfEmpty(void)
{
  switch (FindFirstEmptySlot()) {
  case 0:
    return;
  }
  ClearAllSongSlots();
}

int BoxLeftCheck(int x)
{
  int r;
  if (x <= 0x88 && x >= 0x80) r = 1;
  else r = 0;
  return r;
}

unsigned char _Read_VGA_Register(unsigned int r)
{
  unsigned char *p;
  p = (unsigned char *)0x170000L;
  p += r;
  return *p;
}
