/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_15m129a.c (2026-11-16-100-p6-r19)
   sha256 1d6dfb37b022e7941628385d8ef755abe05f02bfba40869be988ffc2b2545110 (tar-sha256); compiled at -O3 -Xr */
extern void SeMenu_LoadMasterPtr(unsigned char *m);
extern void SeMenu_FlushDisplayObj(unsigned char *r);
void SeEasy_SendParamValue(unsigned char row, unsigned char *val)
{
    unsigned char m;
    unsigned char r[9];
    unsigned char *p, *e;
    p = r;
    e = r + 9;
    do
        *p++ = 0;
    while (p < e);
    SeMenu_LoadMasterPtr(&m);
    r[0] = 136;
    r[1] = m;
    r[2] = 11;
    r[3] = row - 1;
    r[4] = *val;
    r[5] = 255;
    SeMenu_FlushDisplayObj(r);
}
