/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hd/hd_r27_c2b.c (2026-11-16-116-hd-r27c)
   sha256 d400aafc4a0887857f6af0d9108cc69daa1ca6e7738f55adf60c0d44817b30fd (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
long HDAE5000_VarInt_Decode(unsigned char *p, unsigned char *count)
{
    int i;
    long r;
    unsigned char first;

    i = 0;
    r = 0;
    first = p[0];
    do {
        r += p[i] & 0x7f;
        if ((p[i] & 0x80) == 0) {
            *count = i + 1;
            return r;
        }
        i++;
        r <<= 7;
    } while ((i <= 4 || first <= 7) && i <= 5);
    return -1;
}
