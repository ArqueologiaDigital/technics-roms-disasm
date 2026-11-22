/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_Z_22r1m270a.c (2026-11-21-21-p6-r66)
   sha256 74b965a95355c6c4159e71b36c586f5e5e708c98fd83eb862bcef256f54dda5a (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern long ApPostEvent(long, long, long);
#define EVT_EDIT_UP_SET 0x1e00071L
void UI_PostDialValueEvent(unsigned char a)
{
  ApPostEvent(-1L, EVT_EDIT_UP_SET, a);
}
