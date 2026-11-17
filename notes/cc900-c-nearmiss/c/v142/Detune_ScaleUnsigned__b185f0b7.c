/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_2a.c (2026-11-16-47-sub-r2)
   sha256 b185f0b75e10c9bf3906c4dffb6f347153462a7916bfc667822efdd3aa51c4da (name+funcs); compiled at -Xr */
extern unsigned char Detune_Scale_Curve[];
unsigned int Detune_ScaleUnsigned(unsigned char a) { a = Detune_Scale_Curve[a]; return a; }
