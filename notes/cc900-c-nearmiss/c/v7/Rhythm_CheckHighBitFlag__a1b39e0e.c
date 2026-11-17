/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/sequencer_engine.c (2026-11-16-33-p6-r2)
   sha256 a1b39e0eed457b8cec3de76aac5f52cd3fb2d00338cbbd89325bb8f84b4a4d13 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern unsigned char __near ram_42e;
unsigned char Rhythm_CheckHighBitFlag(void) { return (ram_42e & 0x80) >> 7; }
