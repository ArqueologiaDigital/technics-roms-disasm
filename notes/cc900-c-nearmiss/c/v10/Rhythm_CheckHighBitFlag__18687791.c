/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/sequencer_engine.c (2026-11-16-30-p6-r1)
   sha256 18687791111a66b6d3c353fdf5f242cd422e18ac6c9321c8dceb39d0a356de1a (tar-sha256); compiled at -Xr */
extern unsigned char __near ram_42e;
unsigned char Rhythm_CheckHighBitFlag(void) { return (ram_42e & 0x80) >> 7; }
