/* lane_sub helper E, round 5, form b: other spellings of sub_E_5a.c's functions (sub-CPU payload v1.42): the
   pointer store before a return expression, default cases first, a local for the FreqCurve divisor, the record
   address as an integer, an unsigned char key, the left cast only in the interpreter's length. */

struct bcfg { int a; int b; int c; int d; long e; };
struct pent { char pad[4]; unsigned char f[52]; };
struct pblk { char pad[8]; struct pent e[2000]; };

extern struct bcfg ToneGen_WorkArea[];
extern unsigned char DSP_Eff9_Param_Descriptors[];
extern unsigned char DSP_Eff9_Param_Values[];
extern unsigned char DSP_EffA_Param_Descriptors[];
extern unsigned char DSP_EffA_Param_Values[];
extern unsigned char *DSP_Param_Block_Ptrs_A[];
extern unsigned char *DSP_Param_Block_Ptrs_B[];

extern int DSP_DispatchData(int d, int chip);
extern int DSP_DispatchCommand(int d, int chip);
extern void DSP_ParameterWriteEngine(unsigned int slot, struct bcfg *work, void *desc, void *vals, int v,
                                     unsigned char *rec);
extern unsigned char *DSP_TableWalk_Search(void *p, unsigned int key, unsigned int len, int *out);
extern unsigned char *DSP_StreamDecode_3ByteWord(unsigned char *p, void *out);
extern void DSP2_SPI_BusIdle(void);
extern void DSP_Bytecode_NotifyStateChange(void);

unsigned char *DSP_TableWalk_SearchWithState(unsigned char *p, int n, int *st, unsigned char **out)
{
    unsigned int w;
    int r;
    int *s;

    s = st;
    while (((w = ((unsigned int)p[0] << 8) + p[1]) >> 8) != 0xf0) {
        if (n == 0) {
            r = 0;
            *out = p + w;
            p = p + 2;
            goto done;
        }
        p += w;
        n--;
    }
    r = 2;
done:
    *s = r;
    return p;
}

void DSP_WriteParameter(unsigned int slot, unsigned int type, int v, struct pblk *p)
{
    if (slot == 1 && (type == 9 || type == 10)) {
        switch (type) {
        case 9:
            DSP_ParameterWriteEngine(slot, ToneGen_WorkArea, DSP_Eff9_Param_Descriptors, DSP_Eff9_Param_Values, v,
                                     (unsigned char *)((unsigned long)&p->e[slot] + 4));
            break;
        case 10:
            DSP_ParameterWriteEngine(slot, ToneGen_WorkArea, DSP_EffA_Param_Descriptors, DSP_EffA_Param_Values, v,
                                     (unsigned char *)((unsigned long)&p->e[slot] + 4));
            break;
        }
    } else {
        DSP_ParameterWriteEngine(slot, ToneGen_WorkArea, DSP_Param_Block_Ptrs_B[type], DSP_Param_Block_Ptrs_A[type],
                                 v, (unsigned char *)((unsigned long)&p->e[slot] + 4));
    }
}

int DSP_AlgoDescriptor_Emit(unsigned int a, unsigned int sub, int chip, unsigned char *tbl, unsigned int type,
                            unsigned int base, int unused)
{
    int st;
    unsigned int v;

    v = sub * 3 + (*DSP_TableWalk_Search(tbl, (unsigned char)0x78, type, &st) & 0xff);
    st = DSP_DispatchCommand(1, chip);
    st = DSP_DispatchData(0, chip);
    st = DSP_DispatchData((unsigned char)v++, chip);
    if (type != 0x63) {
        st = DSP_DispatchData(0, chip);
        st = DSP_DispatchData(0, chip);
        st = DSP_DispatchData((unsigned char)(((base + a) >> 4) & 0xf), chip);
        st = DSP_DispatchData((unsigned char)(((base + a) << 4) & 0xf0), chip);
        st = DSP_DispatchData(0, chip);
    } else {
        st = DSP_DispatchData(0, chip);
        st = DSP_DispatchData(0, chip);
        st = DSP_DispatchData(0x20, chip);
        st = DSP_DispatchData(0, chip);
        st = DSP_DispatchData(0, chip);
    }
    if (sub == 0) {
        st = DSP_DispatchData(8, chip);
        st = DSP_DispatchData(0, chip);
        st = DSP_DispatchData(0x80, chip);
        st = DSP_DispatchData(0xb4, chip);
        st = DSP_DispatchData(7, chip);
    } else {
        st = DSP_DispatchData((unsigned char)(((v >> 7) & 2) + 0xc), chip);
        st = DSP_DispatchData((unsigned char)((v >> 7) & 1), chip);
        st = DSP_DispatchData((unsigned char)(v * 2), chip);
        st = DSP_DispatchData(4, chip);
        st = DSP_DispatchData(7, chip);
    }
    return st;
}

int DSP_OscAlgoSelect(unsigned int a, unsigned int sub, int chip, unsigned char *tbl, unsigned int type,
                      unsigned int base, int unused)
{
    int st;
    unsigned int v;

    v = sub * 3 + (*DSP_TableWalk_Search(tbl, (unsigned char)0x78, type, &st) & 0xff);
    st = DSP_DispatchCommand(1, chip);
    st = DSP_DispatchData(0, chip);
    st = DSP_DispatchData((unsigned char)v++, chip);
    st = DSP_DispatchData(8, chip);
    st = DSP_DispatchData(1, chip);
    st = DSP_DispatchData((unsigned char)(((type + a) >> 4) & 0xf), chip);
    st = DSP_DispatchData((unsigned char)((((base + a) << 4) & 0xf0) + 8), chip);
    st = DSP_DispatchData(0x21, chip);
    if (sub == 0) {
        st = DSP_DispatchData(8, chip);
        st = DSP_DispatchData(0, chip);
        st = DSP_DispatchData(0x80, chip);
        st = DSP_DispatchData(0xb4, chip);
        st = DSP_DispatchData(8, chip);
    } else {
        st = DSP_DispatchData((unsigned char)(((v >> 7) & 2) + 0xc), chip);
        st = DSP_DispatchData((unsigned char)((v >> 7) & 1), chip);
        st = DSP_DispatchData((unsigned char)(v * 2), chip);
        st = DSP_DispatchData(4, chip);
        st = DSP_DispatchData(8, chip);
    }
    return st;
}

int DSP_TuneOffset(long P, int chip, unsigned char *tbl, unsigned int mode, int flag)
{
    int st;
    unsigned int v;

    v = *DSP_TableWalk_Search(tbl, (unsigned char)0x79, mode, &st);
    if (flag != 0) {
        switch (mode) {
        case 0:
            v--;
            break;
        case 1:
            v++;
            break;
        }
    }
    st = DSP_DispatchCommand(1, chip);
    st = DSP_DispatchData(1, chip);
    st = DSP_DispatchData(0x60, chip);
    st = DSP_DispatchData(0, chip);
    st = DSP_DispatchData(0, chip);
    st = DSP_DispatchData((unsigned char)(((v >> 4) & 0xf) + 0x10), chip);
    st = DSP_DispatchData((unsigned char)((v << 4) & 0xf0), chip);
    st = DSP_DispatchData(0, chip);
    st = DSP_DispatchData(0xa, chip);
    st = DSP_DispatchData((unsigned char)((P >> 17) & 0x7f), chip);
    st = DSP_DispatchData((unsigned char)((P >> 9) & 0xff), chip);
    st = DSP_DispatchData((unsigned char)((P >> 1) & 0xff), chip);
    st = DSP_DispatchData((unsigned char)(((P << 7) & 0x80) + 0x15), chip);
    st = DSP_DispatchCommand(3, chip);
    return st;
}

long DSP_PanScale_Simple(unsigned char **pp, long x)
{
    return x * 0xac44 / 0x3e8;
}

long DSP_ParamInterp_FPScale(unsigned char **pp, long b)
{
    long v;
    unsigned char *p;

    p = *pp;
    p = DSP_StreamDecode_3ByteWord(p, &v);
    v = (v >> 8) & 0xffffff;
    *pp = p;
    return b * 0xac44 / 0x3e8 + v;
}

long DSP_ParamInterp_Div0xB4(unsigned char **pp, long b)
{
    long v;
    unsigned char *p;

    p = *pp;
    p = DSP_StreamDecode_3ByteWord(p, &v);
    v = (v >> 8) & 0xffffff;
    *pp = p;
    return v * b / 0xb4;
}

long DSP_PitchParam_Scale(unsigned char **pp, long b)
{
    long v;
    unsigned char *p;

    p = *pp;
    p = DSP_StreamDecode_3ByteWord(p, &v);
    v = (v >> 8) & 0xffffff;
    *pp = p;
    return ((b << 21) / v << 2) - 0x800000;
}

long DSP_ParamInterp_2Point(unsigned char **pp, long b)
{
    long v0;
    long v1;
    unsigned char *p;

    p = *pp;
    p = DSP_StreamDecode_3ByteWord(p, &v0);
    p = DSP_StreamDecode_3ByteWord(p, &v1);
    *pp = p;
    return (v0 >> 8) + ((v1 - v0) >> 8) * b / 0x63;
}

long DSP_FreqInterp_2Point(unsigned char **pp, long b)
{
    long v0;
    long v1;
    unsigned char *p;

    p = *pp;
    p = DSP_StreamDecode_3ByteWord(p, &v0);
    p = DSP_StreamDecode_3ByteWord(p, &v1);
    *pp = p;
    return (v0 >> 8) + ((v1 - v0) >> 8) * b / 0x63;
}

long DSP_ParamInterp_2Point_B(unsigned char **pp, long b)
{
    long v0;
    long v1;
    unsigned char *p;

    p = *pp;
    p = DSP_StreamDecode_3ByteWord(p, &v0);
    p = DSP_StreamDecode_3ByteWord(p, &v1);
    *pp = p;
    return (v0 >> 8) + ((v1 - v0) >> 8) * b / 0x63;
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
    t = b;
    t += 0x63;
    q = ((v1 - v0) >> 8) / 0xc6;
    *pp = p;
    return (v0 >> 8) + q * t;
}

long DSP_ParamInterp_3Point_WithOffset(unsigned char **pp, long b, long c)
{
    long v0;
    long v1;
    unsigned char *p;

    p = *pp;
    p = DSP_StreamDecode_3ByteWord(p, &v0);
    p = DSP_StreamDecode_3ByteWord(p, &v1);
    v0 = (v0 >> 8) & 0xffffff;
    v1 = (v1 >> 8) & 0xffffff;
    *pp = p;
    return (c + v0 + (v1 - v0) * b / 0x63) << 8;
}

long DSP_FreqCurve_FP(unsigned char **pp, long x)
{
    long t;
    long r;

    if (x <= 0x14) {
        r = (x << 23) / (0xfa0 - x * 2);
    } else if (x <= 0x32) {
        r = ((x - 0xa) << 23) / (0x7ba - (x * 2 - 0x2a));
    } else {
        t = 0x1dea - (x * 0x16 - 0x462);
        r = ((x * 0xb - 0x186) << 15) / t << 8;
    }
    return r;
}

long DSP_PanCurve_PiecewiseLin(unsigned char **pp, long x)
{
    if (x <= 0x14)
        return (x * 2 * 0xac44 + 0x6baa8) / 0x3e8;
    else if (x <= 0x1e)
        return (x * 5 * 0xac44 - 0x21a548) / 0x3e8;
    else if (x <= 0x46)
        return (x * 10 * 0xac44 - 0x869520) / 0x3e8;
    else if (x <= 0x50)
        return (x * 0x32 * 0xac44 - 0x7e2bce0) / 0x3e8;
    else
        return (x * 0x64 * 0xac44 - 0x12666360) / 0x3e8;
}

long DSP_ParamInterp_MultiStep(unsigned char **pp, long b, int *tbl, int unused, unsigned int n)
{
    long junk;
    long v0;
    long v1;
    unsigned char *p;
    int k;

    p = *pp;
    switch (*p++ & 0xf0) {
    default:
        k = (int)b;
        break;
    case 0x10:
        k = tbl[n - 1];
        break;
    case 0x20:
        k = tbl[n - 2];
        break;
    }
    switch (k) {
    default:
        p = DSP_StreamDecode_3ByteWord(p, &v0);
        p = DSP_StreamDecode_3ByteWord(p, &v1);
        p = DSP_StreamDecode_3ByteWord(p, &junk);
        p = DSP_StreamDecode_3ByteWord(p, &junk);
        p = DSP_StreamDecode_3ByteWord(p, &junk);
        p = DSP_StreamDecode_3ByteWord(p, &junk);
        break;
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
    }
    *pp = p;
    return (v0 >> 8) + ((v1 - v0) >> 8) * b / 0x63;
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
        len = ((int)(*code & 0xf) << 8) + (code[1] & 0xff) - 2;
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
