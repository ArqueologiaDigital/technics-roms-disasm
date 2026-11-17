/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_17a.c (2026-11-16-123-p6-r25)
   sha256 2441becdc5df439cc4c6958d347b445adac19bd939d6b2ee4eddd8e6118166c1 (tar-sha256); compiled at -O3 -Xr */
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
  unsigned char t = ram_231c;
  unsigned int m;
  if (t != 0xff) {
    m = 1 << (t - 1);
    if ((m & SEQ_TRACK_MASK) != 0 || (m & ram_2314) != 0) ram_28ac |= 0x40;
  }
  ram_1d6a = 0;
  ram_2862 = 0;
  ram_2864 = 0;
  ram_2866 = 0;
  SeqPlay_ProcessChannelsAndDrum();
}
