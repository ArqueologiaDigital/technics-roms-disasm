/* lane_p6 helper F, round 13, module 293 (audio/dsp_config_sysex.s), form a.
   Run r27: round 12 form a (0x76 branch as a goto to code after the return) is the closest for all three at -O3:
   ReadField +52, Data_ParamDispatch +57, WriteParam +25.
   ReadField: the only differences left are two 2-byte stubs.  The ROM keeps `jr SetWidth2` blocks for case
   0x64/0x67 and for the 0x70 default's `a6 == 1`; V4.23 cross-jumped ours away.  A stub is what an explicit
   `goto` gives, so both jump to a label `w2` on the `w = 2` of case 0x20.
   Data_ParamDispatch: V4.23 inverted the last compare and fell into case 100/103, where the ROM falls into the
   default (which, with the tail after it, sits right after the chain) and keeps case 100/103 as `w = 2;
   goto join` after the epilogue.  Here case 100/103 jumps to a label `join` on the default's `m = 0xff`.
   WriteParam: the ROM loads the value once into BC, takes the high byte into HL before the 0x76 test and the low
   byte from C after the 0x70 test, both used only by case 0x64/0x67.  Our copy into a local put them the other
   way round, so here the case writes `val >> 8` and `val & 0xff` directly and -O3 places them. */

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
    if (t == 118) goto t118;
    r = x;
    switch (t) {
    case 100:
    case 103:
        w = 2;
        goto join;
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
    join:
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

int DSPCfg_WriteParam(unsigned char *p, unsigned char *q, int val, int *vio, unsigned char *mask)
{
    int v;
    int a10;
    int a8;
    int a6;
    unsigned char t;
    unsigned char m;
    unsigned char lo;

    &val;
    v = *vio;
    t = q[2];
    if (t == 0x76) goto t76;
    if (t == 0x70) goto t70;
    switch (t) {
    case 0x64:
    case 0x67:
        p[0] = (unsigned int)val >> 8;
        p[1] = val & 0xff;
        break;
    default:
        *p = val;
        break;
    }
    m = 0xff;
out:
    *vio = v;
    *mask = m;
    return 0;
t70:
    DSPCfg_ExtractFieldSingle(&a10, &a6, q);
    switch (a10) {
    default:
        p[0] = (p[0] & 0xf8) + ((val >> 2) & 7);
        p[1] = (p[1] & 0x3f) + ((val << 6) & 0xc0);
        m = 7;
        break;
    case 0x10:
        p[0] = (p[0] & 7) + ((val << 3) & 0xf8);
        m = 0xf8;
        break;
    case 0x20:
        p[1] = (p[1] & 0xc0) + (val & 0x3f);
        v++;
        m = 0x3f;
        break;
    }
    goto out;
t76:
    DSPCfg_ExtractFieldPair(&a10, &a8, q);
    switch (a10) {
    default:
        p[0] = (p[0] & 0xf8) + ((val >> 2) & 7);
        p[1] = (p[1] & 0x3f) + ((val << 6) & 0xc0);
        m = 7;
        break;
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
    }
    goto out;
}
