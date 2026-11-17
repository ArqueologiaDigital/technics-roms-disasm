/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/sequencer_engine.c (2026-11-16-25-p6-firmware)
   sha256 5d1a534e514aace5232ab8dfac24cfed13ce9e06f6bbee0a4a2cb87681ea340c (tar-sha256); compiled at -O3 -XS -Xr */
extern unsigned char ram_28a1;
int Seq_ValidatePartNumber(unsigned char a) { if (a < 1 || a > ram_28a1) return -1; return 0; }
