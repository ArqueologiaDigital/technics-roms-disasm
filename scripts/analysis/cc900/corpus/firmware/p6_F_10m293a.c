/* lane_p6 helper F, round 10, module 293 (audio/dsp_config_sysex.s), form a.
   Run r21 (p6_F_9m293b): ReadField +8, Data_ParamDispatch +56.  Two spots, both the same in the three routines:
   (1) the ROM tests the ExtractField outputs with the value loaded once into WA and compared as a chain whose
       default body comes first (compare order 0x20 then 0x10): a `switch` on the output, not an if chain;
   (2) the ROM places the store/epilogue block right after the type switch's default body and the other cases
       after it: the default is written LAST in the inner type switch (cases 0x64/0x67, 0x68, 0x70, default; V4.23
       compares in reverse source order).
   Form a keeps `if (t != 0x76) { ... } else { 0x76 }`.  ReadField's case 0x68 widens before the mask (the ROM
   ands HL, not A).  DSPCfg_WriteParam: the ROM keeps p in XIZ and val in the frame (highest slot), so val's
   address is taken once (a statement with no code) to keep it out of XIZ. */

/* cc900-module: DSPCfg_ExtractFieldPair DSPCfg_ExtractFieldSingle */

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
    if (t != 118) {
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
            default:
                r = (x >> 6) & 31;
                m = 7;
                if (a8 == 1) {
                    w = 1;
                    c++;
                }
                break;
            }
            break;
        default:
            r = (char)p[0];
            w = 1;
            m = 0xff;
            break;
        }
    } else {
        DSPCfg_ExtractFieldPair(&a12, &a10, q);
        switch (a12) {
        case 16:
            if (a10 != 2) {
                r = x & 63;
                w = 1;
                c++;
            } else {
                r = (x >> 8) & 63;
                w = 1;
            }
            m = 63;
            break;
        default:
            r = (x >> 6) & 31;
            m = 7;
            break;
        }
    }
    *wout = w;
    *cnt = c;
    *mout = m;
    *tout = t;
    *flag = a8;
    return r;
}

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
    if (t != 0x76) {
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
            case 0x10:
                n = 11;
                goto shift;
            case 0x20:
                r = x & 0x3f;
                w = 2;
                break;
            default:
                r = (x >> 6) & 0x1f;
                if (a6 == 1) w = 2;
                break;
            }
            break;
        default:
            r = (char)p[0];
            w = 1;
            break;
        }
    } else {
        DSPCfg_ExtractFieldPair(&a10, &a8, q);
        switch (a10) {
        case 0x10:
            if (a8 != 2) {
                r = x & 0x3f;
                w = 2;
            } else {
                r = (x >> 8) & 0x3f;
                w = 1;
            }
            break;
        default:
            n = 6;
        shift:
            r = (x >> n) & 0x1f;
            break;
        }
    }
    *wout = w;
    *vio = v;
    return r;
}

int DSPCfg_WriteParam(unsigned char *p, unsigned char *q, int val, int *vio, unsigned char *mask)
{
    int v;
    int a10;
    int a8;
    int a6;
    unsigned char t;
    unsigned char m;
    unsigned int hi;
    unsigned char lo;

    &val;
    v = *vio;
    t = q[2];
    hi = (unsigned int)val >> 8;
    if (t != 0x76) {
        if (t != 0x70) {
            lo = val & 0xff;
            switch (t) {
            case 0x64:
            case 0x67:
                p[0] = hi;
                p[1] = lo;
                break;
            default:
                *p = val;
                break;
            }
            m = 0xff;
        } else {
            DSPCfg_ExtractFieldSingle(&a10, &a6, q);
            switch (a10) {
            case 0x10:
                p[0] = (p[0] & 7) + ((val << 3) & 0xf8);
                m = 0xf8;
                break;
            case 0x20:
                p[1] = (p[1] & 0xc0) + (val & 0x3f);
                v++;
                m = 0x3f;
                break;
            default:
                p[0] = (p[0] & 0xf8) + ((val >> 2) & 7);
                p[1] = (p[1] & 0x3f) + ((val << 6) & 0xc0);
                m = 7;
                break;
            }
        }
    } else {
        DSPCfg_ExtractFieldPair(&a10, &a8, q);
        switch (a10) {
        case 0x10:
            lo = val & 0x3f;
            if (a8 == 2) {
                p[0] = lo;
            } else {
                p[1] = (p[1] & 0xc0) + lo;
                v++;
            }
            m = 0x3f;
            break;
        default:
            p[0] = (p[0] & 0xf8) + ((val >> 2) & 7);
            p[1] = (p[1] & 0x3f) + ((val << 6) & 0xc0);
            m = 7;
            break;
        }
    }
    *vio = v;
    *mask = m;
    return 0;
}
