/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_Y_34r1m129b.c (2026-11-22-21-p6-r88)
   sha256 7699b94b9d1d6f97c1caba1e86e286ff04b26b85aca3cce0bfc05bb54221211b (tar-sha256); compiled at -O3 -Xr */
extern void SeMenu_LoadMasterPtr(unsigned char *);
extern void SeMenu_SetObjectFlags(unsigned int);
extern void SeMenu_FlushDisplayObj(unsigned char *);
int SeMenu_RegisterElement_Type1(unsigned char flags, unsigned char row, unsigned char col, unsigned char kind)
{
    unsigned char o[9];
    unsigned char m;
    register unsigned char *p;
    register unsigned char *e;
    register unsigned char *q;

    e = (q = o) + 9;
    do
        *q++ = 0;
    while (q < e);
    SeMenu_LoadMasterPtr(&m);
    p = o;
    p[0] = 0x80;
    p[1] = m;
    p[2] = row;
    p[3] = col;
    p[4] = 1;
    p[5] = kind;
    SeMenu_SetObjectFlags(flags);
    SeMenu_FlushDisplayObj(o);
    return 0;
}
