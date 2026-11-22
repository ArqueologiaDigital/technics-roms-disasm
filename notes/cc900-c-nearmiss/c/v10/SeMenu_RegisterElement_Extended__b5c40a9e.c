/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_36r1m129b.c (2026-11-22-25-p6-r92)
   sha256 b5c40a9e3d390f630b184008b6da62321c494e096ae9c9eaeadbfee64498a240 (tar-sha256); compiled at -O3 -Xr */
extern void SeMenu_LoadMasterPtr(unsigned char *);
extern void SeMenu_SetObjectFlags(unsigned int);
extern void SeMenu_FlushDisplayObj(unsigned char *);
int SeMenu_RegisterElement_Extended(unsigned char flags, unsigned char row, unsigned char *v, unsigned char kind)
{
    unsigned char m;
    unsigned char o[9];
    register unsigned char *q;
    register unsigned char *e;
    register unsigned char *p;

    e = o + 9;
    q = o;
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
