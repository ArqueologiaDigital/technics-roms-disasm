/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_K_16a.c (2026-11-16-112-sub-r16)
   sha256 0dd0b6eeed5c6a54476ccb99223cdb0df25da8942b516f612d6d27be01083fe5 (name+funcs); compiled at -Xr */
extern unsigned char ram_41368[];
extern unsigned char ram_45210[];
extern unsigned long ToneDB_RelBase;
extern unsigned long *ToneDB_RootPtr;
void DSP_VoiceCoeffRoute2(unsigned char part, unsigned char sel)
{
    unsigned char s;
    unsigned char z;
    unsigned int x;
    unsigned int y;
    unsigned long tbl;
    unsigned int d;
    unsigned int n;
    unsigned int i;
    s = sel & 15;
    z = (sel & 0xf0) >> 4;
    x = (*(unsigned char **)((unsigned long)&((unsigned char *)(unsigned long)(ram_41368 + (part) * 0x11f))[(int)(s) * 37 + 110] + 4))[(int)z * 2 + 3];
    x &= 127;
    y = *(unsigned char *)((unsigned long)&(*(unsigned char **)((unsigned long)&((unsigned char *)(unsigned long)(ram_41368 + (part) * 0x11f))[(int)(s) * 37 + 110] + 4))[(int)z * 2 + 3] + 1);
    y &= 15;
    switch ((int)*(unsigned char *)((unsigned long)&(*(unsigned char **)((unsigned long)&((unsigned char *)(unsigned long)(ram_41368 + (part) * 0x11f))[(int)(s) * 37 + 110] + 4))[(int)z * 2 + 3] + 1) & 192) {
    case 0x00:
        tbl = ToneDB_RootPtr[22];
        break;
    case 0x40:
        tbl = ToneDB_RootPtr[24];
        break;
    case 0x80:
        tbl = ToneDB_RootPtr[23];
        break;
    case 0xc0:
        tbl = ToneDB_RootPtr[22];
        break;
    }
    d = *(unsigned long *)((unsigned long)(((y << 7) + x) * 2) + tbl + ToneDB_RelBase);
    tbl = ToneDB_RootPtr[25];
    tbl = ToneDB_RelBase + tbl;
    n = 13;
    for (i = 0; i < n; i++)
        ram_45210[i + 6] = ((unsigned char *)tbl)[(unsigned long)d * 16 + i];
    ram_45210[n + 6] = ((unsigned char *)tbl + (unsigned long)d * 16)[13];
    n++;
    ram_45210[n + 6] = (unsigned char)(d & 0xff);
    n++;
    ram_45210[n + 6] = (unsigned char)(d >> 8);
    n++;
}
