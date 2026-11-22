/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_W_21r2m270a.c (2026-11-21-9-p6-r64)
   sha256 bb6f1ea43f923653844227cacfe4e5462e92a10714ec59e71aa3e3786f8e5396 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern long ApPostEvent(long, long, long);
#define EVT_VALEN_SET 0x1e0006fL
void UI_PostDialEnable(unsigned int v)
{
  ApPostEvent(-1L, EVT_VALEN_SET, v & 0xff);
}
