/* helper U, round 21r1, module 270, form a: one-spot retries of runs r58 / r59.
   UI_Post*: the ROM builds the third argument as `ld e,a; ld d,0; extz xde`, V4.23's shape for a byte EXPRESSION
   widened to long; here the parameter is a word and the argument its (unsigned char) cast.
   ResetSlotsIfEmpty: the ROM moves the result to WA before the test (a switch on the call).
   BoxLeftCheck: the ROM places `return 1` first, so the condition is written as the in-range test.
   _Read_VGA_Register: the base in a pointer local (the ROM's ld xbc, imm; add xbc, xwa). */
/* cc900-module: ClearAllSongSlots FindFirstEmptySlot */

extern long ApPostEvent(long, long, long);
extern int FindFirstEmptySlot(void);
extern void ClearAllSongSlots(void);

#define EVT_AICEN_SET 0x1e0006eL
#define EVT_VALEN_SET 0x1e0006fL
#define EVT_EDIT_UP_SET 0x1e00071L

void UI_PostDialEnable(unsigned int v)
{
  ApPostEvent(-1L, EVT_VALEN_SET, (unsigned char)v);
}

void UI_PostEvent_0x6E(unsigned int v)
{
  ApPostEvent(-1L, EVT_AICEN_SET, (unsigned char)v);
}

void UI_PostDialValueEvent(unsigned int v)
{
  ApPostEvent(-1L, EVT_EDIT_UP_SET, (unsigned char)v);
}

void ResetSlotsIfEmpty(void)
{
  switch (FindFirstEmptySlot()) {
  case 0:
    break;
  default:
    ClearAllSongSlots();
    break;
  }
}

int BoxLeftCheck(int x)
{
  if (x <= 0x88 && x >= 0x80) return 1;
  return 0;
}

unsigned char _Read_VGA_Register(unsigned int r)
{
  unsigned char *p;
  p = (unsigned char *)0x170000L;
  return p[r];
}
