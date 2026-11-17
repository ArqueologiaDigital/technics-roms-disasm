/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_F_12m293b.c (2026-11-16-128-p6-r27)
   sha256 2ec782b463a903a6890940a79461078dcd3e6c77ae8891e16d4c31886460be6d (tar-sha256); compiled at -O3 -Xr */
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
    case 118:
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
        break;
    default:
        r = (char)p[0];
        w = 1;
        m = 0xff;
        break;
    }
    *wout = w;
    *cnt = c;
    *mout = m;
    *tout = t;
    *flag = a8;
    return r;
}
