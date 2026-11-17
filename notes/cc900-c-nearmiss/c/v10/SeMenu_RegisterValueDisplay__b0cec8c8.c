/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_19m129b.c (2026-11-16-123-p6-r25)
   sha256 b0cec8c86b239117fceba9a2ab35b77fd7a248dbd2428c2110bf376a9481dab0 (tar-sha256); compiled at -O3 -Xr */
extern void SeMenu_LoadMasterPtr(unsigned char *m);
extern void SeMenu_FlushDisplayObj(unsigned char *r);
void SeMenu_RegisterValueDisplay(unsigned char a, unsigned char c)
{
    unsigned char m;
    unsigned char r[9];
    register unsigned char *e;
    unsigned char *p;
    e = r;
    p = e;
    e += 9;
    do
        *p++ = 0;
    while (p < e);
    SeMenu_LoadMasterPtr(&m);
    r[0] = 0x80;
    r[1] = m;
    r[2] = 0x10;
    r[3] = a;
    r[4] = 1;
    r[5] = c;
    SeMenu_FlushDisplayObj(r);
}
