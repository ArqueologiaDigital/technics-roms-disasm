/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_14a.c (2026-11-16-100-p6-r19)
   sha256 85fbeeab11365f896e371bcac755fbdcf9888c9c7500cb9a0ebbc1e1bd869b02 (tar-sha256); compiled at -O3 -XS -Xr */
extern unsigned char __near ram_2587;
extern unsigned int __near ram_258e;
extern unsigned int __near ram_2590;
extern unsigned char __near ram_2592;
extern unsigned char __near ram_28a6;
void SeqScan_UpdateBestPositionA(void)
{
  unsigned int b = ram_258e, w = ram_2590;
  if (w > b) return;
  if (w == b && ram_2592 > ram_2587) return;
  ram_2590 = b;
  ram_2592 = ram_2587;
  ram_28a6 |= 0x01;
}
