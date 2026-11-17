/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/sequencer_engine_m235.c (2026-11-16-111-p6-r22-staged)
   sha256 0bd4ea0167bc05b4b398e2ce68513d816ea8d530ebc3d812796827ab891a6b65 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern unsigned char __near ram_2587;
extern unsigned int __near ram_258e;
extern unsigned int __near ram_2590;
extern unsigned char __near ram_2592;
extern unsigned char __near ram_28a6;
void SeqScan_UpdateBestPositionB(void)
{
  unsigned int b = ram_258e, w = ram_2590;
  if (w > b) return;
  if (w == b && ram_2592 > ram_2587) return;
  ram_2590 = b;
  ram_2592 = ram_2587;
  ram_28a6 &= ~0x01;
}
