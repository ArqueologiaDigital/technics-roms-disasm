/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_E_4a.c (2026-11-16-62-sub-r4)
   sha256 044dfcf0a071d4efe674c111b3e359fdaed2ba3a9ddeec0c55a36074808fc82d (name+funcs); compiled at -Xr */
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
