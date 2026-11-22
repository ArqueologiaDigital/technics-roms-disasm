/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_36r1m129a.c (2026-11-22-25-p6-r92)
   sha256 02fc736b45aa7980da92b77a8fa3b2d65fac7e43983350d68c99d918f7a4254d (tar-sha256); compiled at -O3 -Xr
   cc900-name: SeM_CWU_S3C3H=SeMenu_CopyWriteUpdate_Step3_Code_3_Helper */
extern void SeMenu_LoadMasterPtr(unsigned char *);
extern void SeMenu_FlushDisplayObj(unsigned char *);
int SeM_CWU_S3C3H(unsigned char col, unsigned char kind)
{
    unsigned char m;
    unsigned char o[9];
    register unsigned char *q;
    register unsigned char *p;

    q = o;
    do
        *q++ = 0;
    while (q < o + 9);
    SeMenu_LoadMasterPtr(&m);
    p = o;
    p[0] = 0x80;
    p[1] = m;
    p[2] = 1;
    p[3] = col;
    p[4] = 1;
    p[5] = kind;
    SeMenu_FlushDisplayObj(p);
    return 0;
}
