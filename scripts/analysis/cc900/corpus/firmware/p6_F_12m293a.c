/* lane_p6 helper F, round 12, module 293 (audio/dsp_config_sysex.s), form a.
   Run r25: the flat switch with the default LAST (r11 form b) gave the ROM's main layout (default body, then the
   store/epilogue, then the other cases) but loads the word value before the 0x76 test, where the ROM loads it
   after; nesting the 0x76 test as `switch`/`if` with an else either put the 0x76 code first or stopped the
   default's move (the move happens only when the default falls straight into the tail).
   So here the 0x76 (and WriteParam's 0x70) branch is a `goto` to code placed AFTER the return: the rest falls
   through into the tail, and the 0x76 code comes last, as in the ROM.
   Also: the ROM tests the pair flag as `== 2` and falls into that branch, jumping to the shared
   `x & 0x3f` code otherwise, so the conditions are written `a == 2`. */

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
    unsigned int u;
    unsigned int hi;
    unsigned char lo;

    &val;
    v = *vio;
    t = q[2];
    u = val;
    hi = u >> 8;
    if (t == 0x76) goto t76;
    if (t == 0x70) goto t70;
    lo = u & 0xff;
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
