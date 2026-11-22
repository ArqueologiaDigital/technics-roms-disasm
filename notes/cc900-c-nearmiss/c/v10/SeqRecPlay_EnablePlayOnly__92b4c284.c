/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/demo_seq_bridge_m203.c (2026-11-21-5-p6-r60)
   sha256 92b4c28406c2f83f2443bc79e9db6be479e3550cd6b9d23d747dde1777c84efa (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern long ApPostEvent(long, long, long);
extern unsigned char ram_21092;
extern unsigned char ram_21094;
#define EVT_REFRESH_PARA_DRAW 0x1e000a7L
void SeqRecPlay_EnablePlayOnly(void)
{
  ram_21092 = 0;
  ram_21094 = 1;
  ApPostEvent(0x6f0025L, EVT_REFRESH_PARA_DRAW, 0L);
  ApPostEvent(0x6f0024L, EVT_REFRESH_PARA_DRAW, ram_21094);
}
