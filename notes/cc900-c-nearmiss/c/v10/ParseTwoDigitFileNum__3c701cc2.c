/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_1b.c (2026-11-16-31-p6-r1b)
   sha256 3c701cc280ffa91c9be4bfde230be135727936b7adbcf85cb0819f84e269f11d (tar-sha256); compiled at -O3 -XS -Xr */
int ParseTwoDigitFileNum(char *s)
{
    char c, v;
    if (s[0] < '0' || s[0] > '2') return -1;
    c = s[1];
    if (c < '0' || c > '9') return -1;
    v = s[0] * 10 + c - 0x10;
    if (v < 1 || v > 20) return -1;
    return v - 1;
}
