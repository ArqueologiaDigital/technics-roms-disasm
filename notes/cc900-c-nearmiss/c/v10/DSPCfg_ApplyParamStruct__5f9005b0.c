/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_F_7m293b.c (2026-11-16-100-p6-r19)
   sha256 5f9005b09c1ef6dfa52d38fe0ffd0e6724cb7e0551fd66e9488753a692f2fa4d (tar-sha256); compiled at -O3 -Xr */
extern int DSPCfg_CheckParamTableEntry(int);
extern int DSPCfg_ReadFieldSimple(unsigned char *, unsigned char *, int *, int *);
extern unsigned char *DSPCfg_PackAddress(unsigned char *);
extern unsigned char DspFxParamCountTable[];
extern unsigned char *DspFxRecListPtrTable[];
int DSPCfg_ApplyParamStruct(unsigned char *s)
{
    int w20;
    int a18;
    int t;
    unsigned int cnt;
    int err;
    int v;
    unsigned int i;
    unsigned char *rec;
    unsigned char *p;
    unsigned int k;
    long off;
    int val;

    p = s;
    t = p[0];
    cnt = DspFxParamCountTable[t];
    err = DSPCfg_CheckParamTableEntry(t);
    if (err != 0) return err;
    if (t >= 0x10 && t <= 0x1b) {
        p[6] = p[5];
        p[5] = p[4];
        p[4] = p[3];
        p[3] = p[2];
        p[2] = 0;
        return err;
    }
    w20 = 0;
    a18 = 0;
    v = p[21];
    p = s + 1;
    rec = DspFxRecListPtrTable[t];
    i = 0;
    if (cnt > 0) do {
        a18 += w20;
        DSPCfg_ReadFieldSimple(p, rec, &w20, &a18);
        for (k = 0; k < w20; k++) p++;
        rec = DSPCfg_PackAddress(rec);
    } while (++i < cnt);
    switch (t) {
    case 0x20:
    case 0x21:
    case 0x22:
    case 0x23:
    case 0x0f:
    case 0x35:
    case 0x60:
    case 0x61:
    case 0x62:
    case 0x63:
        off = 2;
        break;
    default:
        off = 1;
        break;
    }
    *(p - off) = v;
    w20 = 0;
    a18 = 0;
    p = s + 1;
    rec = DspFxRecListPtrTable[t];
    i = 0;
    if (cnt > 0) do {
        a18 += w20;
        val = DSPCfg_ReadFieldSimple(p, rec, &w20, &a18);
        if (w20 == 2) {
            p[0] = val & 0xff;
            p[1] = (val >> 8) & 0xff;
        }
        for (k = 0; k < w20; k++) p++;
        rec = DSPCfg_PackAddress(rec);
    } while (++i < cnt);
    return err;
}
