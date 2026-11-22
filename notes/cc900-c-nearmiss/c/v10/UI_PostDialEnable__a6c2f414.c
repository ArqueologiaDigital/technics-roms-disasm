/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_U_21r1m270b.c (2026-11-21-7-p6-r62)
   sha256 a6c2f41457eee12526e64906b0a5da8a5ea6ec45067e13047651b03c7d3fec99 (tar-sha256); compiled at -O3 -Xr */
extern long ApPostEvent(long, long, long);
#define EVT_VALEN_SET 0x1e0006fL
void UI_PostDialEnable(int v)
{
  ApPostEvent(-1L, EVT_VALEN_SET, (unsigned char)v);
}
