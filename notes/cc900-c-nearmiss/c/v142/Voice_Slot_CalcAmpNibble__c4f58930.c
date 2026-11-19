/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_lane_23w5b.c (2026-11-19-10-sub-r23w-asm)
   sha256 c4f58930b3bd612ce04c6acbf4749489c7f80f911867c569244db57c32d4251f (name+funcs); compiled at -Xr
   cc900-options: -Xr */
extern unsigned char ram_41368[];
extern unsigned char ram_43094[];
unsigned int Voice_Slot_CalcAmpNibble(unsigned char part, unsigned char n, unsigned char e)
{
    unsigned int *q;
    unsigned int lo;
    unsigned int r;
    q = (unsigned int *)((unsigned long)&ram_41368[part * 287] + 258);
    if ((*(unsigned int *)&ram_43094[(int)n * 71] >> 8) + 12 >= 36) r = q[e];
    else {
        lo = q[e] & 0xf;
        if (lo < ((q[e] >> 4) & 0xf)) r = q[e] & 0xff0;
        else r = (q[e] & 0xf00) | (lo << 4);
    }
    return r;
}
