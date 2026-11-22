/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_AU_46b.c (2026-11-21-15-sub-r46a)
   sha256 2b24513b52f170a388552055d14707d5a338a1fe4819b6719e7e28f0d707b1c4 (tar-sha256); compiled at -Xr
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
        fr = *(volatile float *)&DSP_EQ_FreqHz_Table[tbl[i] * 4];
        g = tbl[i + 1] * 0.5 + -12.0;
        break;
    case 0x10:
        fr = *(volatile float *)&DSP_EQ_FreqHz_Table[tbl[i - 1] * 4];
        g = tbl[i] * 0.5 + -12.0;
        break;
    }
    switch (m) {
    case 2:
        fr = *(volatile float *)&DSP_EQ_FreqHz_Table[(unsigned int)(*p++ & 0x1f) * 4];
        break;
    }
    *mo = m;
    *fo = fr;
    *go = g;
    return p;
}
