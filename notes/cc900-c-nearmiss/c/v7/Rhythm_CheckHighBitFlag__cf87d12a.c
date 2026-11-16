/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/sequencer_engine.c (2026-11-16-36-p6-staged-r4)
   sha256 cf87d12a4ad49fb769655d9972af2f92b36f5db5a8af9024f75c9fbf40b4ef31 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern unsigned char __near ram_42e;
unsigned char Rhythm_CheckHighBitFlag(void) { return (ram_42e & 0x80) >> 7; }
