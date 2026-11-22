/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/ui_control_panel_m270.c (2026-11-21-22-p6-r67)
   sha256 4c44424394742da9573af136e7263745bb5135461ff6ba2fb3bffaead68a0de0 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern long ApPostEvent(long, long, long);
#define EVT_VALEN_SET 0x1e0006fL
void UI_PostDialEnable(unsigned char a)
{
  ApPostEvent(-1L, EVT_VALEN_SET, a);
}
