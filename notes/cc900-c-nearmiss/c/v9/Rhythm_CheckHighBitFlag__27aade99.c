/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/sequencer_engine.c (2026-11-16-31-p6-r1b)
   sha256 27aade999f7ef06a47ac6fa27f8c59782ab01933ef9fc78ed12c36a96d5561f5 (tar-sha256); compiled at -Xr */
extern unsigned char __near ram_42e;
unsigned char Rhythm_CheckHighBitFlag(void) { return (ram_42e & 0x80) >> 7; }
