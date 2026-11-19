/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_AP_23a.c (2026-11-19-18-sub-r23r-apdsp)
   sha256 6881d8b79ecead95941178b1b08f8461b6bd4470c92c74b0632664b0f1c2d1fc (name+funcs); compiled at -Xr
   cc900-options: -Xr */
struct r16 { unsigned char b[16]; };
extern unsigned long ToneDB_RelBase;
extern unsigned long *ToneDB_RootPtr;
extern unsigned char ram_45210[];
extern unsigned char ram_41368[];
void DSP_VoiceCoeffRoute(unsigned char part, unsigned char sel)
{
    unsigned int n;
    unsigned int d;
    unsigned char *off;
    unsigned char *tbl;
    unsigned char s;
    unsigned int x;
    unsigned int y;
    unsigned int i;
    s = sel;
    s &= 15;
    x = (*(unsigned char **)&((unsigned char *)(unsigned long)(ram_41368 + (part) * 0x11f))[(int)(s) * 37 + 110])[2];
    x &= 127;
    y = (*(unsigned char **)&((unsigned char *)(unsigned long)(ram_41368 + (part) * 0x11f))[(int)(s) * 37 + 110])[3];
    y &= 15;
    switch ((int)(*(unsigned char **)&((unsigned char *)(unsigned long)(ram_41368 + (part) * 0x11f))[(int)(s) * 37 + 110])[3] & 192) {
    case 0x00:
        off = (unsigned char *)ToneDB_RootPtr[17];
        break;
    case 0x40:
        off = (unsigned char *)ToneDB_RootPtr[19];
        break;
    case 0x80:
        off = (unsigned char *)ToneDB_RootPtr[18];
        break;
    case 0xc0:
        off = (unsigned char *)ToneDB_RootPtr[17];
        break;
    }
    d = *(unsigned long *)((unsigned long)(((y << 7) + x) * 2) + (unsigned long)off + ToneDB_RelBase);
    off = (unsigned char *)ToneDB_RootPtr[20];
    tbl = (unsigned char *)ToneDB_RelBase;
    tbl += (unsigned long)off;
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
