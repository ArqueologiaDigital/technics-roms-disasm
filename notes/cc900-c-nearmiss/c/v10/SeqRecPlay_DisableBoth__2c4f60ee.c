/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_R_20r1m203a.c (2026-11-21-3-p6-r59)
   sha256 2c4f60eeaa827b7ae6b5735be848e91ac9c484ff21cce24c7eefd31ab14b4e78 (tar-sha256); compiled at -Xr */
#define EVT_REFRESH_PARA_DRAW 0x1e000a7L
extern long ApPostEvent(long, long, long);
extern unsigned char ram_21092;
extern unsigned char ram_21094;
void SeqRecPlay_DisableBoth(void)
{
  ram_21092 = 0;
  ram_21094 = 0;
  ApPostEvent(0x6f0025L, EVT_REFRESH_PARA_DRAW, 0L);
  ApPostEvent(0x6f0024L, EVT_REFRESH_PARA_DRAW, ram_21094);
}
