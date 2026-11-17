/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_2b.c (2026-11-16-47-sub-r2)
   sha256 3cc3e48055b60002cdf17b29d0f34843d18df1591a988ec7fb65ea625f152370 (name+funcs); compiled at -Xr */
extern unsigned char Detune_Scale_Curve[];
int Detune_ScaleUnsigned(unsigned char a) { a = Detune_Scale_Curve[a]; return a; }
