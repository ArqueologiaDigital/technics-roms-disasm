/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_W_21r2m270b.c (2026-11-21-9-p6-r64)
   sha256 477f0b929f277a4bf56f1082c9119091e21129a6dca7424f5e422c47da274c70 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern long ApPostEvent(long, long, long);
#define EVT_EDIT_UP_SET 0x1e00071L
void UI_PostDialValueEvent(unsigned int v)
{
  unsigned int w;
  w = v & 0xff;
  ApPostEvent(-1L, EVT_EDIT_UP_SET, w);
}
