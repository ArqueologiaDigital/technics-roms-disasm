/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_14b.c (2026-11-16-100-p6-r19)
   sha256 4593df46c7ccd0fe04e84b3b12d7adf29ec8187be773eb6acc8acb80e215a928 (tar-sha256); compiled at -O3 -Xr */
extern unsigned char __near ram_2587;
extern unsigned int __near ram_258e;
extern unsigned int __near ram_2590;
extern unsigned char __near ram_2592;
extern unsigned char __near ram_28a6;
void SeqScan_UpdateBestPositionB(void)
{
  unsigned int b = ram_258e, w = ram_2590;
  if (w < b || (w == b && ram_2592 <= ram_2587)) {
    ram_2590 = b;
    ram_2592 = ram_2587;
    ram_28a6 &= ~0x01;
  }
}
