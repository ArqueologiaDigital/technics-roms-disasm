/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/demo_seq_bridge_m203.c (2026-11-21-5-p6-r60)
   sha256 15e49d0f48a8e59ee49c7f6480672616ae3db27b6c0c9a6993d4bd3223a7e6f9 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern long ApPostEvent(long, long, long);
extern unsigned char ram_21092;
extern unsigned char ram_21094;
#define EVT_REFRESH_PARA_DRAW 0x1e000a7L
void SeqRecPlay_EnableRecordOnly(void)
{
  ram_21092 = 1;
  ram_21094 = 0;
  ApPostEvent(0x6f0025L, EVT_REFRESH_PARA_DRAW, 1L);
  ApPostEvent(0x6f0024L, EVT_REFRESH_PARA_DRAW, ram_21094);
}
