/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_E_4b.c (2026-11-16-62-sub-r4)
   sha256 3f6b729e7593b6348d4062d2bc31effd2d177be96053ddeab43e3728401960d2 (name+funcs); compiled at -Xr */
unsigned char *DSP_TableWalk_SearchWithState(unsigned char *p, int n, int *st, unsigned char **out)
{
    int r;
    unsigned int w;
    int *s;

    s = st;
    while (((w = ((unsigned int)p[0] << 8) + p[1]) >> 8) != 0xf0) {
        if (n == 0) {
            *out = p + w;
            r = 0;
            p = p + 2;
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
