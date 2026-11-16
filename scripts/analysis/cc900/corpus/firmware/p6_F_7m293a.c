/* lane_p6 helper F, round 7, module 293 (audio/dsp_config_sysex.s), form a.  New routines.
   DSPCfg_Data_ParamDispatch: DSPCfg_ReadField's sibling with seven outputs (width, write mask, type, a field flag,
   and a counter it bumps); the type byte lives in a stack slot.
   DSPCfg_ApplyParamStruct: for an effect-parameter record s (s[0] = effect type): types 0x10..0x1b shift bytes
   2..5 up by one; the others walk the type's field descriptors twice with DSPCfg_ReadFieldSimple /
   DSPCfg_PackAddress, store s[21] before the end of the packed fields (2 back for the types of the switch, else
   1), then store the 2-byte field values.
   Address-taken locals are declared highest slot first; plain scalars lowest slot first (run 55 / 87 rules). */

/* cc900-module: DSPCfg_CheckParamTableEntry DSPCfg_ExtractFieldPair DSPCfg_ExtractFieldSingle DSPCfg_PackAddress DSPCfg_ReadFieldSimple */

extern void DSPCfg_ExtractFieldPair(int *, int *, unsigned char *);
extern void DSPCfg_ExtractFieldSingle(int *, int *, unsigned char *);
extern int DSPCfg_CheckParamTableEntry(int);
extern int DSPCfg_ReadFieldSimple(unsigned char *, unsigned char *, int *, int *);
extern unsigned char *DSPCfg_PackAddress(unsigned char *);
extern unsigned char DspFxParamCountTable[];
extern unsigned char *DspFxRecListPtrTable[];

int DSPCfg_Data_ParamDispatch(unsigned char *p, unsigned char *q, int *wout, unsigned char *flag,
                              unsigned char *tout, unsigned char *mout, unsigned char *cnt)
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
    default:
        r = (char)p[0];
        w = 1;
        m = 0xff;
        break;
    case 100:
    case 103:
        w = 2;
        m = 0xff;
        break;
    case 112:
        DSPCfg_ExtractFieldSingle(&a12, &a8, q);
        if (a12 == 32) {
            r = x & 63;
            w = 1;
            c++;
            m = 63;
        } else if (a12 == 16) {
            r = (x >> 11) & 31;
            m = 248;
        } else {
            r = (x >> 6) & 31;
            m = 7;
            if (a8 == 1) {
                w = 1;
                c++;
            }
        }
        break;
    case 118:
        DSPCfg_ExtractFieldPair(&a12, &a10, q);
        if (a12 == 16) {
            if (a10 != 2) {
                r = x & 63;
                w = 1;
                c++;
            } else {
                r = (x >> 8) & 63;
                w = 1;
            }
            m = 63;
        } else {
            r = (x >> 6) & 31;
            m = 7;
        }
        break;
    }
    *wout = w;
    *cnt = c;
    *mout = m;
    *tout = t;
    *flag = a8;
    return r;
}

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
    rec = *(unsigned char **)((unsigned long)DspFxRecListPtrTable + (long)t * 4);
    for (i = 0; i < cnt; i++) {
        a18 += w20;
        DSPCfg_ReadFieldSimple(p, rec, &w20, &a18);
        for (k = 0; k < w20; k++) p++;
        rec = DSPCfg_PackAddress(rec);
    }
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
    rec = *(unsigned char **)((unsigned long)DspFxRecListPtrTable + (long)t * 4);
    for (i = 0; i < cnt; i++) {
        a18 += w20;
        val = DSPCfg_ReadFieldSimple(p, rec, &w20, &a18);
        if (w20 == 2) {
            p[0] = val & 0xff;
            p[1] = (val >> 8) & 0xff;
        }
        for (k = 0; k < w20; k++) p++;
        rec = DSPCfg_PackAddress(rec);
    }
    return err;
}
