/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/sequencer_engine.c (2026-11-16-33-p6-r2)
   sha256 bc97e16e36eb78be362860cbcf8cad4b1d6004abf048306b08f54cde8c6bf0e2 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern unsigned char __near ram_42e;
unsigned char Rhythm_CheckHighBitFlag(void) { return (ram_42e & 0x80) >> 7; }
