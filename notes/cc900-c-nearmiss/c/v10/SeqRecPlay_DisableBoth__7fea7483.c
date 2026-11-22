/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_R_20r1m203b.c (2026-11-21-3-p6-r59)
   sha256 7fea748337bc6fd2bfc985a91ef6a2e01238182a164a847aafdb8c445ac4a15e (tar-sha256); compiled at -Xr */
#define EVT_REFRESH_PARA_DRAW 0x1e000a7L
extern long ApPostEvent(long, long, long);
extern unsigned char ram_21092;
extern volatile unsigned char ram_21094;
void SeqRecPlay_DisableBoth(void)
{
  ram_21092 = 0;
  ram_21094 = 0;
  ApPostEvent(0x6f0025L, EVT_REFRESH_PARA_DRAW, 0L);
  ApPostEvent(0x6f0024L, EVT_REFRESH_PARA_DRAW, (unsigned long)ram_21094);
}
