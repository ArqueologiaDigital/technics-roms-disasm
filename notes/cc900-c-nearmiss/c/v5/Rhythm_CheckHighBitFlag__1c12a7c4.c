/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/sequencer_engine.c (2026-11-16-30-p6-r1)
   sha256 1c12a7c49e741b91c0ec6e448e44f65374fdd1ced98c7fb9d0decc7a63677858 (tar-sha256); compiled at -Xr */
extern unsigned char __near ram_42e;
unsigned char Rhythm_CheckHighBitFlag(void) { return (ram_42e & 0x80) >> 7; }
