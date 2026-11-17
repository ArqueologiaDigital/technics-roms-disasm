/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/sequencer_engine.c (2026-11-16-36-p6-staged-r4)
   sha256 89407f0c2d25bb39cbeb834be9f9a659e995f5e65ab955bf65c63980fa1ea092 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern unsigned char __near ram_42e;
unsigned char Rhythm_CheckHighBitFlag(void) { return (ram_42e & 0x80) >> 7; }
