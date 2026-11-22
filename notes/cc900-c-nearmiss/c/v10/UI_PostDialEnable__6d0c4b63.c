/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_U_21r1m270a.c (2026-11-21-7-p6-r62)
   sha256 6d0c4b63923df8c38c2b0036d6673a43b682381bbee85736421e6a9d9b1e4541 (tar-sha256); compiled at -O3 -Xr */
extern long ApPostEvent(long, long, long);
#define EVT_VALEN_SET 0x1e0006fL
void UI_PostDialEnable(unsigned int v)
{
  ApPostEvent(-1L, EVT_VALEN_SET, (unsigned char)v);
}
