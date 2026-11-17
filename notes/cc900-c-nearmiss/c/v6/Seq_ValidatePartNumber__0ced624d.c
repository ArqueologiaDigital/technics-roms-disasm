/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/sequencer_engine.c (2026-11-16-25-p6-firmware)
   sha256 0ced624d4f49c5143eb407d6a74e7e70a366a523a09e5def467ea0889befe9a8 (tar-sha256); compiled at -O3 -XS -Xr */
extern unsigned char ram_2885;
int Seq_ValidatePartNumber(unsigned char a) { if (a < 1 || a > ram_2885) return -1; return 0; }
