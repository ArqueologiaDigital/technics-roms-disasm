/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_AU_45c.c (2026-11-21-13-sub-r45a)
   sha256 410a47929419e6c017f7d6fdb0871e47f7a009df33d1c8198b56b986575f3485 (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
extern unsigned char DSP_EQ_FreqHz_Table[];
unsigned char *DSP_SOS_LUT_Fetch(register unsigned int i, float *fo, float *go, int *mo, int *tbl, unsigned char *p)
{
    float fr;
    float g;
    int m;
    unsigned char c;

    m = *p & 0xf;
    c = *p++ & 0xf0;
    switch (c) {
    default:
        fr = *(volatile float *)&DSP_EQ_FreqHz_Table[(tbl[i]) << 2];
        g = tbl[i + 1] * 0.5 + -12.0;
        break;
    case 0x10:
        fr = *(volatile float *)&DSP_EQ_FreqHz_Table[(tbl[i - 1]) << 2];
        g = tbl[i] * 0.5 + -12.0;
        break;
    }
    switch (m) {
    case 2:
        fr = *(volatile float *)&DSP_EQ_FreqHz_Table[(*p++ & 0x1f) << 2];
        break;
    }
    *mo = m;
    *fo = fr;
    *go = g;
    return p;
}
