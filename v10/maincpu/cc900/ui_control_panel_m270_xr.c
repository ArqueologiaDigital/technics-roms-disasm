/* Functions of ui/ui_control_panel.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/
/* cc900-module: ApTaskControl ClearAllSongSlots Composer_GetPassword FDC_CMD_SEND FindFirstEmptySlot SOME_DELAY */   /* scripts/analysis/cc900/module_calls.py v10 */

extern int ram_3ef4e;
extern void KeyScan_Enable(void);
extern void ApTaskControl(long, long, long);
#define EVT_SLEEP_MAIN_TASK 0x1e000acL
#define NAKA_APFUNC_ApTaskControl 0x120000bL
extern void SleepMainTask(void);
extern long ApPostEvent(long, long, long);
#define EVT_ALL_PAINT 0x1c0000aL
extern void UI_PostRefreshEvent(void);

void KeyScan_Enable(void)
{
  ram_3ef4e = 1;
}

void SleepMainTask(void)
{
  ApTaskControl(NAKA_APFUNC_ApTaskControl, EVT_SLEEP_MAIN_TASK, 0L);
}

void UI_PostRefreshEvent(void)
{
  ApPostEvent(-1L, EVT_ALL_PAINT, 0L);
}
