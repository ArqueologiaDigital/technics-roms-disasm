/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_F_11m293b.c (2026-11-16-123-p6-r25)
   sha256 51fcbe02aa1d2f9456245a6997f2450f67b504e09ed597201146fb57dfea8b0d (tar-sha256); compiled at -O3 -Xr */
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
    r = x;
    switch (t) {
    case 0x64:
    case 0x67:
        w = 2;
        break;
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
            if (a6 == 1) w = 2;
            break;
        case 0x10:
            n = 11;
            goto shift;
        case 0x20:
            r = x & 0x3f;
            w = 2;
            break;
        }
        break;
    case 0x76:
        DSPCfg_ExtractFieldPair(&a10, &a8, q);
        switch (a10) {
        default:
            n = 6;
        shift:
            r = (x >> n) & 0x1f;
            break;
        case 0x10:
            if (a8 != 2) {
                r = x & 0x3f;
                w = 2;
            } else {
                r = (x >> 8) & 0x3f;
                w = 1;
            }
            break;
        }
        break;
    default:
        r = (char)p[0];
        w = 1;
        break;
    }
    *wout = w;
    *vio = v;
    return r;
}
