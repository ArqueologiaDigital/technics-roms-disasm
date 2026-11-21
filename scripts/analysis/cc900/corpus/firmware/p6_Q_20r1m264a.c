/* helper Q, round 20r1, module 264 (ui/drawbar_panel_ui.s): end-of-song post, main-control start, mixer word array. */

extern unsigned int *ram_3ea34;
extern long ram_3ea30;
extern long ApPostEvent(long, long, long);
extern void MainPreControl(long, long, long);

#define EVT_END_SONG 0x1c10006L
#define EVT_INIT_PRESENTATION 0x1e1000cL
#define NAKA_MAINFUNC_MainPreControl 0x1410000L

void Seq_DispatchEventType6(int v)
{
  ApPostEvent(-1L, EVT_END_SONG, v);
}

void Seq_StartMainControl(void)
{
  MainPreControl(NAKA_MAINFUNC_MainPreControl, EVT_INIT_PRESENTATION, 0L);
}

unsigned int PsMixer_ReadWordArrayEntry(int i)
{
  return ram_3ea34[i];
}

void Util_StorePartArrayBase(long p)
{
  ram_3ea30 = p;
}
