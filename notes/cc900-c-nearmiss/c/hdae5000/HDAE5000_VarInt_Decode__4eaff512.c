/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hd/hd_r27_c2.c (2026-11-16-116-hd-r27c)
   sha256 4eaff5124d09d8fd753256fae45b448e8bec06edd9466c96cd5dfc33460d7540 (tar-sha256); compiled at -Xr
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
        r += p[i] & 0x7fU;
        if ((p[i] & 0x80) == 0) {
            *count = i + 1;
            return r;
        }
        i++;
        r <<= 7;
    } while ((i <= 4 || first <= 7) && i <= 5);
    return -1;
}
