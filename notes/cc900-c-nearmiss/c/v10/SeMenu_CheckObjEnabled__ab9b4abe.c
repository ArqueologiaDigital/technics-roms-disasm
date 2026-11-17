/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_m8b.c (2026-11-16-20-p6-m8)
   sha256 ab9b4abeddceec590d6eb3bab3cc58072523b326fc3061edd386a6db54fc86b0 (name+funcs); compiled at (no flags) */
extern unsigned char ram_20c33, ram_20c35, ram_20bf3[], ram_6c1[], ram_42e, SEQ_ERROR_CODE, SEQ_RTMCFG;
int SeMenu_CheckObjEnabled(unsigned char a) { int r = -1; if (ram_20c33 == a) r = 0; return r; }
