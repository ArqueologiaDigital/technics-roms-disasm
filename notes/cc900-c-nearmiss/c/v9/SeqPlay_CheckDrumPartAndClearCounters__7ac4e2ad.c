/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/sequencer_engine_m233.c (2026-11-16-125-p6-r26-staged)
   sha256 7ac4e2adf6a6714e96197f490d8bc08d781ca25256f3a98b1736434e897892a3 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern unsigned char __near ram_1d6a;
extern unsigned int __near ram_2314;
extern unsigned char __near ram_231c;
extern unsigned int __near SEQ_TRACK_MASK;
extern unsigned char __near ram_28ac;
extern unsigned char __near ram_2862;
extern unsigned char __near ram_2864;
extern unsigned char __near ram_2866;
extern void SeqPlay_ProcessChannelsAndDrum(void);
void SeqPlay_CheckDrumPartAndClearCounters(void)
{
  unsigned char t;
  int m;
  t = ram_231c;
  if (t != 0xff) {
    m = 1 << (t - 1);
    if ((m & SEQ_TRACK_MASK) || (m & ram_2314)) ram_28ac |= 0x40;
  }
  ram_1d6a = 0;
  ram_2862 = 0;
  ram_2864 = 0;
  ram_2866 = 0;
  SeqPlay_ProcessChannelsAndDrum();
}
