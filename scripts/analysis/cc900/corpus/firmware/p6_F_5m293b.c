/* lane_p6 helper F, round 5, module 293 (audio/dsp_config_sysex.s), form b.
   As form a, with the 0x76 type tested first by an `if` and the rest a switch (DSPCfg_ReadField assigns the word
   value after the 0x76 test, where the ROM loads it); DSPCfg_WriteParam takes the high byte into a local before
   the tests, as the ROM computes it ahead of the compares. */

/* cc900-module: DSPCfg_ExtractFieldPair DSPCfg_ExtractFieldSingle */

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
    if (t == 0x76) {
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
            r = (x >> n) & 0x1f;
        }
    } else {
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
                r = (x >> n) & 0x1f;
            } else {
                r = (x >> 6) & 0x1f;
                if (a6 == 1) w = 2;
            }
            break;
        }
    }
    *wout = w;
    *vio = v;
    return r;
}

int DSPCfg_WriteParam(register unsigned char *p, unsigned char *q, int val, unsigned char *mask, int *vio)
{
    int v;
    int a10;
    int a8;
    int a6;
    unsigned char t;
    unsigned char m;
    unsigned char hi;

    v = *vio;
    t = q[2];
    hi = (unsigned int)val >> 8;
    if (t == 0x76) {
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
    } else if (t == 0x70) {
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
    } else if (t == 0x67 || t == 0x64) {
        p[0] = hi;
        p[1] = val & 0xff;
        m = 0xff;
    } else {
        p[0] = val;
        m = 0xff;
    }
    *vio = v;
    *mask = m;
    return 0;
}
