/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_17m129b.c (2026-11-16-107-p6-r21)
   sha256 41cc8106ac2042a106a57c77c689c80099e3c1a76c55fe5a5fca2be6397f0f3d (tar-sha256); compiled at -O3 -Xr */
extern void SeMenu_LoadMasterPtr(unsigned char *m);
extern void SeMenu_FlushDisplayObj(unsigned char *r);
void SeMenu_SetDisplayValue(unsigned char v)
{
    unsigned char m;
    unsigned char r[9];
    unsigned char *e, *p;
    p = r;
    e = p + 9;
    do
        *p++ = 0;
    while (p < e);
    SeMenu_LoadMasterPtr(&m);
    r[0] = 0x80;
    r[1] = m;
    r[2] = 0xc;
    r[3] = 0;
    r[4] = 1;
    r[5] = v;
    SeMenu_FlushDisplayObj(r);
}
