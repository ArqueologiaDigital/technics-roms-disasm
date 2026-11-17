/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_F_13m293a.c (2026-11-17-2-p6-r29)
   sha256 09bfb127e3fc4f60a46668bbabab465a385437c6032e10446ef9f1518167a16f (tar-sha256); compiled at -O3 -Xr */
extern void DSPCfg_ExtractFieldPair(int *, int *, unsigned char *);
extern void DSPCfg_ExtractFieldSingle(int *, int *, unsigned char *);
int DSPCfg_ReadField(unsigned char *p, unsigned char *q, int *wout, int *vio)
{
    int v;
    int a10;
    int a8;
    int a6;
    unsigned int x;
    int w;
    unsigned char t;
    int r;
    int n;

    w = 0;
    x = ((unsigned int)p[0] << 8) + p[1];
    v = *vio;
    t = q[2];
    if (t == 0x76) goto t76;
    r = x;
    switch (t) {
    case 0x64:
    case 0x67:
        goto w2;
    case 0x68:
        r = (char)p[0];
        r &= 0xff;
        w = 1;
        break;
    case 0x70:
        DSPCfg_ExtractFieldSingle(&a10, &a6, q);
        switch (a10) {
        default:
            r = (x >> 6) & 0x1f;
            if (a6 == 1) goto w2;
            break;
        case 0x10:
            n = 11;
            goto shift;
        case 0x20:
            r = x & 0x3f;
        w2:
            w = 2;
            break;
        }
        break;
    default:
        r = (char)p[0];
        w = 1;
        break;
    }
out:
    *wout = w;
    *vio = v;
    return r;
t76:
    DSPCfg_ExtractFieldPair(&a10, &a8, q);
    switch (a10) {
    default:
        n = 6;
    shift:
        r = (x >> n) & 0x1f;
        break;
    case 0x10:
        if (a8 == 2) {
            r = (x >> 8) & 0x3f;
            w = 1;
        } else {
            r = x & 0x3f;
            w = 2;
        }
        break;
    }
    goto out;
}
