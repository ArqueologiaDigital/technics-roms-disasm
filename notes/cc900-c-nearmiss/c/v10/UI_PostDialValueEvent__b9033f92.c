/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_Q_20r1m270a.c (2026-11-21-2-p6-r58)
   sha256 b9033f920fa66dbd6912a0fae6066fc035794524d600bbd3e485d9b41817fe29 (tar-sha256); compiled at -O3 -XS -Xr */
extern long ApPostEvent(long, long, long);
#define EVT_EDIT_UP_SET 0x1e00071L
void UI_PostDialValueEvent(unsigned char v)
{
  ApPostEvent(-1L, EVT_EDIT_UP_SET, (unsigned int)v);
}
