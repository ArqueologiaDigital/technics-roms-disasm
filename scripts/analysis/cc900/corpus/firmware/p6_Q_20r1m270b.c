/* helper Q, round 20r1, module 270, form b: the line helper as if / else with two calls; the dial posts through
   an int local (form a: a cast in the argument); the disk-change test as ?:. */
/* cc900-module: ClearAllSongSlots FindFirstEmptySlot */

struct pt { int x, y; };

extern unsigned char __tiny PD;
extern long ApPostEvent(long, long, long);
extern void DrawLine(struct pt *, struct pt *, int);
extern int FindFirstEmptySlot(void);
extern void ClearAllSongSlots(void);

#define EVT_AICEN_SET 0x1e0006eL
#define EVT_VALEN_SET 0x1e0006fL
#define EVT_EDIT_UP_SET 0x1e00071L

void DrawLineHelper(struct pt *a, struct pt *b, int c, int swap)
{
  struct pt p1;
  struct pt p2;
  if (swap != 0) {
    p1.x = a->y;
    p1.y = a->x;
    p2.x = b->y;
    p2.y = b->x;
    DrawLine(&p1, &p2, c);
  } else
    DrawLine(a, b, c);
}

void UI_PostDialEnable(unsigned char v)
{
  unsigned int w;
  w = v;
  ApPostEvent(-1L, EVT_VALEN_SET, w);
}

void UI_PostEvent_0x6E(unsigned char v)
{
  unsigned int w;
  w = v;
  ApPostEvent(-1L, EVT_AICEN_SET, w);
}

void UI_PostDialValueEvent(unsigned char v)
{
  unsigned int w;
  w = v;
  ApPostEvent(-1L, EVT_EDIT_UP_SET, w);
}

unsigned char Check_for_Floppy_Disk_Change(void)
{
  return (PD & 0x40) ? 0 : 1;
}

void ResetSlotsIfEmpty(void)
{
  if (FindFirstEmptySlot() == 0) return;
  ClearAllSongSlots();
}
