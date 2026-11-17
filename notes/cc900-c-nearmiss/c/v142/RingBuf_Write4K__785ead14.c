/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the whole file of sub/sub_D_6b.c (2026-11-16-73-sub-r6)
   sha256 785ead14bde2cd00a37c982e36dbc98d6a424ae515442f94fae6ab5b95c95cd9 (name+funcs); compiled at -Xr */
/* lane_sub probe round 6, helper D, form b: DSP / effect routines of the KN5000 sub-CPU payload v1.42
   (core/11_ringbuf_and_midi_dispatch.s, core/12_dsp2_init.s, core/13_audio_process_dsp_and_effects.s): the routines
   that reach same-module code with calr / jrl, and the round-2 routines that end in a jrl.
   Names are the tree's labels and .equ names; ram_<hex> is a RAM cell the tree has not named.
   The same-module callees (asm900 gave their calls the relative form):
*/
/* cc900-module: DSP_ApplyAlgoForVoiceType DSP_FlushAllSlots DSP_WriteAlgoInitPreset DSP_State_DiffAll EFF_StateLoad_Prepare DSP_AlgoChange_CheckAndFlag */
/* cc900-module: DSP_SlotParam_DiffAndFlag DSP_EFFParam_DiffAllAndFlag EFF_SlotActive_UpdateFlags EFF_DSPLink_ResetFlags EFF_DspChannel_InitFlags DSP_Config_ClampLimits */
/* cc900-module: DSP_State_DiffAndPrepare DSP_State_Dispatcher DSP_StateTable_Save EFF_ParamIterator_Process DSP_Send_Command DSP2_Send_Command */
/* cc900-module: DSP_Send_Data DSP2_Send_Data DSP_RingBuf_Read RingBuf_ReadByte DSP_ResetLoop EFF_MuteLoop */
/* cc900-module: DSP_MuteLoop DSP_AlgorithmChangeCheck EFF_DisconnectLoop DSP_UnmuteLoop EFF_HeaderChangeDataLoop EFF_LinkLoop */
/* cc900-module: EFF_VolumeLoop EFF_SecondaryLinkPath DSP_AntiReset_WithDebug Unsigned_Max_Select EFF_Change_Handler EFF_VolumeChange_Check */

struct slot { unsigned int type; unsigned int a[1]; int param[17]; int idx; int q[1]; int r42[6]; int on; };
struct cfg { unsigned int f0, f2, f4, f6; struct slot s[5]; };
struct rec { unsigned int f0; unsigned int a[1]; unsigned int flags[17]; unsigned int q[1]; unsigned int g[5]; };
struct fxflags { unsigned int active[5]; unsigned int chip[2]; unsigned int algochg; struct rec r[5]; };
struct e50 { unsigned int f0; char pad[48]; };
struct ring2k { unsigned int w, r, n; unsigned char buf[2048]; };
struct ring4k { unsigned int w, r, n; unsigned char buf[4096]; };
struct cfgimg { int w[0x91]; };

extern struct cfg __near DSP_ConfigBuffer;
extern struct cfg __near DSP_DefaultEffectConfig_Image;
extern struct slot __near ram_4496[];
extern struct fxflags __near EFF_SlotActiveFlags;
extern struct e50 __near ram_4940[];
extern unsigned int __near DSP_SlotMuteState[];
extern unsigned int __near ram_4492;
extern unsigned int __near ram_454a;
extern unsigned int __near ram_45b0;
extern unsigned int __near ram_45b2;
extern unsigned int __near ram_45b4;
extern unsigned int __near ram_45b6;
extern unsigned int __near ram_45b8;
extern unsigned int __near ram_45ba;
extern unsigned int __near ram_45c8;
extern unsigned char __near ram_4369[];
extern unsigned char ram_41381[];
extern unsigned char ram_41382[];

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
extern void DSP_FlushAllSlots(int, int);
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
extern void EFF_Disconnect(unsigned int, unsigned int);
extern void EFF_Change_WithDebug(unsigned int, unsigned int);
extern void EFF_DataChange_WithDebug(unsigned int, unsigned int);
extern int DSP_RingBuf_Read(struct ring2k *);
extern int RingBuf_ReadByte(struct ring4k *);
extern void DSP_Send_Command(int);
extern void DSP2_Send_Command(int);
extern void DSP_Send_Data(int);
extern void DSP2_Send_Data(int);

void DSP_ApplyConfig(unsigned char mode, unsigned char unused, unsigned char flag)
{
    unsigned int *q;

    if (flag == 0xff)
        DSP_ConfigBuffer.f0 = 1;
    else
        DSP_ConfigBuffer.f0 = 0;
    switch (mode) {
    case 0:
        DSP_State_ApplyBuf(&DSP_ConfigBuffer);
        DSP_ApplyAlgoForVoiceType(ram_4496[0].type);
        return;
    case 1: case 2: case 4:
        DSP_State_ApplyBuf(&DSP_ConfigBuffer);
        return;
    case 3:
        q = &ram_454a;
        *q = ram_45ba != 0 ? ram_45b8 : 0;
        DSP_State_ApplyBuf(&DSP_ConfigBuffer);
        break;
    }
    ;
}

void DSP_Set_RotarySpeed(unsigned char v)
{
    DSP_ConfigBuffer.f0 = 0;
    ram_45b0 = v;
    DSP_ApplyAlgoForVoiceType(ram_4496[0].type);
}

void DSP_ReconfigAndStatus(void)
{
    DSP_State_ApplyBuf(&DSP_ConfigBuffer);
    DSP_ApplyAlgoForVoiceType(ram_4496[0].type);
}

void DSP_FlushAllSlots_ForPart(unsigned char part)
{
    DSP_FlushAllSlots(ram_41381[part * 0x11f], ram_41382[part * 0x11f]);
}

void DSP_State_DiffAll(struct cfg *p)
{
    DSP_AlgoChange_CheckAndFlag(p);
    DSP_SlotParam_DiffAndFlag(p);
    DSP_EFFParam_DiffAllAndFlag(p);
}

void EFF_StateLoad_Prepare(struct cfg *p)
{
    EFF_SlotActive_UpdateFlags(p);
    EFF_DSPLink_ResetFlags();
    EFF_DspChannel_InitFlags(p);
}

void DSP_State_DiffAndPrepare(struct cfg *p)
{
    DSP_State_DiffAll(p);
    EFF_StateLoad_Prepare(p);
}

extern void DSP_State_Dispatcher(struct cfg *);

int DSP_State_ApplyAll(struct cfg *p)
{
    ram_45c8 = 0;
    DSP_Config_ClampLimits(p);
    DSP_State_DiffAndPrepare(p);
    DSP_State_Dispatcher(p);
    DSP_StateTable_Save(p);
    return ram_45c8;
}

int DSP_DispatchCommand(unsigned char c, unsigned int chip)
{
    int r;

    r = 0;
    switch (chip) {
    case 0:
        DSP_Send_Command(c);
        break;
    case 1:
        DSP2_Send_Command(c);
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
        DSP_Send_Data(c);
        break;
    case 1:
        DSP2_Send_Data(c);
        break;
    default:
        r++;
        break;
    }
    return r;
}

void DSP_RingBuf_Skip(struct ring2k *r)
{
    while (DSP_RingBuf_Read(r) >= 0) {
    }
    r->w = r->r;
}

void RingBuf_SkipToEnd(struct ring4k *r)
{
    while (RingBuf_ReadByte(r) >= 0) {
    }
    r->w = r->r;
}

void DSP_RingBuf_Write2K(struct ring2k *r, unsigned char c)
{
    *((unsigned char *)r + ((unsigned long)(r->w++ & 2047) + 6)) = c;
    r->n++;
}

void RingBuf_Write4K(struct ring4k *r, unsigned char c)
{
    *((unsigned char *)r + ((unsigned long)(r->w++ & 4095) + 6)) = c;
    r->n++;
}

void DSP_Cmd_DequeueHeader(struct ring2k *r)
{
    ram_4369[0] = DSP_RingBuf_Read(r);
    ram_4369[1] = DSP_RingBuf_Read(r);
    ram_4369[2] = DSP_RingBuf_Read(r);
    ram_4369[3] = DSP_RingBuf_Read(r);
    ram_4369[4] = DSP_RingBuf_Read(r);
    ram_4369[5] = DSP_RingBuf_Read(r);
    ram_4369[6] = DSP_RingBuf_Read(r);
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

void DSP_AlgorithmChange(struct cfg *p)
{
    unsigned int chip;

    Debug_Print_String(Str_DspAlgoChange_Msg);
    Debug_Print_Byte(p->f6);
    chip = 0;
    DSP_WriteGlobalConfig(chip, (unsigned char *)(unsigned long)DSP_AlgoChange_Program);
    if (p->f4 == 1)
        DSP_AntiReset_WithDebug(chip);
    DSP_WriteGlobalConfig(chip, (unsigned char *)(unsigned long)DSP1_BootProgram);
    chip = 1;
    DSP_WriteGlobalConfig(chip, (unsigned char *)(unsigned long)DSP2_BootProgram_Step1);
    DSP_WriteGlobalConfig(chip, (unsigned char *)(unsigned long)DSP2_BootProgram_Step2);
    DSP_WaitForDelay(1);
    DSP_WriteGlobalConfig(chip, (unsigned char *)(unsigned long)DSP2_BootProgram_Step3);
    DSP_WriteGlobalConfig(chip, (unsigned char *)(unsigned long)DSP2_BootProgram_Step4);
    DSP_WriteGlobalConfig(chip, (unsigned char *)(unsigned long)DSP2_BootProgram_Step5);
    DSP_WriteGlobalConfig(chip, (unsigned char *)(unsigned long)DSP2_BootProgram_Step6);
}

void EFF_VolumeChange_Check(unsigned int slot, struct cfg *p)
{
    if (EFF_SlotActiveFlags.r[slot].g[4] == 1)
        EFF_ParamIterator_Process(slot, p);
}

void EFF_Change_Handler(unsigned int slot, struct cfg *p)
{
    if (ram_4940[slot].f0 == 1) {
        switch (slot) {
        case 2:
            if (p->f4 == 1)
                EFF_Disconnect(slot, p->f6);
            break;
        default:
            EFF_Disconnect(slot, p->f6);
            break;
        }
        switch (slot) {
        default:
            EFF_Change_WithDebug(slot, ((struct slot *)((char *)p + ((unsigned long)slot * 56 + 8)))->type);
            break;
        case 2: case 3: case 4:
            if (p->f4 == 1)
                EFF_Change_WithDebug(slot, ((struct slot *)((char *)p + ((unsigned long)slot * 56 + 8)))->type);
            else
                EFF_DataChange_WithDebug(slot, ((struct slot *)((char *)p + ((unsigned long)slot * 56 + 8)))->type);
            break;
        }
    }
    EFF_VolumeChange_Check(slot, p);
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

void EFF_SecondaryLinkPath(struct cfg *p)
{
    unsigned int m;
    int i;

    m = 0;
    for (i = 4; i > -1; i--)
        if (EFF_SlotActiveFlags.r[i].g[3] == 1 && p->s[i].on == 0)
            m = Unsigned_Max_Select(m, 20);
    if (m != 0)
        DSP_ScheduleDelay(m);
    m = 0;
    for (i = 4; i > -1; i--)
        if (EFF_SlotActiveFlags.r[i].g[3] == 1 && p->s[i].on == 0) {
            if (i != 3 && i != 2)
                EFF_Disconnect(i, p->f6);
            m = Unsigned_Max_Select(m, EFF_SlotSettleTime_Table[i]);
        }
    if (m != 0)
        DSP_ScheduleDelay(m);
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

struct slot *EFF_GetSlotBuffer(unsigned int i)
{
    struct slot *r;

    switch (i) {
    case 0: case 1: case 2: case 3: case 4:
        __XWA = (unsigned long)&ram_4496[i];
        r = (struct slot *)__XWA;
        break;
    default:
        r = (struct slot *)0xffffffff;
        break;
    }
    return r;
}
