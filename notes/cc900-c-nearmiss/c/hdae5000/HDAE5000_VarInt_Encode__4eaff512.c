/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hd/hd_r27_c2.c (2026-11-16-116-hd-r27c)
   sha256 4eaff5124d09d8fd753256fae45b448e8bec06edd9466c96cd5dfc33460d7540 (tar-sha256); compiled at -Xr
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
