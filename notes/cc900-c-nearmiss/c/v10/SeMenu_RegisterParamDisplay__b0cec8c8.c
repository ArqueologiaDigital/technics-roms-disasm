/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_19m129b.c (2026-11-16-123-p6-r25)
   sha256 b0cec8c86b239117fceba9a2ab35b77fd7a248dbd2428c2110bf376a9481dab0 (tar-sha256); compiled at -O3 -Xr */
extern void SeMenu_LoadMasterPtr(unsigned char *m);
extern void SeMenu_FlushDisplayObj(unsigned char *r);
void SeMenu_RegisterParamDisplay(unsigned char v)
{
    unsigned char m;
    unsigned char r[9];
    register unsigned char *q;
    unsigned char *p, *e;
    q = r;
    p = q;
    e = q + 9;
    do
        *p++ = 0;
    while (p < e);
    SeMenu_LoadMasterPtr(&m);
    r[0] = 0x80;
    r[1] = m;
    r[3] = 0;
    r[4] = 1;
    r[5] = v;
    SeMenu_FlushDisplayObj(r);
}
