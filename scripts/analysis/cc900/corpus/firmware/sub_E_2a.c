/* lane_sub helper E, round 2, form a: functions of the KN5000 sub-CPU payload v1.42 (v142/subcpu),
   core/14_dsp_control_routines.s and core/02_audio_system_init.s.  Names are the tree's labels;
   ram_<hex> is a RAM cell (sub-CPU address) the tree has not named. */

struct bcfg { int a; int b; int c; int d; long e; };         /* 12-byte rows read by DSP_BytecodeInterpreter_Init */
struct dspstate { int w[0x90]; int busy; };                  /* 0x91 words; busy at +288 */
struct pent { char pad[4]; unsigned char f[52]; };            /* 56-byte rows */
struct pblk { char pad[8]; struct pent e[2]; };

extern unsigned char __tiny ram_1c;                           /* P7 */
extern unsigned char __tiny ram_44;                           /* PH */

extern struct bcfg ToneGen_WorkArea[];
extern struct bcfg DSP_Bytecode_Global_Config[];
extern unsigned char EFF_SlotToChip_Table[];
extern unsigned char DSP_Eff9_Param_Descriptors[];
extern unsigned char DSP_Eff9_Param_Values[];
extern unsigned char DSP_EffA_Param_Descriptors[];
extern unsigned char DSP_EffA_Param_Values[];
extern unsigned char *DSP_Param_Block_Ptrs_A[];
extern unsigned char *DSP_Param_Block_Ptrs_B[];
extern long DSP_CoeffCurve_Op62[];
extern long DSP_FreqParamCurve_Algo0[];
extern long DSP_FreqParamCurve_Algo1[];
extern long DSP_FreqParamCurve_Algo2[];
extern struct dspstate ram_45324;
extern struct dspstate ram_45446;

extern int DSP_DispatchData(int d, int chip);
extern int DSP_BytecodeInterpreter_Init(int chip, unsigned int idx, struct bcfg *cfg, unsigned char *code);
extern void DSP_ParameterWriteEngine(unsigned int slot, struct bcfg *work, unsigned char *desc, unsigned char *rec,
                                     int v, unsigned char *vals);
extern void DSP_State_ApplyAll(struct dspstate *s);
extern void Kernel_StartTask(int n);
extern void Kernel_SemaSignal(int n);
extern void MsgQueue_Send(int q, struct dspstate *m);
extern struct dspstate *MsgQueue_ReceiveBlocking(int q);
extern void RingBuf_Init_1K(void);
extern void RingBuf_Init_256(void);
extern void RingBuf_Init_512(void);

void DSP_Nop(void) { }
void DSP_NopReturn(void) { }
void Task2_NeverSpawned(void) { }

void DSP1_Assert_Reset(void) { ram_44 &= ~2; }
void DSP1_Deassert_Reset(void) { ram_44 |= 2; }
void DSP2_Assert_Reset(void) { ram_44 &= ~4; }
void DSP2_Deassert_Reset(void) { ram_44 |= 4; }
void DSP_Set_Command_Mode(void) { ram_1c &= ~0x40; }
void DSP_Set_Data_Mode(void) { ram_1c |= 0x40; }
void DSP_Assert_Write(void) { ram_1c &= ~8; }
void DSP_Deassert_Write(void) { ram_1c |= 8; }
void DSP_Assert_Read(void) { ram_1c &= ~0x10; }
void DSP_Deassert_Read(void) { ram_1c |= 0x10; }

void DSP_Bytecode_NotifyStateChange(void) { Kernel_SemaSignal(1); }

void Audio_InitRingBuffers(void)
{
    RingBuf_Init_1K();
    RingBuf_Init_256();
    RingBuf_Init_512();
}

void RingBuf_Reset_256(int a, int b, int *p)
{
    p[-5] = 0;
    p[-4] = 0;
    p[-2] = 0;
    p[-3] = 0;
    p[-1] = 0xff;
}

void RingBuf_Reset_512(int a, int b, int *p)
{
    p[-5] = 0;
    p[-4] = 0;
    p[-2] = 0;
    p[-3] = 0;
    p[-1] = 0x1ff;
}

void RingBuf_Reset_1K(int a, int b, int *p)
{
    p[-5] = 0;
    p[-4] = 0;
    p[-2] = 0;
    p[-3] = 0;
    p[-1] = 0x3ff;
}

long DSP_ParamFetch_SingleTable(int x, unsigned long i) { return DSP_CoeffCurve_Op62[i]; }

long DSP_ParamFetch_AlgoTypeTable(unsigned char **pp, unsigned long i)
{
    unsigned char *p;
    long r;

    p = *pp;
    switch (*p) {
    case 0:
        r = DSP_FreqParamCurve_Algo0[i];
        break;
    case 1:
        r = DSP_FreqParamCurve_Algo1[i];
        break;
    case 2:
        r = DSP_FreqParamCurve_Algo2[i];
        break;
    }
    *pp = ++p;
    return r;
}

long DSP_UnpackParam3B(unsigned char **pp)
{
    unsigned char *p;
    long v;

    p = *pp;
    v = ((long)p[0] << 16) + ((long)p[1] << 8) + p[2];
    *pp = p + 3;
    return v;
}

char *DSP_StreamDecode_3ByteWord(char *p, long *out)
{
    long a;
    long b;
    long c;

    a = ((long)*p++ << 24) & 0xff000000;
    b = ((long)*p++ << 16) & 0xff0000;
    c = ((long)*p++ << 8) & 0xff00;
    *out = a + b + c;
    return p;
}

unsigned char *DSP_TableWalk_Search(unsigned char *p, unsigned int key, unsigned int len, int *out)
{
    unsigned char *next;
    unsigned int w;
    int r;

    while (((w = ((unsigned int)p[0] << 8) + p[1]) >> 8) != 0xf0) {
        next = p + w;
        p += 2;
        if (*p == key) {
            p += len + 1;
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

unsigned char *DSP_TableWalk_SearchWithState(unsigned char *p, int n, int *st, unsigned char **out)
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

void DSP_WriteParamWord(long v, int chip)
{
    DSP_DispatchData((unsigned char)((v >> 16) & 0xff), chip);
    DSP_DispatchData((unsigned char)((v >> 8) & 0xff), chip);
}

void DSP_WriteCoeffData_5B(long v, int chip)
{
    DSP_DispatchData(0xa, chip);
    DSP_DispatchData((unsigned char)((v >> 17) & 0x7f), chip);
    DSP_DispatchData((unsigned char)((v >> 9) & 0xff), chip);
    DSP_DispatchData((unsigned char)((v >> 1) & 0xff), chip);
    DSP_DispatchData((unsigned char)(((v << 7) & 0x80) + 0x15), chip);
}

void DSP_WriteCoeffData_5B_Direct(long v, int chip)
{
    DSP_DispatchData(0xa, chip);
    DSP_DispatchData((unsigned char)((v >> 17) & 0x7f), chip);
    DSP_DispatchData((unsigned char)((v >> 9) & 0xff), chip);
    DSP_DispatchData((unsigned char)((v >> 1) & 0xff), chip);
    DSP_DispatchData((unsigned char)(((v << 7) & 0x80) + 0x26), chip);
}

void DSP_WriteOscParam_Offset(unsigned int a, long v, int chip, long off, unsigned int base)
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

void DSP_WriteEFFConfig(unsigned int slot, unsigned char *code)
{
    DSP_BytecodeInterpreter_Init(EFF_SlotToChip_Table[slot], slot, ToneGen_WorkArea, code);
}

void DSP_WriteGlobalConfig(int chip, unsigned char *code)
{
    DSP_BytecodeInterpreter_Init(chip, 0, DSP_Bytecode_Global_Config, code);
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

void DSP_State_DmaLoadPresets(void)
{
    Kernel_StartTask(3);
    MsgQueue_Send(1, &ram_45324);
    MsgQueue_Send(1, &ram_45446);
}

void DSP_State_ApplyTask(void)
{
    struct dspstate *p;

    for (;;) {
        p = MsgQueue_ReceiveBlocking(2);
        DSP_State_ApplyAll(p);
        p->busy = 0;
        MsgQueue_Send(1, p);
    }
}

int __cdecl Audio_CmdHandler_20_3F(unsigned char cmd, unsigned char *d) { return 0; }

int __cdecl Audio_CmdHandler_40_5F(char n, unsigned char *d)
{
    while (n--)
        ;
    return 0;
}
