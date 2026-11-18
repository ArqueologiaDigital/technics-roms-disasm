/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_AI_22a.c (2026-11-18-29-sub-r21f)
   sha256 f1667cac05ec896d30235087cc0a76bcfed9f9fea2e4a484286b1e79967f607f (tar-sha256); compiled at -Xr */
struct r16 { unsigned char b[16]; };
extern unsigned long ToneDB_RelBase;
extern unsigned long *ToneDB_RootPtr;
extern unsigned char ram_4136e[];
extern unsigned char ram_45210[];
extern unsigned char *ToneDB_Find_SubToneRecord(unsigned char *rec, unsigned char k, unsigned char e);
void DSP_SetCoeff_RouteWithCallback(unsigned char a, unsigned char c, unsigned char e)
{
    unsigned int n;
    unsigned int d;
    unsigned char *tbl;
    unsigned char s;
    unsigned char *q;
    unsigned int x;
    unsigned int y;
    unsigned int i;
    unsigned long t;

    s = e;
    s &= 15;
    q = ToneDB_Find_SubToneRecord(*(unsigned char **)&ram_4136e[(a) * 0x11f], c, a);
    q = &q[(int)s * 21 + 16];
    x = (unsigned char)q[1];
    x &= 127;
    y = (unsigned char)q[2];
    y &= 15;
    switch ((int)q[2] & 192) {
    case 0x00:
    case 0x40:
    case 0x80:
    case 0xc0:
        tbl = (unsigned char *)ToneDB_RootPtr[19];
        break;
    }
    d = *(unsigned long *)((unsigned long)(((y << 7) + x) * 2) + (unsigned long)tbl + ToneDB_RelBase);
    tbl = (unsigned char *)ToneDB_RootPtr[35];
    t = ToneDB_RelBase;
    t += (unsigned long)tbl;
    tbl = (unsigned char *)t;
    n = 13;
    for (i = 0; i < n; i++)
        ram_45210[i + 6] = tbl[(unsigned long)d * 16 + i];
    ram_45210[n + 6] = ((struct r16 *)(tbl + (unsigned long)d * 16))->b[13];
    n++;
    ram_45210[n + 6] = (unsigned char)(d & 0xff);
    n++;
    ram_45210[n + 6] = (unsigned char)(d >> 8);
    n++;
}
