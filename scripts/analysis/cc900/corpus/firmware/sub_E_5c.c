/* lane_sub helper E, round 5, form c: the decoder callers with DSP_StreamDecode_3ByteWord declared as in its
   staged C (long *out, no conversion of &v), and the interpreter without the int casts in its length. */

struct bcfg { int a; int b; int c; int d; long e; };

extern int DSP_DispatchData(int d, int chip);
extern int DSP_DispatchCommand(int d, int chip);
extern unsigned char *DSP_StreamDecode_3ByteWord(unsigned char *p, long *out);
extern void DSP2_SPI_BusIdle(void);
extern void DSP_Bytecode_NotifyStateChange(void);


long DSP_ParamInterp_FPScale(unsigned char **pp, long b)
{
    long v;
    unsigned char *p;
    long r;

    p = *pp;
    p = DSP_StreamDecode_3ByteWord(p, &v);
    v = (v >> 8) & 0xffffff;
    r = b * 0xac44 / 0x3e8 + v;
    *pp = p;
    return r;
}


long DSP_ParamInterp_2Point(unsigned char **pp, long b)
{
    long v0;
    long v1;
    unsigned char *p;
    long r;

    p = *pp;
    p = DSP_StreamDecode_3ByteWord(p, &v0);
    p = DSP_StreamDecode_3ByteWord(p, &v1);
    r = (v0 >> 8) + ((v1 - v0) >> 8) * b / 0x63;
    *pp = p;
    return r;
}


long DSP_ParamInterp_3Point_WithOffset(unsigned char **pp, long b, long c)
{
    long v0;
    long v1;
    unsigned char *p;
    long r;

    p = *pp;
    p = DSP_StreamDecode_3ByteWord(p, &v0);
    p = DSP_StreamDecode_3ByteWord(p, &v1);
    v0 = (v0 >> 8) & 0xffffff;
    v1 = (v1 >> 8) & 0xffffff;
    r = (c + v0 + (v1 - v0) * b / 0x63) << 8;
    *pp = p;
    return r;
}


long DSP_ParamInterp_MultiStep(unsigned char **pp, long b, int *tbl, int unused, unsigned int n)
{
    long junk;
    long v0;
    long v1;
    unsigned char *p;
    int k;
    long r;

    p = *pp;
    switch (*p++ & 0xf0) {
    case 0x10:
        k = tbl[n - 1];
        break;
    case 0x20:
        k = tbl[n - 2];
        break;
    default:
        k = (int)b;
        break;
    }
    switch (k) {
    case 1:
        p = DSP_StreamDecode_3ByteWord(p, &junk);
        p = DSP_StreamDecode_3ByteWord(p, &junk);
        p = DSP_StreamDecode_3ByteWord(p, &v0);
        p = DSP_StreamDecode_3ByteWord(p, &v1);
        p = DSP_StreamDecode_3ByteWord(p, &junk);
        p = DSP_StreamDecode_3ByteWord(p, &junk);
        break;
    case 2:
        p = DSP_StreamDecode_3ByteWord(p, &junk);
        p = DSP_StreamDecode_3ByteWord(p, &junk);
        p = DSP_StreamDecode_3ByteWord(p, &junk);
        p = DSP_StreamDecode_3ByteWord(p, &junk);
        p = DSP_StreamDecode_3ByteWord(p, &v0);
        p = DSP_StreamDecode_3ByteWord(p, &v1);
        break;
    default:
        p = DSP_StreamDecode_3ByteWord(p, &v0);
        p = DSP_StreamDecode_3ByteWord(p, &v1);
        p = DSP_StreamDecode_3ByteWord(p, &junk);
        p = DSP_StreamDecode_3ByteWord(p, &junk);
        p = DSP_StreamDecode_3ByteWord(p, &junk);
        p = DSP_StreamDecode_3ByteWord(p, &junk);
        break;
    }
    r = (v0 >> 8) + ((v1 - v0) >> 8) * b / 0x63;
    *pp = p;
    return r;
}


long DSP_ParamInterp_Div0xC6(unsigned char **pp, long b)
{
    long v0;
    long v1;
    long t;
    unsigned char *p;
    long q;

    p = *pp;
    p = DSP_StreamDecode_3ByteWord(p, &v0);
    p = DSP_StreamDecode_3ByteWord(p, &v1);
    t = b + 0x63;
    q = ((v1 - v0) >> 8) / 0xc6;
    q = (v0 >> 8) + q * t;
    *pp = p;
    return q;
}


int DSP_BytecodeInterpreter_Init(int chip, unsigned int idx, struct bcfg *cfg, unsigned char *code)
{
    int st;
    unsigned int t;
    unsigned int op;
    unsigned int i;
    unsigned int len;
    int f0;
    int f1;
    int f2;
    int f3;
    long f4;

    f0 = cfg[idx].a;
    f1 = cfg[idx].b;
    f2 = cfg[idx].c;
    f3 = cfg[idx].d;
    f4 = cfg[idx].e;
    while ((*code & 0xf0) != 0xf0) {
        op = *code & 0xf0;
        len = ((*code & 0xf) << 8) + (code[1] & 0xff) - 2;
        code = code + 2;
        switch (op >> 4) {
        case 0:
            st = DSP_DispatchCommand(*code++, chip);
            st = DSP_DispatchData(*code++, chip);
            st = DSP_DispatchData(*code++, chip);
            for (i = 1; i <= (len - 3) / 5; i++) {
                if (*code == 0) {
                    st = DSP_DispatchData(*code++, chip);
                    st = DSP_DispatchData(*code++, chip);
                    t = ((unsigned int)code[0] << 4) + ((code[1] >> 4) & 0xf);
                    t += f1;
                    st = DSP_DispatchData((unsigned char)((t >> 4) & 0xff), chip);
                    st = DSP_DispatchData((unsigned char)((t << 4) & 0xff), chip);
                    code = code + 2;
                    st = DSP_DispatchData(*code++, chip);
                } else if (*code == 10) {
                    st = DSP_DispatchData(*code++, chip);
                    st = DSP_DispatchData(*code++, chip);
                    st = DSP_DispatchData(*code++, chip);
                    st = DSP_DispatchData(*code++, chip);
                    st = DSP_DispatchData(*code++, chip);
                } else {
                    st = DSP_DispatchData(*code++, chip);
                    st = DSP_DispatchData((unsigned char)(code[0] + ((f4 >> 17) & 0x7f)), chip);
                    st = DSP_DispatchData((unsigned char)(code[1] + ((f4 >> 9) & 0xff)), chip);
                    st = DSP_DispatchData((unsigned char)(code[2] + ((f4 >> 1) & 0xff)), chip);
                    st = DSP_DispatchData((unsigned char)(code[3] + ((f4 << 7) & 0x80)), chip);
                    code = code + 4;
                }
            }
            break;
        case 1:
            st = DSP_DispatchCommand(*code++, chip);
            st = DSP_DispatchData(*code++, chip);
            st = DSP_DispatchData(*code++, chip);
            for (i = 1; i <= (len - 3) / 5; i++) {
                st = DSP_DispatchData(*code++, chip);
                st = DSP_DispatchData(*code++, chip);
                t = ((unsigned int)code[0] << 4) + ((code[1] >> 4) & 0xf);
                t += f0;
                st = DSP_DispatchData((unsigned char)((t >> 4) & 0xff), chip);
                st = DSP_DispatchData((unsigned char)(((t << 4) & 0xff) + 8), chip);
                code = code + 2;
                st = DSP_DispatchData(*code++, chip);
            }
            break;
        case 2:
            st = DSP_DispatchCommand(*code++, chip);
            st = DSP_DispatchData(*code++, chip);
            st = DSP_DispatchData(*code++, chip);
            for (i = 1; i <= (len - 3) / 3; i++) {
                st = DSP_DispatchData(*code++, chip);
                st = DSP_DispatchData(*code++, chip);
                st = DSP_DispatchData(*code++, chip);
            }
            break;
        case 3:
            st = DSP_DispatchCommand(*code++, chip);
            t = ((unsigned int)code[0] << 8) + (code[1] & 0xff);
            t += f3;
            st = DSP_DispatchData((unsigned char)((t >> 8) & 0xff), chip);
            st = DSP_DispatchData((unsigned char)(t & 0xff), chip);
            code = code + 2;
            for (i = 1; i <= len - 3; i++)
                st = DSP_DispatchData(*code++, chip);
            break;
        case 4:
            st = DSP_DispatchCommand(*code++, chip);
            break;
        case 5:
            st = DSP_DispatchCommand(*code++, chip);
            st = DSP_DispatchData(*code++, chip);
            st = DSP_DispatchData(*code++, chip);
            for (i = 1; i <= (len - 3) / 5; i++) {
                if (*code == 8) {
                    st = DSP_DispatchData(*code++, chip);
                    st = DSP_DispatchData(*code++, chip);
                    t = ((unsigned int)code[0] << 4) + ((code[1] >> 4) & 0xf);
                    t += f2;
                    t &= 0xff;
                    st = DSP_DispatchData((unsigned char)((t >> 4) & 0xff), chip);
                    st = DSP_DispatchData((unsigned char)(((t << 4) & 0xff) + 8), chip);
                    code = code + 2;
                    st = DSP_DispatchData(*code++, chip);
                } else {
                    st = DSP_DispatchData(*code++, chip);
                    st = DSP_DispatchData((unsigned char)(code[0] + ((f4 >> 17) & 0x7f)), chip);
                    st = DSP_DispatchData((unsigned char)(code[1] + ((f4 >> 9) & 0xff)), chip);
                    st = DSP_DispatchData((unsigned char)(code[2] + ((f4 >> 1) & 0xff)), chip);
                    st = DSP_DispatchData((unsigned char)(code[3] + ((f4 << 7) & 0x80)), chip);
                    code = code + 4;
                }
            }
            break;
        case 0xd:
            DSP2_SPI_BusIdle();
            DSP_Bytecode_NotifyStateChange();
            break;
        case 0xe:
            st = DSP_DispatchCommand(*code++, chip);
            for (i = 1; i <= len - 1; i++)
                st = DSP_DispatchData(*code++, chip);
            break;
        }
    }
    return st;
}
