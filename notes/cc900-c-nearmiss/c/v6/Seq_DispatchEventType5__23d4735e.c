/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/drawbar_panel_ui_m264.c (2026-11-21-5-p6-r60)
   sha256 23d4735e7b9ad5e7ea8f4f11d9072364a1849468bc94572b37f6485759cf94ee (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern long ApPostEvent(long, long, long);
#define EVT_START_SONG 0x1c10005L
void Seq_DispatchEventType5(int v)
{
  ApPostEvent(-1L, EVT_START_SONG, v);
}
