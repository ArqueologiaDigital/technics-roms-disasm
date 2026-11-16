/* lane_p6 helper F, round 5, module 293 (audio/dsp_config_sysex.s), form a.
   Refinements of round 3 (run 87): V4.23 gives address-taken scalars descending slots in declaration order (like
   arrays), so the ExtractField outputs are declared a10, a8, a6 for the ROM's +10 / +8 / +6; the word value is
   assigned before the switch (the ROM loads it between the type compares); DSPCfg_WriteParam's destination
   pointer is `register` (the ROM keeps it in XIZ and the value in memory). */

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

int DSPCfg_WriteParam(register unsigned char *p, unsigned char *q, int val, unsigned char *mask, int *vio)
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
