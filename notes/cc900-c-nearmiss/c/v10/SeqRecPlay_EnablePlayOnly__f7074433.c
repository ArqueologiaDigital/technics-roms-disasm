/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_Q_20r1m203a.c (2026-11-21-2-p6-r58)
   sha256 f7074433fcaa55e38a1cae9e0ec3c4d2596605924613a4a1825fa9760aa42e09 (tar-sha256); compiled at -Xr */
extern unsigned char ram_21092;
extern unsigned char ram_21094;
extern long ApPostEvent(long, long, long);
#define EVT_REFRESH_PARA_DRAW 0x1e000a7L
void SeqRecPlay_EnablePlayOnly(void)
{
  ram_21092 = 0;
  ram_21094 = 1;
  ApPostEvent(0x6f0025L, EVT_REFRESH_PARA_DRAW, 0L);
  ApPostEvent(0x6f0024L, EVT_REFRESH_PARA_DRAW, ram_21094);
}
