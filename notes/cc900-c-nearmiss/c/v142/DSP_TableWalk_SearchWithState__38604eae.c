/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_E_5a.c (2026-11-16-65-sub-r5)
   sha256 38604eaef711c8975f39133271ddd4a463dd44abf935b4ade97a469216c12a20 (name+funcs); compiled at -Xr */
unsigned char *DSP_TableWalk_SearchWithState(unsigned char *p, int n, int *st, unsigned char **out)
{
    int r;
    unsigned int w;
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
