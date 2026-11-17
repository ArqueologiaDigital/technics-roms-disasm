/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_W_18c.c (2026-11-17-7-sub-r18)
   sha256 11cd90f719c686bf95df843efa1165d230f4ca93f1f4a74de11f60b2fcf7bbb8 (name+funcs); compiled at -Xr */
extern unsigned char ram_4136e[];
extern unsigned char DSP_AlgoDescriptor_Records[];
struct algorec { unsigned char b[40]; };
struct b5 { unsigned char f0; unsigned char f1; unsigned char f2; unsigned char f3; unsigned char f4; };
#define PATCH(p) (*(unsigned char **)&ram_4136e[(p) * 0x11f])
#define AREC(t) ((struct algorec *)(DSP_AlgoDescriptor_Records + (int)(t) * 39))
#define AENT(t, k) ((struct b5 *)((unsigned long)&AREC(t)->b[(int)(k) * 5 + 0x13]))
unsigned char Algo_SubTable_DispatchB(unsigned char part, unsigned char k)
{
    unsigned char t;
    unsigned char r;

    t = PATCH(part)[93] & 0xf;
    r = AENT(t, k)->f2;
    switch (t) {
    case 0: case 1: case 2: case 3:
        if (k == 1)
            r = PATCH(part)[96] * 2;
        break;
    case 4: case 5:
        if (k == 1)
            r = PATCH(part)[98] * 2;
        break;
    case 8:
        if (k == 1)
            r = PATCH(part)[95] * 2;
        break;
    }
    return r;
}
