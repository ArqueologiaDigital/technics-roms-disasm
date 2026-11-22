/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_AU_45b.c (2026-11-21-13-sub-r45a)
   sha256 64cf4c421b0baee2da580e3b243aa8148ab7eeef4f5aa0ab7fe64d9ccf677796 (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
extern volatile float DSP_EQ_FreqHz_Table[];
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
        fr = *(volatile float *)((unsigned char *)DSP_EQ_FreqHz_Table + (tbl[i]) * 4);
        g = tbl[i + 1] * 0.5 + -12.0;
        break;
    case 0x10:
        fr = *(volatile float *)((unsigned char *)DSP_EQ_FreqHz_Table + (tbl[i - 1]) * 4);
        g = tbl[i] * 0.5 + -12.0;
        break;
    }
    if (m == 2) {
        fr = *(volatile float *)((unsigned char *)DSP_EQ_FreqHz_Table + (*p++ & 0x1f) * 4);
    }
    *mo = m;
    *fo = fr;
    *go = g;
    return p;
}
