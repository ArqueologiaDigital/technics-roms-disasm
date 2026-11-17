/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_A_9a.c (2026-11-16-86-sub-r9)
   sha256 88eb9f6250e886eb73d0ea17657ceaba2c1d96ee178a9e302b394fec469d7fa4 (name+funcs); compiled at -Xr */
void Voice_Selector_Unpack3Groups(unsigned char *p, unsigned int v, int e);
void Voice_Selector_FindBestSlot(unsigned int *w, unsigned char *cnt, unsigned char *idx, unsigned char *val)
{
    unsigned char g[10];
    unsigned char hi, lo, d;
    Voice_Selector_Unpack3Groups(g, w[0], 0);
    Voice_Selector_Unpack3Groups(g, w[1], 1);
    Voice_Selector_Unpack3Groups(g, w[2], 2);
    hi = 0xff;
    lo = 0xff;
    *cnt = 0;
    for (d = 0; d < 9; d++) {
        if (lo == 0xff && g[d] != 0) lo = d;
        if (g[d] >= 4) {
            (*cnt)++;
            if (hi == 0xff) hi = d;
        }
    }
    if (hi != 0xff) {
        *idx = hi;
        *val = g[hi];
    } else {
        *idx = lo;
        *val = g[lo];
    }
}
