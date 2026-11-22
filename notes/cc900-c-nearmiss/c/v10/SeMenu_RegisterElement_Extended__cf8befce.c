/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_Z_35r1m129a.c (2026-11-22-23-p6-r90)
   sha256 cf8befce8e9bb8e2c6500ac12d4f88083ef8f9f0fc9353590141e1660cb78bbe (tar-sha256); compiled at -O3 -Xr */
extern void SeMenu_LoadMasterPtr(unsigned char *);
extern void SeMenu_SetObjectFlags(unsigned int);
extern void SeMenu_FlushDisplayObj(unsigned char *);
int SeMenu_RegisterElement_Extended(unsigned char flags, unsigned char row, unsigned char *v, unsigned char kind)
{
    unsigned char m;
    unsigned char o[9];
    register unsigned char *e;
    register unsigned char *q;
    register unsigned char *p;

    e = (q = o) + 9;
    do
        *q++ = 0;
    while (q < e);
    SeMenu_LoadMasterPtr(&m);
    p = o;
    p[0] = 0x80;
    p[0] |= 0x08;
    p[1] = m;
    p[2] = row;
    p[3] = 1;
    p[4] = *v;
    p[5] = kind;
    SeMenu_SetObjectFlags(flags);
    SeMenu_FlushDisplayObj(o);
    return 0;
}
