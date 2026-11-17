/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_m8c.c (2026-11-16-20-p6-m8)
   sha256 56dcc10411bef59352628fc224d9a25e7399ab4d94c1aa38071cf7e31237f52e (name+funcs); compiled at -Xr */
extern unsigned char ram_20c33, ram_20c35, ram_20bf3[], ram_6c1[], ram_42e, SEQ_ERROR_CODE, SEQ_RTMCFG;
void SeMenu_SetNameBufferChar(unsigned char i, unsigned char c) { if (i < 16) *(ram_20bf3 + i) = c; }
