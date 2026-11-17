/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/sequencer_engine.c (2026-11-16-31-p6-r1b)
   sha256 cc18d044cdc82b7bd433154d65ff9606178d9ad956773e9205ffa7531565ada7 (tar-sha256); compiled at -Xr */
extern unsigned char __near ram_42e;
unsigned char Rhythm_CheckHighBitFlag(void) { return (ram_42e & 0x80) >> 7; }
