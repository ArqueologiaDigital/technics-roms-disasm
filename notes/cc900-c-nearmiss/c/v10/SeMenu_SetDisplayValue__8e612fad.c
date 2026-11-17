/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_18m129a.c (2026-11-16-118-p6-r23)
   sha256 8e612fad7397452076ffefb24a11a402ad464cbd728734a396b11791849b42f5 (tar-sha256); compiled at -O3 -Xr */
extern void SeMenu_LoadMasterPtr(unsigned char *m);
extern void SeMenu_FlushDisplayObj(unsigned char *r);
void SeMenu_SetDisplayValue(unsigned char v)
{
    unsigned char m;
    unsigned char r[9];
    unsigned char *q, *p, *e;
    q = r;
    p = q;
    e = q + 9;
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
