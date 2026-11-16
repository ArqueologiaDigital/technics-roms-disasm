/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_A_4b.c (2026-11-16-62-sub-r4)
   sha256 2930891c0f4cc37037eb6f8318034f85e7213280edee0124175fee577eb1783d (name+funcs); compiled at -Xr */
extern unsigned char ram_41368[];
extern unsigned char ram_43094[];
unsigned int Voice_Slot_FindOctaveOffset(unsigned char part, unsigned char n, unsigned char e)
{
    unsigned int *q;
    unsigned char k;
    unsigned int w, r, b, c;
    q = (unsigned int *)&ram_41368[part * 287];
    q = q + 129;
    k = 0;
    w = (*(unsigned int *)&ram_43094[(int)n * 71] >> 8) - 12;
    while (w >= 0x54) {
        w -= 12;
        k++;
    }
    if (k == 0) return q[e];
    else if (k == 1) {
        r = q[e] & 0xff;
        b = (q[e] >> 4) & 0xf;
        c = (q[e] >> 8) & 0xf;
        if (b < c) r = (r & 0xf) | (c << 4);
    } else {
        r = q[e] & 0xf;
        b = (q[e] >> 4) & 0xf;
        c = (q[e] >> 8) & 0xf;
        if (r < b) {
            if (b < c) r = c;
            else r = b;
        } else if (r < c) r = c;
    }
    return r;
}
