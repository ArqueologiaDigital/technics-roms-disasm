/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_F_12m293a.c (2026-11-16-128-p6-r27)
   sha256 117e572066aca537f4e7506c1d3058463533fa4231a71c22c4a3f8d8e44022dc (tar-sha256); compiled at -O3 -Xr */
extern void DSPCfg_ExtractFieldPair(int *, int *, unsigned char *);
extern void DSPCfg_ExtractFieldSingle(int *, int *, unsigned char *);
int DSPCfg_Data_ParamDispatch(unsigned char *p, unsigned char *q, int *wout, unsigned char *cnt,
                              unsigned char *mout, unsigned char *tout, unsigned char *flag)
{
    int a12;
    int a10;
    int a8;
    unsigned char c;
    unsigned char t;
    unsigned int x;
    int w;
    int r;
    unsigned char m;

    w = 0;
    a8 = 0;
    x = ((unsigned int)p[0] << 8) + p[1];
    c = *cnt;
    t = q[2];
    if (t == 118) goto t118;
    r = x;
    switch (t) {
    case 100:
    case 103:
        w = 2;
        m = 0xff;
        break;
    case 112:
        DSPCfg_ExtractFieldSingle(&a12, &a8, q);
        switch (a12) {
        default:
            r = (x >> 6) & 31;
            m = 7;
            if (a8 == 1) {
                w = 1;
                c++;
            }
            break;
        case 16:
            r = (x >> 11) & 31;
            m = 248;
            break;
        case 32:
            r = x & 63;
            w = 1;
            c++;
            m = 63;
            break;
        }
        break;
    default:
        r = (char)p[0];
        w = 1;
        m = 0xff;
        break;
    }
out:
    *wout = w;
    *cnt = c;
    *mout = m;
    *tout = t;
    *flag = a8;
    return r;
t118:
    DSPCfg_ExtractFieldPair(&a12, &a10, q);
    switch (a12) {
    default:
        r = (x >> 6) & 31;
        m = 7;
        break;
    case 16:
        if (a10 == 2) {
            r = (x >> 8) & 63;
            w = 1;
        } else {
            r = x & 63;
            w = 1;
            c++;
        }
        m = 63;
        break;
    }
    goto out;
}
