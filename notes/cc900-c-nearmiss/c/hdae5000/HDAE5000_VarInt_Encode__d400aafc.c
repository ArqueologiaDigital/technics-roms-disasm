/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hd/hd_r27_c2b.c (2026-11-16-116-hd-r27c)
   sha256 d400aafc4a0887857f6af0d9108cc69daa1ca6e7738f55adf60c0d44817b30fd (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
long HDAE5000_VarInt_Encode(unsigned long value, unsigned char *out)
{
    unsigned char tmp[6];
    int n;
    int i;

    n = 0;
    do {
        tmp[n] = value & 0x7f;
        value >>= 7;
        n++;
    } while (value != 0);
    for (i = 1; i < n; i++)
        out[n - i - 1] = tmp[i] | 0x80;
    out[n - 1] = tmp[0];
    return n;
}
