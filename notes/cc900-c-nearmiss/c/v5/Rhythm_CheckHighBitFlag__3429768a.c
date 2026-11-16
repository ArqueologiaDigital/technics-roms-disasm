/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/sequencer_engine.c (2026-11-16-36-p6-staged-r4)
   sha256 3429768a70dc785fb21192a3344794e57ad1c19c09315bae78e9ab52aac28f93 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern unsigned char __near ram_42e;
unsigned char Rhythm_CheckHighBitFlag(void) { return (ram_42e & 0x80) >> 7; }
