/* helper Q, round 20r1, module 270 (ui/ui_control_panel.s, storage/fdc_routines.s, file_io/medley.s): dial / refresh
   event posts, FDC port bits, composer password, line helper. */
/* cc900-module: ApTaskControl ClearAllSongSlots Composer_GetPassword FDC_CMD_SEND FindFirstEmptySlot SOME_DELAY */

struct pt { int x, y; };

extern unsigned char __tiny PD;
extern unsigned char __tiny PA;
extern unsigned char __near FDC_ERROR_CODE;
extern int ram_3ef4e;
extern unsigned int ram_9480e;

extern long ApPostEvent(long, long, long);
extern void ApTaskControl(long, long, long);
extern void DrawLine(struct pt *, struct pt *, int);
extern void SOME_DELAY(int);
extern void FDC_CMD_SEND(int);
extern int FindFirstEmptySlot(void);
extern void ClearAllSongSlots(void);
extern int Composer_GetPassword(void);

#define EVT_ALL_PAINT 0x1c0000aL
#define EVT_AICEN_SET 0x1e0006eL
#define EVT_VALEN_SET 0x1e0006fL
#define EVT_EDIT_UP_SET 0x1e00071L
#define EVT_SLEEP_MAIN_TASK 0x1e000acL
#define NAKA_APFUNC_ApTaskControl 0x120000bL

void DrawLineHelper(struct pt *a, struct pt *b, int c, int swap)
{
  struct pt p1;
  struct pt p2;
  if (swap != 0) {
    p1.x = a->y;
    p1.y = a->x;
    p2.x = b->y;
    p2.y = b->x;
    a = &p1;
    b = &p2;
  }
  DrawLine(a, b, c);
}

void UI_PostDialEnable(unsigned char v)
{
  ApPostEvent(-1L, EVT_VALEN_SET, (unsigned int)v);
}

void UI_PostEvent_0x6E(unsigned char v)
{
  ApPostEvent(-1L, EVT_AICEN_SET, (unsigned int)v);
}

void UI_PostDialValueEvent(unsigned char v)
{
  ApPostEvent(-1L, EVT_EDIT_UP_SET, (unsigned int)v);
}

void UI_PostRefreshEvent(void)
{
  ApPostEvent(-1L, EVT_ALL_PAINT, 0L);
}

void SleepMainTask(void)
{
  ApTaskControl(NAKA_APFUNC_ApTaskControl, EVT_SLEEP_MAIN_TASK, 0L);
}

void FDC_PulseResetLine(void)
{
  PD |= 0x01;
  SOME_DELAY(10);
  PD &= ~0x01;
  SOME_DELAY(10);
}

unsigned char Check_for_Floppy_Disk_Change(void)
{
  if (PD & 0x40) return 0;
  return 1;
}

void ResetSlotsIfEmpty(void)
{
  int s;
  s = FindFirstEmptySlot();
  if (s != 0)
    ClearAllSongSlots();
}

void FDC_CMD_DISABLE(void)
{
  PA &= ~0x08;
  FDC_CMD_SEND(14);
}

void KeyScan_Enable(void)
{
  ram_3ef4e = 1;
}

int Composer_HasPassword(void)
{
  return Composer_GetPassword() != 0;
}

void FDC_ClearStatus_InitTimer(void)
{
  FDC_ERROR_CODE = 0;
}

void Composer_SetPassword(unsigned int pw)
{
  ram_9480e = pw;
}
