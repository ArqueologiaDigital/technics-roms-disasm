/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_E_5b.c (2026-11-16-65-sub-r5)
   sha256 8103302d06eded4296168063c7cacbdd09fcb9eb64632e2961ad999d3ff8d85b (name+funcs); compiled at -Xr */
unsigned char *DSP_TableWalk_SearchWithState(unsigned char *p, int n, int *st, unsigned char **out)
{
    unsigned int w;
    int r;
    int *s;

    s = st;
    while (((w = ((unsigned int)p[0] << 8) + p[1]) >> 8) != 0xf0) {
        if (n == 0) {
            r = 0;
            *out = p + w;
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
