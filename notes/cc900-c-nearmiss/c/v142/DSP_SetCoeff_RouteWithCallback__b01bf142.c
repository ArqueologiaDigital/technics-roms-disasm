/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_AF_21e.c (2026-11-18-22-sub-r21d-staged)
   sha256 b01bf1423e452c791c43120881240016de4b3f13996e3e118aef404b67297d40 (tar-sha256); compiled at -Xr */
struct r16 { unsigned char b[16]; };
extern unsigned long ToneDB_RelBase;
extern unsigned long *ToneDB_RootPtr;
extern unsigned char ram_45210[];
extern unsigned char ram_4136e[];
extern unsigned char *ToneDB_Find_SubToneRecord();
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
    n = 13;
    for (i = 0; i < n; i++)
        ram_45210[i + 6] = ((unsigned char *)t)[(unsigned long)d * 16 + i];
    ram_45210[n + 6] = ((struct r16 *)((unsigned char *)t + (unsigned long)d * 16))->b[13];
    n++;
    ram_45210[n + 6] = (unsigned char)(d & 0xff);
    n++;
    ram_45210[n + 6] = (unsigned char)(d >> 8);
    n++;
}
