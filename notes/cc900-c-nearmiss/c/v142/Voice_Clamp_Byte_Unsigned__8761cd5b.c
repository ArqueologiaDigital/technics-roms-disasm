/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_A_4a.c (2026-11-16-62-sub-r4)
   sha256 8761cd5b09c02ab4a3dcf319bf8f33d0a140160a7f99178b636c4330cd768909 (name+funcs); compiled at -Xr */
unsigned int Voice_Clamp_Byte_Unsigned(unsigned int a)
{
    if (a > 255) a = 255;
    return a;
}
