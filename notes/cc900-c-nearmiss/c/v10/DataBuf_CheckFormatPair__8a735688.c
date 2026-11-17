/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_1b.c (2026-11-16-30-p6-r1)
   sha256 8a7356886e18f7ab911e798723ccf50ecdd2436ab818c9ee86a2ecf0d3209eb9 (tar-sha256); compiled at -O3 -XS -Xr */
int DataBuf_CheckFormatPair(char *p)
{
    char c = p[4];
    char d;
    p += 5;
    if (c == 'M' && *p == '4') return 1;
    d = *p;
    if (c == 'M' && d == '6') return 2;
    if (c == 'N' && d == 'N') return 3;
    return -1;
}
