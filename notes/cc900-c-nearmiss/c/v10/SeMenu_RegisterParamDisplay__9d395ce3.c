/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_19m129c.c (2026-11-16-123-p6-r25)
   sha256 9d395ce3453ee0111fbd9d95b58cec7128ae8285eddbff31d2f97f2cfac7e3ec (tar-sha256); compiled at -O3 -Xr */
extern void SeMenu_LoadMasterPtr(unsigned char *m);
extern void SeMenu_FlushDisplayObj(unsigned char *r);
void SeMenu_RegisterParamDisplay(unsigned char v)
{
    unsigned char m;
    unsigned char r[9];
    char *p, *e;
    e = (char *)r;
    p = e;
    e += 9;
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
