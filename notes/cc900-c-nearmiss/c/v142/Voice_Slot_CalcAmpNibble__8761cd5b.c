/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_A_4a.c (2026-11-16-62-sub-r4)
   sha256 8761cd5b09c02ab4a3dcf319bf8f33d0a140160a7f99178b636c4330cd768909 (name+funcs); compiled at -Xr */
extern unsigned char ram_41368[];
extern unsigned char ram_43094[];
unsigned int Voice_Slot_CalcAmpNibble(unsigned char part, unsigned char n, unsigned char e)
{
    unsigned int *q;
    unsigned int lo;
    unsigned int r;
    q = (unsigned int *)&ram_41368[part * 287];
    q += 129;
    if ((*(unsigned int *)&ram_43094[(int)n * 71] >> 8) + 12 >= 36) r = q[e];
    else {
        lo = q[e] & 0xf;
        if (lo < ((q[e] >> 4) & 0xf)) r = q[e] & 0xff0;
        else r = (q[e] & 0xf00) | (lo << 4);
    }
    return r;
}
