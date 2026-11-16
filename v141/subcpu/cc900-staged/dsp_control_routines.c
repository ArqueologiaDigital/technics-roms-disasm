/* Functions of core/14_dsp_control_routines.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function (notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

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
extern void Kernel_SemaSignal(int n);

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
extern struct dspstate ram_4530c;
extern struct dspstate ram_4542e;
extern void DSP_State_ApplyAll(struct dspstate *s);
extern void Kernel_StartTask(int n);
extern void MsgQueue_Send(int q, void *m);
extern void *MsgQueue_ReceiveBlocking(int q);

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
    MsgQueue_Send(1, &ram_4530c);
    MsgQueue_Send(1, &ram_4542e);
}
