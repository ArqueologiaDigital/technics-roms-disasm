/* Functions of core/14_dsp_control_routines.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function (notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
   Held back from subcpu/cc900/ (2026-11-16): these call the shared kernel (wsa1/kernel/kernel.s), whose
   labels the build cannot resolve yet.
*/

extern long DSP_OscParamCurve[];



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













void DSP_Bytecode_NotifyStateChange(void) { Kernel_SemaSignal(1); }



























struct dspstate { int w[0x90]; int busy; };
extern struct dspstate ram_45324;
extern struct dspstate ram_45446;
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
    MsgQueue_Send(1, &ram_45324);
    MsgQueue_Send(1, &ram_45446);
}

extern unsigned char __near ram_4a48;
extern unsigned char __near ram_4a4a;
extern struct bcfg DSP_Bytecode_Global_Config[];
extern unsigned char *DSP_TableWalk_Search(unsigned char *p, unsigned int key, unsigned int len, int *out);








