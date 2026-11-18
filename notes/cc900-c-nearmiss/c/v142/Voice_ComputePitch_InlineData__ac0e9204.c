/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_Q_17a.c (2026-11-16-126-sub-r17)
   sha256 ac0e9204f80496a2a00e80ac0c4a0b41db26241507df15b2c4016b2c7863b004 (name+funcs); compiled at -Xr */
int Voice_ComputePitch_InlineData(int a, int hi, int lo)
{
    if (a < lo) a = lo;
    else if (a > hi) a = hi;
    return a;
}
