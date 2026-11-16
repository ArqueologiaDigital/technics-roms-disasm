/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_1b.c (2026-11-16-32-p6-m18-olevels)
   sha256 bd6e4557c8e04a2edcf7c0a4f18652e01cf59f735fd3362c0cbe758f01080833 (tar-sha256); compiled at -O2 -Xr */
extern unsigned int __near ram_2526[];
extern unsigned int __near ram_2590;
extern unsigned char __near ram_2546[];
extern unsigned char __near ram_2592;
void SeqScan_ClearMatchingBarSlots(void)
{
  unsigned int i = 0;
  do {
    if (ram_2546[i] == ram_2592 && ram_2526[i] == ram_2590) { ram_2526[i] = 0xffff; ram_2546[i] = 0xff; }
    i++;
  } while (i < 16);
}
