/* lane_p6 helper F, round 3, module 293 (audio/dsp_config_sysex.s), form a.
   DSPCfg_ReadField / DSPCfg_WriteParam: read or write one DSP parameter field of a 2-byte register image by the
   field type byte q[2] (0x64 / 0x67 word, 0x68 byte, 0x70 / 0x76 bit fields described by the ExtractField
   helpers, which they reach with calr).  The ROM keeps the type in a byte register (QL / QC).
   Form a: a switch written with `default` first (the ROM compares the cases in reverse source order and falls
   into the default body), the shared shift-and-mask reached by goto. */

/* cc900-module: DSPCfg_ExtractFieldPair DSPCfg_ExtractFieldSingle */

extern void DSPCfg_ExtractFieldPair(int *, int *, unsigned char *);
extern void DSPCfg_ExtractFieldSingle(int *, int *, unsigned char *);

int DSPCfg_ReadField(unsigned char *p, unsigned char *q, int *wout, int *vio)
{
    int v;
    int a6;
    int a8;
    int a10;
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
        r = (char)p[0];
        w = 1;
        break;
    case 0x64:
    case 0x67:
        r = x;
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

int DSPCfg_WriteParam(unsigned char *p, unsigned char *q, int val, unsigned char *mask, int *vio)
{
    int v;
    int a6;
    int a8;
    int a10;
    unsigned char t;
    unsigned char m;

    v = *vio;
    t = q[2];
    switch (t) {
    default:
        *p = val;
        m = 0xff;
        break;
    case 0x64:
    case 0x67:
        p[0] = (val >> 8) & 0xff;
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
