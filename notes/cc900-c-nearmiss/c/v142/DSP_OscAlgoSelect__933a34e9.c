/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the whole file of sub/sub_E_3b.c (2026-11-16-58-sub-r3)
   sha256 933a34e91b0361e4e33794d2b5f1b5268cc2fd5dd516e86c00b85fbd3333c303 (name+funcs); compiled at -Xr */
/* lane_sub helper E, round 3, form b: other spellings of sub_E_3a.c's functions (sub-CPU payload v1.42):
   `register` on the parameter the ROM leaves in place instead of a local copy of the one it moves, a local copy of
   the chip number instead of `register`, a void * cell instead of a cast, v << 1, the locals in the other order. */

struct bcfg { int a; int b; int c; int d; long e; };
struct dspstate { int w[0x90]; int busy; };
struct pent { char pad[4]; unsigned char f[52]; };
struct pblk { char pad[8]; struct pent e[2]; };

extern void *__near ram_4a3e;
extern struct dspstate ram_45324;
extern struct bcfg ToneGen_WorkArea[];
extern struct bcfg DSP_Bytecode_Global_Config[];
extern unsigned char DSP_Eff9_Param_Descriptors[];
extern unsigned char DSP_Eff9_Param_Values[];
extern unsigned char DSP_EffA_Param_Descriptors[];
extern unsigned char DSP_EffA_Param_Values[];
extern unsigned char *DSP_Param_Block_Ptrs_A[];
extern unsigned char *DSP_Param_Block_Ptrs_B[];

extern int DSP_DispatchData(int d, int chip);
extern int DSP_DispatchCommand(int d, int chip);
extern int DSP_BytecodeInterpreter_Init(int chip, unsigned int idx, struct bcfg *cfg, unsigned char *code);
extern void DSP_ParameterWriteEngine(unsigned int slot, struct bcfg *work, void *desc, unsigned char *rec,
                                     int v, void *vals);
extern void DSP_State_ApplyAll(struct dspstate *s);
extern unsigned char *DSP_TableWalk_Search(unsigned char *p, unsigned int key, unsigned int len, int *out);

char *DSP_StreamDecode_3ByteWord(char *p, long *out)
{
    char *q;
    long c;
    long b;
    long a;

    q = p;
    a = ((long)*q++ << 24) & 0xff000000;
    b = ((long)*q++ << 16) & 0xff0000;
    c = ((long)*q++ << 8) & 0xff00;
    *out = a + b + c;
    return q;
}

unsigned char *DSP_TableWalk_Search(unsigned char *p, unsigned int key, register unsigned int len, int *out)
{
    unsigned char *next;
    unsigned int w;
    int r;

    while (((w = ((unsigned int)p[0] << 8) + p[1]) >> 8) != 0xf0) {
        next = p + w;
        p += 2;
        if (*p == key) {
            p += len + 1L;
            if (p >= next) r = 4;
            else r = 0;
            goto done;
        }
        p = next;
    }
    r = 3;
done:
    *out = r;
    return p;
}

unsigned char *DSP_TableWalk_SearchWithState(unsigned char *p, register int n, int *st, unsigned char **out)
{
    unsigned int w;
    int r;

    while (((w = ((unsigned int)p[0] << 8) + p[1]) >> 8) != 0xf0) {
        if (n == 0) {
            r = 0;
            *out = p + w;
            p += 2;
            goto done;
        }
        p += w;
        n--;
    }
    r = 2;
done:
    *st = r;
    return p;
}

void DSP_State_LoadAndApplyAll(struct dspstate *src)
{
    *(struct dspstate *)(ram_4a3e = &ram_45324) = *src;
    ((struct dspstate *)ram_4a3e)->busy = 1;
    DSP_State_ApplyAll(ram_4a3e);
    ((struct dspstate *)ram_4a3e)->busy = 0;
}

void DSP_WriteGlobalConfig(int chip, unsigned char *code)
{
    int i = 0;

    DSP_BytecodeInterpreter_Init(chip, i, DSP_Bytecode_Global_Config, code);
}

void DSP_WriteOscParam_Offset(unsigned int a, long v, int chip, long off, unsigned int base)
{
    int c;

    c = chip;
    DSP_DispatchData(8, c);
    DSP_DispatchData(1, c);
    DSP_DispatchData((unsigned char)(((base + a) >> 4) & 0xf), c);
    DSP_DispatchData((unsigned char)((((base + a) << 4) & 0xf0) + 8), c);
    DSP_DispatchData(0x25, c);
    v += off;
    DSP_DispatchData(0xa, c);
    DSP_DispatchData((unsigned char)((v >> 17) & 0x7f), c);
    DSP_DispatchData((unsigned char)((v >> 9) & 0xff), c);
    DSP_DispatchData((unsigned char)((v >> 1) & 0xff), c);
    DSP_DispatchData((unsigned char)(((v << 7) & 0x80) + 0x4c), c);
}

void DSP_WriteParameter(unsigned int slot, unsigned int type, int v, register struct pblk *p)
{
    if (slot == 1 && (type == 9 || type == 10)) {
        switch (type) {
        case 9:
            DSP_ParameterWriteEngine(slot, ToneGen_WorkArea, DSP_Eff9_Param_Descriptors, p->e[slot].f, v,
                                     DSP_Eff9_Param_Values);
            break;
        case 10:
            DSP_ParameterWriteEngine(slot, ToneGen_WorkArea, DSP_EffA_Param_Descriptors, p->e[slot].f, v,
                                     DSP_EffA_Param_Values);
            break;
        }
    } else {
        DSP_ParameterWriteEngine(slot, ToneGen_WorkArea, DSP_Param_Block_Ptrs_B[type], p->e[slot].f, v,
                                 DSP_Param_Block_Ptrs_A[type]);
    }
}

int DSP_AlgoDescriptor_Emit(unsigned int a, unsigned int sub, int chip, int unused, unsigned int base,
                            unsigned int type, unsigned char *tbl)
{
    int st;
    unsigned int v;

    v = (*DSP_TableWalk_Search(tbl, 0x78, type, &st) & 0xff) + sub * 3;
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
        st = DSP_DispatchData((unsigned char)(v << 1), chip);
        st = DSP_DispatchData(4, chip);
        st = DSP_DispatchData(7, chip);
    }
    return st;
}

int DSP_OscAlgoSelect(unsigned int a, unsigned int sub, int chip, int unused, unsigned int base,
                      unsigned int type, unsigned char *tbl)
{
    int st;
    unsigned int v;

    v = (*DSP_TableWalk_Search(tbl, 0x78, type, &st) & 0xff) + sub * 3;
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
        st = DSP_DispatchData((unsigned char)(v << 1), chip);
        st = DSP_DispatchData(4, chip);
        st = DSP_DispatchData(8, chip);
    }
    return st;
}

int DSP_TuneOffset(long P, int chip, unsigned char *tbl, int flag, unsigned int mode)
{
    int st;
    unsigned int v;

    v = *DSP_TableWalk_Search(tbl, 0x79, mode, &st);
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
