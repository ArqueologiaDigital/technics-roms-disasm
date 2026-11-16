/* lane_p6 helper F, round 9, module 293 (audio/dsp_config_sysex.s), form a.
   Run r19: DSPCfg_Data_ParamDispatch differed (+36) only where the ROM loads the word value (ld HL,IZ) after the
   0x76 compare.  A nested switch puts it there: the outer switch has only case 0x76, its default body sets the
   word value and runs the inner switch (compared 0x70, [0x68,] 0x67, 0x64 as the ROM does).
   Stack arguments: V4.23 pushes the 4th first, so the callee finds the 4th argument at the HIGHEST slot; the
   ROM's (xsp+0x22) / (xsp+0x16) operands give DSPCfg_Data_ParamDispatch the order (p, q, wout, cnt, mout, tout,
   flag) and DSPCfg_WriteParam (p, q, val, vio, mask). */

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
    switch (t) {
    default:
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
    switch (t) {
    default:
        r = x;
        switch (t) {
        default:
            r = (char)p[0];
            w = 1;
            break;
        case 0x64:
        case 0x67:
            w = 2;
            break;
        case 0x68:
            r = (char)p[0] & 0xff;
            w = 1;
            break;
        case 0x70:
            DSPCfg_ExtractFieldSingle(&a10, &a6, q);
            if (a10 == 0x20) {
                r = x & 0x3f;
                w = 2;
            } else if (a10 == 0x10) {
                n = 11;
                goto shift;
            } else {
                r = (x >> 6) & 0x1f;
                if (a6 == 1) w = 2;
            }
            break;
        }
        break;
    case 0x76:
        DSPCfg_ExtractFieldPair(&a10, &a8, q);
        if (a10 == 0x10) {
            if (a8 != 2) {
                r = x & 0x3f;
                w = 2;
            } else {
                r = (x >> 8) & 0x3f;
                w = 1;
            }
        } else {
            n = 6;
        shift:
            r = (x >> n) & 0x1f;
        }
        break;
    }
    *wout = w;
    *vio = v;
    return r;
}

int DSPCfg_WriteParam(register unsigned char *p, unsigned char *q, int val, int *vio, unsigned char *mask)
{
    int v;
    int a10;
    int a8;
    int a6;
    unsigned char t;
    unsigned char m;

    v = *vio;
    t = q[2];
    switch (t) {
    default:
        switch (t) {
        default:
            *p = val;
            m = 0xff;
            break;
        case 0x64:
        case 0x67:
            p[0] = (unsigned int)val >> 8;
            p[1] = val & 0xff;
            m = 0xff;
            break;
        case 0x70:
            DSPCfg_ExtractFieldSingle(&a10, &a6, q);
            if (a10 == 0x20) {
                p[1] = (p[1] & 0xc0) + (val & 0x3f);
                v++;
                m = 0x3f;
            } else if (a10 == 0x10) {
                p[0] = (p[0] & 7) + ((val << 3) & 0xf8);
                m = 0xf8;
            } else {
                p[0] = (p[0] & 0xf8) + ((val >> 2) & 7);
                p[1] = (p[1] & 0x3f) + ((val << 6) & 0xc0);
                m = 7;
            }
            break;
        }
        break;
    case 0x76:
        DSPCfg_ExtractFieldPair(&a10, &a8, q);
        if (a10 == 0x10) {
            if (a8 == 2) {
                p[0] = val & 0x3f;
            } else {
                p[1] = (p[1] & 0xc0) + (val & 0x3f);
                v++;
            }
            m = 0x3f;
        } else {
            p[0] = (p[0] & 0xf8) + ((val >> 2) & 7);
            p[1] = (p[1] & 0x3f) + ((val << 6) & 0xc0);
            m = 7;
        }
        break;
    }
    *vio = v;
    *mask = m;
    return 0;
}
