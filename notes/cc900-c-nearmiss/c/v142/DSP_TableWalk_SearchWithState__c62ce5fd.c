/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_E_3a.c (2026-11-16-58-sub-r3)
   sha256 c62ce5fddcf8b613845ab6dee451222d9696446cb538d0e863a5815dd894a1aa (name+funcs); compiled at -Xr */
unsigned char *DSP_TableWalk_SearchWithState(unsigned char *p, int n, int *st, unsigned char **out)
{
    int *s;
    unsigned int w;
    int r;

    s = st;
    while (((w = ((unsigned int)p[0] << 8) + p[1]) >> 8) != 0xf0) {
        if (n == 0) {
            r = 0;
            *out = p + w;
            p += 2;
            goto done;
        }
        p += w;
        n--;
    }
    r = 2;
done:
    *s = r;
    return p;
}
