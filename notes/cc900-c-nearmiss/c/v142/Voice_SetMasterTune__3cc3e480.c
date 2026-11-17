/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_2b.c (2026-11-16-47-sub-r2)
   sha256 3cc3e48055b60002cdf17b29d0f34843d18df1591a988ec7fb65ea625f152370 (name+funcs); compiled at -Xr */
extern int ram_41347;
void Voice_SetMasterTune(char a) { a = (a - 0x40) * 2; ram_41347 = a; }
