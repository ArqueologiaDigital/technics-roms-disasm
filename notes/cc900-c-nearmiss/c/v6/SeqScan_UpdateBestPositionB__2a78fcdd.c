/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/sequencer_engine_m235.c (2026-11-16-111-p6-r22-staged)
   sha256 2a78fcddc032094c763d5086f20356f864dfbe2ec471ecb6bb387d5901b89f78 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern unsigned char __near ram_256d;
extern unsigned int __near ram_2574;
extern unsigned int __near ram_2576;
extern unsigned char __near ram_2578;
extern unsigned char __near ram_288a;
void SeqScan_UpdateBestPositionB(void)
{
  unsigned int b = ram_2574, w = ram_2576;
  if (w > b) return;
  if (w == b && ram_2578 > ram_256d) return;
  ram_2576 = b;
  ram_2578 = ram_256d;
  ram_288a &= ~0x01;
}
