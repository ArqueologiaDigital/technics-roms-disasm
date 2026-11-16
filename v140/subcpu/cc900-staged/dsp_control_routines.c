/* Functions of core/14_dsp_control_routines.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function at -Xr (notes/cc900-c-subcpu-2026-11-16/);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   cc900-options: -Xr */
extern long DSP_OscParamCurve[];

long DSP_ParamFetch_Op61Table(int x, unsigned long i) { return DSP_OscParamCurve[i]; }

struct bcfg { int a; int b; int c; int d; long e; };
extern unsigned char __tiny ram_1c;
extern unsigned char __tiny ram_44;
extern struct bcfg ToneGen_WorkArea[];
extern unsigned char EFF_SlotToChip_Table[];
extern long DSP_CoeffCurve_Op62[];
extern long DSP_FreqParamCurve_Algo0[];
extern long DSP_FreqParamCurve_Algo1[];
extern long DSP_FreqParamCurve_Algo2[];
extern int DSP_DispatchData(int d, int chip);
extern int DSP_BytecodeInterpreter_Init(int chip, unsigned int idx, struct bcfg *cfg, unsigned char *code);
extern void DSP_ParameterWriteEngine(unsigned int slot, struct bcfg *work, unsigned char *desc, unsigned char *rec,
                                     int v, unsigned char *vals);

void DSP1_Assert_Reset(void) { ram_44 &= ~2; }

void DSP1_Deassert_Reset(void) { ram_44 |= 2; }

void DSP2_Assert_Reset(void) { ram_44 &= ~4; }

void DSP2_Deassert_Reset(void) { ram_44 |= 4; }

void DSP_Assert_Read(void) { ram_1c &= ~0x10; }

void DSP_Assert_Write(void) { ram_1c &= ~8; }

void DSP_Bytecode_NotifyStateChange(void) { Kernel_SemaSignal(1); }

void DSP_Deassert_Read(void) { ram_1c |= 0x10; }

void DSP_Deassert_Write(void) { ram_1c |= 8; }

void DSP_Nop(void) { }

void DSP_NopReturn(void) { }

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

long DSP_ParamFetch_SingleTable(int x, unsigned long i) { return DSP_CoeffCurve_Op62[i]; }

void DSP_Set_Command_Mode(void) { ram_1c &= ~0x40; }

void DSP_Set_Data_Mode(void) { ram_1c |= 0x40; }

long DSP_UnpackParam3B(unsigned char **pp)
{
    unsigned char *p;
    long v;

    p = *pp;
    v = ((long)p[0] << 16) + ((long)p[1] << 8) + p[2];
    *pp = p + 3;
    return v;
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

void DSP_WriteEFFConfig(unsigned int slot, unsigned char *code)
{
    DSP_BytecodeInterpreter_Init(EFF_SlotToChip_Table[slot], slot, ToneGen_WorkArea, code);
}

void DSP_WriteParamWord(long v, int chip)
{
    DSP_DispatchData((unsigned char)((v >> 16) & 0xff), chip);
    DSP_DispatchData((unsigned char)((v >> 8) & 0xff), chip);
}

struct dspstate { int w[0x90]; int busy; };
extern struct dspstate ram_452d8;
extern struct dspstate ram_453fa;

void DSP_State_ApplyTask(void)
{
    struct dspstate *p;

    while (1) {
        p = MsgQueue_ReceiveBlocking(2);
        DSP_State_ApplyAll(p);
        p->busy = 0;
        MsgQueue_Send(1, p);
    }
}

void DSP_State_DmaLoadPresets(void)
{
    Kernel_StartTask(3);
    MsgQueue_Send(1, &ram_452d8);
    MsgQueue_Send(1, &ram_453fa);
}

extern struct dspstate *__near ram_4a3a;

void DSP_State_ApplyBuf(struct dspstate *src)
{
    if ((ram_4a3a = MsgQueue_Receive_NoBlock(2)) == 0)
        ram_4a3a = MsgQueue_ReceiveBlocking(1);
    *ram_4a3a = *src;
    ram_4a3a->busy = 1;
    MsgQueue_Send(2, ram_4a3a);
}
