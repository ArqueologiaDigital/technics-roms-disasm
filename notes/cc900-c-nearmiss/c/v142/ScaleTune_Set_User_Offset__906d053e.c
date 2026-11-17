/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_2c.c (2026-11-16-47-sub-r2)
   sha256 906d053e9e022b076b374cbe36e37f4f7859909ad771530433ba3cbcc3c0234b (name+funcs); compiled at -Xr */
extern unsigned char ram_41342[];
void ScaleTune_Set_User_Offset(unsigned char n, unsigned char v) { ram_41342[n + 12U] = v - 0x80; }
