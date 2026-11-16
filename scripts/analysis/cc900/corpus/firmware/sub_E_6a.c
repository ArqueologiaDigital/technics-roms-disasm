/* lane_sub helper E, round 6, form a: KN5000 sub-CPU payload v1.42 (v142/subcpu), core/14_dsp_control_routines.s.
   Same-module callers (pool_E_rel), DSP_VolumeParam_Scale / DSP_VolScale_B (identical bytes), ToneGen_Init, and
   round 5's near misses.  Stack parameters: the first one is at the highest address.  DSP_Nop / DSP_NopReturn are
   called WITH an argument in the ROM (`ld wa,..` before the calr), so they are declared here without a prototype. */

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
extern void ToneGen_Poll_Init(void);
extern void Keybed_Decode_Event(unsigned char *ev, unsigned char d);
extern void InterCPU_DMA_Send(int a, int b, unsigned char *p);
extern unsigned char *DSP_StreamDecode_3ByteWord(unsigned char *p, void *out);
extern unsigned char *DSP_TableWalk_SearchWithState(unsigned char *p, int n, int *st, unsigned char **out);
extern unsigned char *DSP_PerParameterTranslator(int chip, unsigned int slot, int v, unsigned char *p, void *desc,
                                                 unsigned char *rec, struct bcfg *work, int *status);

void DSP_Select_Chip(int chip)
{
    DSP_Nop(chip);
    switch (chip) {
    case 0:
        ram_1c &= ~0x20;
        break;
    case 1:
        ram_38 &= ~0x40;
        break;
    }
}

void DSP_Deselect_Chip(int chip)
{
    DSP_Nop(chip);
    switch (chip) {
    case 0:
        ram_1c |= 0x20;
        break;
    case 1:
        ram_38 |= 0x40;
        break;
    }
}

void DSP_WriteParamCmd30(int chip, unsigned int b, long v)
{
    DSP_DispatchCommand(0x30, chip);
    DSP_DispatchData(0, chip);
    DSP_DispatchData((unsigned char)b, chip);
    DSP_WriteParamWord(v, chip);
}

void DSP_WriteOscParam(unsigned int a, long v, int chip, unsigned int base)
{
    if (chip != 1) {
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
    } else {
        DSP_WriteParamCmd30(chip, a, v);
    }
}

void DSP_WriteFreqParam(unsigned int a, long v, int chip, unsigned int base)
{
    if (chip != 1) {
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
    } else {
        DSP_WriteParamCmd30(chip, a, v);
    }
}

void DSP_WriteFreqParam_AlgoType(unsigned int a, long v, int chip, unsigned int base)
{
    if (chip != 1) {
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
    } else {
        DSP_WriteParamCmd30(chip, a, v);
    }
}

void ToneGen_Init(void)
{
    ram_4a48 = 6;
    ToneGen_Poll_Init();
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
    if (hi == 0xff || (st & 2)) {
        if (lo & 0x80)
            return 0xffff;
        Keybed_Decode_Event(ev, lo);
        ev[1] = 0;
        return 0;
    } else {
        Keybed_Decode_Event(ev, lo);
        return 0;
    }
}

void ToneGen_Process_Notes(void)
{
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

void DSP_ParameterWriteEngine(unsigned int slot, struct bcfg *work, void *desc, unsigned char *vals, int v,
                              unsigned char *rec)
{
    int status;
    unsigned char *end;
    int chip;

    chip = EFF_SlotToChip_Table[slot];
    status = 0;
    vals = DSP_TableWalk_SearchWithState(vals, v, &status, &end);
    if (status != 0) {
        DSP_NopReturn(status);
        return;
    }
    while (vals < end) {
        if (chip == 0) {
            status = DSP_DispatchCommand(1, chip);
            status = DSP_DispatchData(1, chip);
            status = DSP_DispatchData(0x60, chip);
        }
        vals = DSP_PerParameterTranslator(chip, slot, v, vals, desc, rec, work, &status);
        if (status != 0) {
            DSP_NopReturn(status);
            return;
        }
        if (chip == 0)
            status = DSP_DispatchCommand(3, chip);
    }
}

long DSP_VolumeParam_Scale(unsigned char **pp, long x)
{
    unsigned char *p;
    long r;

    p = *pp;
    switch (*p++) {
    case 0:
        if (x <= 0x32)
            r = (x << 23) / 0x6baa8;
        else if (x <= 0x4b)
            r = ((x - 0x19) << 23) / 0x35d54;
        else if (x <= 0x58)
            r = ((x * 4 - 0xfa) << 23) / 0x35d54;
        else
            r = ((x * 9 - 0x2b2) << 23) / 0x35d54;
        break;
    case 1:
        if (x <= 0xa)
            r = (x << 23) / 0xac44;
        else if (x <= 0x13)
            r = ((x * 10 - 0x5a) << 23) / 0xac44;
        else if (x <= 0x40)
            r = ((x * 20 - 0x118) << 15) / 0xac44 << 8;
        else if (x <= 0x57)
            r = ((x * 0x190 - 0x60e0) << 15) / 0xac44 << 8;
        else
            r = ((x * 0x320 - 0xe8d0) << 15) / 0xac44 << 8;
        break;
    case 2:
        if (x <= 0x32)
            r = (x << 23) / (0xfa0 - x * 2);
        else if (x <= 0x4b)
            r = ((x - 0x19) << 23) / (0x79c - (x * 2 - 0x66));
        else if (x <= 0x58)
            r = ((x * 4 - 0xfa) << 23) / (0x764 - (x * 8 - 0x260));
        else
            r = ((x * 9 - 0x2b2) << 23) / (0x6f2 - (x * 18 - 0x642));
        break;
    }
    *pp = p;
    return r;
}

long DSP_VolScale_B(unsigned char **pp, long x)
{
    unsigned char *p;
    long r;

    p = *pp;
    switch (*p++) {
    case 0:
        if (x <= 0x32)
            r = (x << 23) / 0x6baa8;
        else if (x <= 0x4b)
            r = ((x - 0x19) << 23) / 0x35d54;
        else if (x <= 0x58)
            r = ((x * 4 - 0xfa) << 23) / 0x35d54;
        else
            r = ((x * 9 - 0x2b2) << 23) / 0x35d54;
        break;
    case 1:
        if (x <= 0xa)
            r = (x << 23) / 0xac44;
        else if (x <= 0x13)
            r = ((x * 10 - 0x5a) << 23) / 0xac44;
        else if (x <= 0x40)
            r = ((x * 20 - 0x118) << 15) / 0xac44 << 8;
        else if (x <= 0x57)
            r = ((x * 0x190 - 0x60e0) << 15) / 0xac44 << 8;
        else
            r = ((x * 0x320 - 0xe8d0) << 15) / 0xac44 << 8;
        break;
    case 2:
        if (x <= 0x32)
            r = (x << 23) / (0xfa0 - x * 2);
        else if (x <= 0x4b)
            r = ((x - 0x19) << 23) / (0x79c - (x * 2 - 0x66));
        else if (x <= 0x58)
            r = ((x * 4 - 0xfa) << 23) / (0x764 - (x * 8 - 0x260));
        else
            r = ((x * 9 - 0x2b2) << 23) / (0x6f2 - (x * 18 - 0x642));
        break;
    }
    *pp = p;
    return r;
}

long DSP_PanCurve_PiecewiseLin(unsigned char **pp, long x)
{
    if (x <= 0x14)
        return ((x * 2 + 10) * 0xac44) / 0x3e8;
    else if (x <= 0x1e)
        return ((x * 5 - 50) * 0xac44) / 0x3e8;
    else if (x <= 0x46)
        return ((x * 10 - 200) * 0xac44) / 0x3e8;
    else if (x <= 0x50)
        return ((x * 50 - 3000) * 0xac44) / 0x3e8;
    else
        return ((x * 100 - 7000) * 0xac44) / 0x3e8;
}

long DSP_ParamInterp_Div0xC6(unsigned char **pp, long b)
{
    long v0;
    long v1;
    unsigned char *p;
    long t;
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
    r = (v0 >> 8) + ((v1 - v0) >> 8) * b / 0x63;
    *pp = p;
    return r;
}
