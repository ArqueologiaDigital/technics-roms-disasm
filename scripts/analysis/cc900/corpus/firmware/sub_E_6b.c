/* lane_sub helper E, round 6, form b: other spellings of sub_E_6a.c's functions (sub-CPU payload v1.42):
   if / else in the other order, a zeroed local in ToneGen_Process_Notes, void * value tables in
   DSP_ParameterWriteEngine (with DSP_WriteParameter, which passes them), a temporary in the pan curve, the
   Div0xC6 locals in the other order. */

/* cc900-module: DSP_Nop DSP_NopReturn DSP_WriteParamWord DSP_WriteParamCmd30 ToneGen_Poll_Init Keybed_Decode_Event Keybed_Read_Event DSP_TableWalk_SearchWithState DSP_PerParameterTranslator */

struct bcfg { int a; int b; int c; int d; long e; };
struct pent { char pad[4]; unsigned char f[52]; };
struct pblk { char pad[8]; struct pent e[2000]; };

extern unsigned char __tiny ram_18;                           /* P6 */
extern unsigned char __tiny ram_1c;                           /* P7 */
extern unsigned char __tiny ram_38;                           /* PE */
extern unsigned int ram_110000;
extern unsigned int ram_110002;
extern unsigned char __near ram_4a42;
extern unsigned char __near ram_4a43;
extern unsigned char __near ram_4a44;
extern unsigned char __near ram_4a48;
extern unsigned char __near ram_4a4a;
extern unsigned char __near ram_4a4c[];
extern unsigned char EFF_SlotToChip_Table[];
extern struct bcfg ToneGen_WorkArea[];
extern unsigned char DSP_Eff9_Param_Descriptors[];
extern unsigned char DSP_Eff9_Param_Values[];
extern unsigned char DSP_EffA_Param_Descriptors[];
extern unsigned char DSP_EffA_Param_Values[];
extern unsigned char *DSP_Param_Block_Ptrs_A[];
extern unsigned char *DSP_Param_Block_Ptrs_B[];

extern int DSP_DispatchData(int d, int chip);
extern int DSP_DispatchCommand(int d, int chip);
extern void DSP_Nop();
extern void DSP_NopReturn();
extern void DSP_WriteParamWord(long v, int chip);
extern void DSP_WriteParamCmd30(int chip, unsigned int b, long v);
extern void ToneGen_Poll_Init(void);
extern void Keybed_Decode_Event(unsigned char *ev, unsigned char d);
extern void InterCPU_DMA_Send(int a, int b, unsigned char *p);
extern unsigned char *DSP_StreamDecode_3ByteWord(unsigned char *p, void *out);
extern unsigned char *DSP_TableWalk_SearchWithState(unsigned char *p, int n, int *st, unsigned char **out);
extern void DSP_ParameterWriteEngine(unsigned int slot, struct bcfg *work, void *desc, void *vals, int v,
                                     unsigned char *rec);
extern unsigned char *DSP_PerParameterTranslator(int chip, unsigned int slot, int v, unsigned char *p, void *desc,
                                                 unsigned char *rec, struct bcfg *work, int *status);

void DSP_WriteOscParam(unsigned int a, long v, int chip, unsigned int base)
{
    if (chip == 1) {
        DSP_WriteParamCmd30(chip, a, v);
    } else {
        DSP_DispatchData(8, chip);
        DSP_DispatchData(1, chip);
        DSP_DispatchData((unsigned char)(((base + a) >> 4) & 0xf), chip);
        DSP_DispatchData((unsigned char)((((base + a) << 4) & 0xf0) + 8), chip);
        DSP_DispatchData(0x21, chip);
        DSP_DispatchData(0xa, chip);
        DSP_DispatchData((unsigned char)((v >> 17) & 0x7f), chip);
        DSP_DispatchData((unsigned char)((v >> 9) & 0xff), chip);
        DSP_DispatchData((unsigned char)((v >> 1) & 0xff), chip);
        DSP_DispatchData((unsigned char)(((v << 7) & 0x80) + 0x26), chip);
    }
}

void DSP_WriteFreqParam(unsigned int a, long v, int chip, unsigned int base)
{
    if (chip == 1) {
        DSP_WriteParamCmd30(chip, a, v);
    } else {
        DSP_DispatchData(0, chip);
        DSP_DispatchData(0, chip);
        DSP_DispatchData((unsigned char)((((base + a) >> 4) & 0xf) + 0x10), chip);
        DSP_DispatchData((unsigned char)(((base + a) << 4) & 0xf0), chip);
        DSP_DispatchData(0, chip);
        DSP_DispatchData(0xa, chip);
        DSP_DispatchData((unsigned char)((v >> 17) & 0x7f), chip);
        DSP_DispatchData((unsigned char)((v >> 9) & 0xff), chip);
        DSP_DispatchData((unsigned char)((v >> 1) & 0xff), chip);
        DSP_DispatchData((unsigned char)(((v << 7) & 0x80) + 0x15), chip);
    }
}

void DSP_WriteFreqParam_AlgoType(unsigned int a, long v, int chip, unsigned int base)
{
    if (chip == 1) {
        DSP_WriteParamCmd30(chip, a, v);
    } else {
        DSP_DispatchData(0, chip);
        DSP_DispatchData(0, chip);
        DSP_DispatchData((unsigned char)((((base + a) >> 4) & 0xf) + 0x10), chip);
        DSP_DispatchData((unsigned char)(((base + a) << 4) & 0xf0), chip);
        DSP_DispatchData(0, chip);
        DSP_DispatchData(0xa, chip);
        DSP_DispatchData((unsigned char)((v >> 17) & 0x7f), chip);
        DSP_DispatchData((unsigned char)((v >> 9) & 0xff), chip);
        DSP_DispatchData((unsigned char)((v >> 1) & 0xff), chip);
        DSP_DispatchData((unsigned char)(((v << 7) & 0x80) + 0x15), chip);
    }
}

unsigned int Keybed_Read_Event(unsigned char *ev)
{
    unsigned int st;
    unsigned int d;
    unsigned char lo;
    unsigned char hi;

    ram_18 |= 0x80;
    __ASM(" nop");
    st = ram_110002;
    if (!(st & 1))
        return 0xffff;
    ram_18 &= ~0x80;
    __ASM(" nop");
    d = ram_110000;
    lo = d & 0xff;
    hi = (d >> 8) & 0xff;
    if (hi != 0xff && !(st & 2)) {
        Keybed_Decode_Event(ev, lo);
        return 0;
    } else {
        if (lo & 0x80)
            return 0xffff;
        Keybed_Decode_Event(ev, lo);
        ev[1] = 0;
        return 0;
    }
}

void ToneGen_Process_Notes(void)
{
    unsigned int i = 0;
    unsigned char ev[2];

    while (Keybed_Read_Event(ev) != 0xffff) {
        if (ev[1] != 0) {
            ram_4a4c[ev[0]] = 0xff;
            ram_4a42 = 0x90;
            ram_4a43 = ev[0];
            ram_4a44 = ev[1];
            if (ram_4a4a == 1)
                InterCPU_DMA_Send(2, 3, (unsigned char *)0x4a42);
        } else if (ram_4a4c[ev[0]] == 0xff) {
            ram_4a4c[ev[0]] = 0;
            ram_4a42 = 0x90;
            ram_4a43 = ev[0];
            ram_4a44 = ev[1];
            if (ram_4a4a == 1)
                InterCPU_DMA_Send(2, 3, (unsigned char *)0x4a42);
        }
    }
}

void DSP_ParameterWriteEngine(unsigned int slot, struct bcfg *work, void *desc, void *vals, int v,
                              unsigned char *rec)
{
    int status;
    unsigned char *end;
    int chip;
    unsigned char *p;

    chip = EFF_SlotToChip_Table[slot];
    status = 0;
    p = DSP_TableWalk_SearchWithState(vals, v, &status, &end);
    if (status != 0) {
        DSP_NopReturn(status);
        return;
    }
    while (p < end) {
        if (chip == 0) {
            status = DSP_DispatchCommand(1, chip);
            status = DSP_DispatchData(1, chip);
            status = DSP_DispatchData(0x60, chip);
        }
        p = DSP_PerParameterTranslator(chip, slot, v, p, desc, rec, work, &status);
        if (status != 0) {
            DSP_NopReturn(status);
            return;
        }
        if (chip == 0)
            status = DSP_DispatchCommand(3, chip);
    }
}

void DSP_WriteParameter(unsigned int slot, unsigned int type, int v, struct pblk *p)
{
    if (slot == 1 && (type == 9 || type == 10)) {
        switch (type) {
        case 9:
            DSP_ParameterWriteEngine(slot, ToneGen_WorkArea, DSP_Eff9_Param_Descriptors, DSP_Eff9_Param_Values, v,
                                     p->e[(unsigned long)slot].f);
            break;
        case 10:
            DSP_ParameterWriteEngine(slot, ToneGen_WorkArea, DSP_EffA_Param_Descriptors, DSP_EffA_Param_Values, v,
                                     p->e[(unsigned long)slot].f);
            break;
        }
    } else {
        DSP_ParameterWriteEngine(slot, ToneGen_WorkArea, DSP_Param_Block_Ptrs_B[type], DSP_Param_Block_Ptrs_A[type],
                                 v, p->e[(unsigned long)slot].f);
    }
}

long DSP_PanCurve_PiecewiseLin(unsigned char **pp, long x)
{
    long t;

    if (x <= 0x14) {
        t = x * 2;
        return (t * 0xac44 + 0x6baa8) / 0x3e8;
    } else if (x <= 0x1e) {
        t = x * 5;
        return (t * 0xac44 - 0x21a548) / 0x3e8;
    } else if (x <= 0x46) {
        t = x * 10;
        return (t * 0xac44 - 0x869520) / 0x3e8;
    } else if (x <= 0x50) {
        t = x * 0x32;
        return (t * 0xac44 - 0x7e2bce0) / 0x3e8;
    } else {
        t = x * 0x64;
        return (t * 0xac44 - 0x12666360) / 0x3e8;
    }
}

long DSP_ParamInterp_Div0xC6(unsigned char **pp, long b)
{
    long v0;
    long v1;
    long t;
    unsigned char *p;
    long q;
    long r;

    p = *pp;
    p = DSP_StreamDecode_3ByteWord(p, &v0);
    p = DSP_StreamDecode_3ByteWord(p, &v1);
    t = b;
    t += 0x63;
    q = ((v1 - v0) >> 8) / 0xc6;
    r = (v0 >> 8) + q * t;
    *pp = p;
    return r;
}
