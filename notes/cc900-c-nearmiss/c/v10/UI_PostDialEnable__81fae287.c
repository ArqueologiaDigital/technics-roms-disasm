/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_Q_20r1m270b.c (2026-11-21-2-p6-r58)
   sha256 81fae287a9d8c761235f434d133de164de80f2dd6b9980cce8bc15ed0d0406de (tar-sha256); compiled at -O3 -XS -Xr */
extern long ApPostEvent(long, long, long);
#define EVT_VALEN_SET 0x1e0006fL
void UI_PostDialEnable(unsigned char v)
{
  unsigned int w;
  w = v;
  ApPostEvent(-1L, EVT_VALEN_SET, w);
}
