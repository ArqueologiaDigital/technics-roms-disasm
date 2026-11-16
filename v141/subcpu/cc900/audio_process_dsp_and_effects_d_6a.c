/* Functions of core/13_audio_process_dsp_and_effects.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function (notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

struct slot { unsigned int type; unsigned int a[1]; int param[17]; int idx; int q[1]; int r42[6]; int on; };
struct cfg { unsigned int f0, f2, f4, f6; struct slot s[5]; };
struct rec { unsigned int f0; unsigned int a[1]; unsigned int flags[17]; unsigned int q[1]; unsigned int g[5]; };
struct fxflags { unsigned int active[5]; unsigned int chip[2]; unsigned int algochg; struct rec r[5]; };
struct e50 { unsigned int f0; char pad[48]; };
struct cfgimg { int w[0x91]; };
extern struct cfg __near DSP_ConfigBuffer;
extern struct cfg __near DSP_DefaultEffectConfig_Image;
extern struct slot __near ram_4496[];
extern struct fxflags __near EFF_SlotActiveFlags;
extern struct e50 __near ram_4940[];
extern unsigned int __near DSP_SlotMuteState[];
extern unsigned int __near ram_4492;
extern unsigned int __near ram_45b0;
extern unsigned int __near ram_45b2;
extern unsigned int __near ram_45b4;
extern unsigned int __near ram_45b6;
extern unsigned int __near ram_45b8;
extern unsigned int __near ram_45ba;
extern unsigned int __near ram_45c8;
extern char Str_DspAlgoChange_Msg[];
extern unsigned char DSP_EffectClass_Table[];
extern unsigned char EFF_SlotSettleTime_Table[];
extern unsigned char DSP_AlgoChange_Program[], DSP1_BootProgram[];
extern unsigned char DSP2_BootProgram_Step1[], DSP2_BootProgram_Step2[], DSP2_BootProgram_Step3[];
extern unsigned char DSP2_BootProgram_Step4[], DSP2_BootProgram_Step5[], DSP2_BootProgram_Step6[];
extern void Debug_Print_String(char *);
extern void Debug_Print_Byte(unsigned int);
extern void DSP_WriteGlobalConfig(unsigned int, unsigned char *);
extern void DSP_State_ApplyBuf(struct cfg *);
extern void DSP_ApplyAlgoForVoiceType(unsigned int);
extern void DSP_WriteAlgoInitPreset(unsigned int);
extern int DSP_MixerCoeff_Compute(unsigned int, unsigned int, unsigned int);
extern void DSP_State_LoadAndApplyAll(struct cfg *);
extern void DSP_State_DmaLoadPresets(void);
extern void DSP_WaitForDelay(unsigned int);
extern void DSP_ScheduleDelay(int);
extern void DSP_AntiReset_WithDebug(unsigned int);
extern unsigned int Unsigned_Max_Select(unsigned int, unsigned int);
extern void DSP_AlgoChange_CheckAndFlag(struct cfg *);
extern void DSP_SlotParam_DiffAndFlag(struct cfg *);
extern void DSP_EFFParam_DiffAllAndFlag(struct cfg *);
extern void EFF_SlotActive_UpdateFlags(struct cfg *);
extern void EFF_DSPLink_ResetFlags(void);
extern void EFF_DspChannel_InitFlags(struct cfg *);
extern void DSP_Config_ClampLimits(struct cfg *);
extern void DSP_StateTable_Save(struct cfg *);
extern void EFF_ParamIterator_Process(unsigned int, struct cfg *);
extern void DSP_ResetLoop(void);
extern void EFF_MuteLoop(struct cfg *);
extern void DSP_MuteLoop(void);
extern void DSP_AlgorithmChangeCheck(struct cfg *);
extern void EFF_WriteHeader(unsigned int);
extern void EFF_DisconnectLoop(struct cfg *);
extern void DSP_UnmuteLoop(void);
extern void EFF_LinkLoop(struct cfg *);
extern void EFF_VolumeLoop(struct cfg *);
extern void DSP_Send_Command(int, unsigned int);
extern void DSP2_Send_Command(int, unsigned int);
extern void DSP_Send_Data(int, unsigned int);
extern void DSP2_Send_Data(int, unsigned int);
extern void DSP_State_Dispatcher(struct cfg *);
void EFF_Change_Handler(unsigned int slot, struct cfg *p);
void EFF_SecondaryLinkPath(struct cfg *p);

/* cc900-module: DSP2_Send_Command DSP2_Send_Data DSP_AlgoChange_CheckAndFlag DSP_AlgorithmChangeCheck DSP_AntiReset_WithDebug DSP_ApplyAlgoForVoiceType DSP_Config_ClampLimits DSP_EFFParam_DiffAllAndFlag DSP_MuteLoop DSP_ResetLoop DSP_Send_Command DSP_Send_Data DSP_SlotParam_DiffAndFlag DSP_StateTable_Save DSP_State_DiffAll DSP_State_DiffAndPrepare DSP_State_Dispatcher DSP_UnmuteLoop DSP_WriteAlgoInitPreset EFF_Change_Handler EFF_DSPLink_ResetFlags EFF_DisconnectLoop EFF_DspChannel_InitFlags EFF_HeaderChangeDataLoop EFF_LinkLoop EFF_MuteLoop EFF_ParamIterator_Process EFF_SecondaryLinkPath EFF_SlotActive_UpdateFlags EFF_StateLoad_Prepare EFF_VolumeChange_Check EFF_VolumeLoop Unsigned_Max_Select */
void DSP_AlgorithmChange(struct cfg *p);
int DSP_DispatchCommand(unsigned char c, unsigned int chip);
int DSP_DispatchData(unsigned char c, unsigned int chip);
void DSP_ReconfigAndStatus(void);
void DSP_Reset(void);
void DSP_Set_RotarySpeed(unsigned char v);
int DSP_State_ApplyAll(struct cfg *p);
void DSP_State_DiffAll(struct cfg *p);
void DSP_State_DiffAndPrepare(struct cfg *p);
void DSP_State_Dispatcher(struct cfg *p);
void EFF_HeaderChangeDataLoop(struct cfg *p);
void EFF_StateLoad_Prepare(struct cfg *p);
void EFF_VolumeChange_Check(unsigned int slot, struct cfg *p);

void DSP_AlgorithmChange(struct cfg *p)
{
    unsigned int chip;

    Debug_Print_String(Str_DspAlgoChange_Msg);
    Debug_Print_Byte(p->f6);
    chip = 0;
    DSP_WriteGlobalConfig(chip, &DSP_AlgoChange_Program[0]);
    if (p->f4 == 1)
        DSP_AntiReset_WithDebug(chip);
    DSP_WriteGlobalConfig(chip, &DSP1_BootProgram[0]);
    chip = 1;
    DSP_WriteGlobalConfig(chip, &DSP2_BootProgram_Step1[0]);
    DSP_WriteGlobalConfig(chip, &DSP2_BootProgram_Step2[0]);
    DSP_WaitForDelay(1);
    DSP_WriteGlobalConfig(chip, &DSP2_BootProgram_Step3[0]);
    DSP_WriteGlobalConfig(chip, &DSP2_BootProgram_Step4[0]);
    DSP_WriteGlobalConfig(chip, &DSP2_BootProgram_Step5[0]);
    DSP_WriteGlobalConfig(chip, &DSP2_BootProgram_Step6[0]);
}

int DSP_DispatchCommand(unsigned char c, unsigned int chip)
{
    int r;

    r = 0;
    switch (chip) {
    case 0:
        DSP_Send_Command(c, chip);
        break;
    case 1:
        DSP2_Send_Command(c, chip);
        break;
    default:
        r++;
        break;
    }
    return r;
}

int DSP_DispatchData(unsigned char c, unsigned int chip)
{
    int r;

    r = 0;
    switch (chip) {
    case 0:
        DSP_Send_Data(c, chip);
        break;
    case 1:
        DSP2_Send_Data(c, chip);
        break;
    default:
        r++;
        break;
    }
    return r;
}

void DSP_ReconfigAndStatus(void)
{
    DSP_State_ApplyBuf(&DSP_ConfigBuffer);
    DSP_ApplyAlgoForVoiceType(ram_4496[0].type);
}

void DSP_Reset(void)
{
    unsigned int a;

    ram_45b0 = 1;
    ram_45b2 = 0;
    ram_45b4 = 0;
    ram_45b6 = 0;
    ram_45b8 = 0;
    ram_45ba = 0;
    DSP_MixerCoeff_Compute(ram_45b2, ram_45b4, ram_45b6);
    *(struct cfgimg *)0x448e = *(struct cfgimg *)0xf01e;
    DSP_State_LoadAndApplyAll(&DSP_ConfigBuffer);
    ram_4492 = 0;
    DSP_State_DmaLoadPresets();
    a = DSP_DefaultEffectConfig_Image.s[0].type;
    DSP_WriteAlgoInitPreset(a);
    DSP_ApplyAlgoForVoiceType(a);
    DSP_MixerCoeff_Compute(ram_45b2, ram_45b4, ram_45b6);
}

void DSP_Set_RotarySpeed(unsigned char v)
{
    DSP_ConfigBuffer.f0 = 0;
    ram_45b0 = v;
    DSP_ApplyAlgoForVoiceType(ram_4496[0].type);
}

int DSP_State_ApplyAll(struct cfg *p)
{
    ram_45c8 = 0;
    DSP_Config_ClampLimits(p);
    DSP_State_DiffAndPrepare(p);
    DSP_State_Dispatcher(p);
    DSP_StateTable_Save(p);
    return ram_45c8;
}

void DSP_State_DiffAll(struct cfg *p)
{
    DSP_AlgoChange_CheckAndFlag(p);
    DSP_SlotParam_DiffAndFlag(p);
    DSP_EFFParam_DiffAllAndFlag(p);
}

void DSP_State_DiffAndPrepare(struct cfg *p)
{
    DSP_State_DiffAll(p);
    EFF_StateLoad_Prepare(p);
}

void DSP_State_Dispatcher(struct cfg *p)
{
    int i;
    unsigned int t;

    if (p->f4 == 1)
        DSP_ResetLoop();
    else
        EFF_MuteLoop(p);
    DSP_MuteLoop();
    DSP_AlgorithmChangeCheck(p);
    if (p->f4 == 1 || p->f2 == 1) {
        EFF_WriteHeader(0);
        EFF_DisconnectLoop(p);
    }
    DSP_UnmuteLoop();
    EFF_HeaderChangeDataLoop(p);
    EFF_LinkLoop(p);
    EFF_VolumeLoop(p);
    EFF_SecondaryLinkPath(p);
    for (i = 4; i > -1; i--) {
        t = p->s[i].type;
        if (ram_4940[i].f0 == 1) {
            if (DSP_EffectClass_Table[t] != 0)
                DSP_SlotMuteState[i] = DSP_EffectClass_Table[t] + 1;
            else
                DSP_SlotMuteState[i] = 0;
        }
    }
}

void EFF_HeaderChangeDataLoop(struct cfg *p)
{
    unsigned int m;
    int i;

    m = 0;
    for (i = 4; i > -1; i--) {
        if (p->f2 == 1 || p->f4 == 1)
            EFF_WriteHeader(i);
        if (ram_4940[i].f0 == 1 || p->f0 == 1)
            m = Unsigned_Max_Select(m, EFF_SlotSettleTime_Table[i]);
        EFF_Change_Handler(i, p);
    }
    if (m != 0)
        DSP_ScheduleDelay(m);
}

void EFF_StateLoad_Prepare(struct cfg *p)
{
    EFF_SlotActive_UpdateFlags(p);
    EFF_DSPLink_ResetFlags();
    EFF_DspChannel_InitFlags(p);
}

void EFF_VolumeChange_Check(unsigned int slot, struct cfg *p)
{
    if (EFF_SlotActiveFlags.r[slot].g[4] == 1)
        EFF_ParamIterator_Process(slot, p);
}
