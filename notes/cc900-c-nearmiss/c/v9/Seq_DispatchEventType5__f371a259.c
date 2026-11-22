/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/drawbar_panel_ui_m264.c (2026-11-21-5-p6-r60)
   sha256 f371a2593bfb9e3c03fada19a2b5084f152469f64b1dce8d3467fc6817cba146 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern long ApPostEvent(long, long, long);
#define EVT_START_SONG 0x1c10005L
void Seq_DispatchEventType5(int v)
{
  ApPostEvent(-1L, EVT_START_SONG, v);
}
