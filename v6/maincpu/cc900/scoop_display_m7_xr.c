/* Functions of display/scoop_display.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

extern void ChannelFilter_SetMode(void);
extern void ChannelFilter_ApplyWrapper(void);
extern unsigned int __near ram_1108;
extern void ChannelFilter_InitAndApply(void);

void ChannelFilter_InitAndApply(void)
{
  ChannelFilter_SetMode();
  ChannelFilter_ApplyWrapper();
  ram_1108 = 0;
}
