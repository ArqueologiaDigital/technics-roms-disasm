/* lane_sub helper E, round 3, form a: KN5000 sub-CPU payload v1.42 (v142/subcpu), core/14_dsp_control_routines.s and
   core/02_audio_system_init.s.  Round 2's near misses again (register choice: `register` on the parameter the ROM
   keeps in IZ, local copies of the parameter the ROM moves out of XWA / XDE, void * conversions that make the
   ROM evaluate an argument first), and the unreferenced DSP_AlgoDescriptor_Emit / DSP_OscAlgoSelect /
   DSP_TuneOffset, Audio_CmdHandler_A0_BF and ToneGen_Init.  ram_<hex> is a RAM cell the tree has not named. */

struct bcfg { int a; int b; int c; int d; long e; };
struct dspstate { int w[0x90]; int busy; };
struct pent { char pad[4]; unsigned char f[52]; };
struct pblk { char pad[8]; struct pent e[2]; };

extern unsigned char __near ram_4a48;
extern unsigned char __near ram_4a4a;
extern struct dspstate *__near ram_4a3e;
extern int ram_45324[];
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
extern void ToneGen_Poll_Init(void);
extern unsigned char *DSP_TableWalk_Search(unsigned char *p, unsigned int key, unsigned int len, int *out);

char *DSP_StreamDecode_3ByteWord(char *p, long *out)
{
    char *q;
    long a;
    long b;
    long c;

    q = p;
    a = ((long)*q++ << 24) & 0xff000000;
    b = ((long)*q++ << 16) & 0xff0000;
    c = ((long)*q++ << 8) & 0xff00;
    *out = a + b + c;
    return q;
}

unsigned char *DSP_TableWalk_Search(unsigned char *p, unsigned int key, unsigned int len, int *out)
{
    unsigned char *q;
    unsigned char *next;
    unsigned int w;
    int r;

    q = p;
    while (((w = ((unsigned int)q[0] << 8) + q[1]) >> 8) != 0xf0) {
        next = q + w;
        q += 2;
        if (*q == key) {
            q += len + 1L;
            if (q >= next) r = 4;
            else r = 0;
            goto done;
        }
        q = next;
    }
    r = 3;
done:
    *out = r;
    return q;
}

unsigned char *DSP_TableWalk_SearchWithState(unsigned char *p, int n, int *st, unsigned char **out)
{
    int *s;
    unsigned int w;
    int r;

    s = st;
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
    *s = r;
    return p;
}

void DSP_State_LoadAndApplyAll(struct dspstate *src)
{
    *(ram_4a3e = (struct dspstate *)ram_45324) = *src;
    ram_4a3e->busy = 1;
    DSP_State_ApplyAll(ram_4a3e);
    ram_4a3e->busy = 0;
}

void DSP_WriteGlobalConfig(int chip, unsigned char *code)
{
    unsigned int i;

    i = 0;
    DSP_BytecodeInterpreter_Init(chip, i, DSP_Bytecode_Global_Config, code);
}

void DSP_WriteOscParam_Offset(unsigned int a, long v, register int chip, long off, unsigned int base)
{
    DSP_DispatchData(8, chip);
    DSP_DispatchData(1, chip);
    DSP_DispatchData((unsigned char)(((base + a) >> 4) & 0xf), chip);
    DSP_DispatchData((unsigned char)((((base + a) << 4) & 0xf0) + 8), chip);
    DSP_DispatchData(0x25, chip);
    v += off;
    DSP_DispatchData(0xa, chip);
    DSP_DispatchData((unsigned char)((v >> 17) & 0x7f), chip);
    DSP_DispatchData((unsigned char)((v >> 9) & 0xff), chip);
    DSP_DispatchData((unsigned char)((v >> 1) & 0xff), chip);
    DSP_DispatchData((unsigned char)(((v << 7) & 0x80) + 0x4c), chip);
}

void DSP_WriteParameter(unsigned int slot, unsigned int type, int v, struct pblk *p)
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

int DSP_AlgoDescriptor_Emit(unsigned int a, unsigned int sub, register int chip, int unused, unsigned int base,
                            unsigned int type, unsigned char *tbl)
{
    unsigned int v;
    int st;

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
        st = DSP_DispatchData((unsigned char)(v * 2), chip);
        st = DSP_DispatchData(4, chip);
        st = DSP_DispatchData(7, chip);
    }
    return st;
}

int DSP_OscAlgoSelect(unsigned int a, unsigned int sub, register int chip, int unused, unsigned int base,
                      unsigned int type, unsigned char *tbl)
{
    unsigned int v;
    int st;

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
        st = DSP_DispatchData((unsigned char)(v * 2), chip);
        st = DSP_DispatchData(4, chip);
        st = DSP_DispatchData(8, chip);
    }
    return st;
}

int DSP_TuneOffset(long P, register int chip, unsigned char *tbl, int flag, unsigned int mode)
{
    unsigned char *d;
    unsigned int v;
    int st;

    d = DSP_TableWalk_Search(tbl, 0x79, mode, &st);
    v = *d;
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

void ToneGen_Init(void)
{
    ram_4a48 = 6;
    ToneGen_Poll_Init();
}

int __cdecl Audio_CmdHandler_A0_BF(unsigned char cmd, unsigned char *p)
{
    switch (p[0]) {
    case 0:
        if (p[1] == 1) ram_4a4a = 1;
        break;
    case 1:
        if (p[1] <= 9) ram_4a48 = p[1];
        break;
    }
    return 0;
}
