/* Functions of core/13_audio_process_dsp_and_effects.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function (notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

unsigned int Unsigned_Max_Select(unsigned int a, unsigned int b)
{
    if (b > a) a = b;
    return a;
}

struct st { int w[0x91]; };

void DSP_StateTable_Save(struct st *p) { *(struct st *)0x45ca = *p; }

struct slot { unsigned int type; int f2; int param[25]; int on; };
struct cfg { unsigned int f0, f2, f4, f6; struct slot s[5]; };
struct e50 { unsigned int f0; char pad[48]; };
struct cfgimg { int w[0x91]; };
extern struct cfg __near DSP_ConfigBuffer;
extern struct slot __near ram_45d2[];
extern unsigned int __near ram_45d0;
extern unsigned int __near DSP_SlotMuteState[];
extern unsigned int __near ram_4504;
extern unsigned int __near ram_453c;
extern unsigned int __near ram_4574;
extern unsigned int __near ram_45ac;
extern unsigned int __near ram_45b2;
extern unsigned int __near ram_45b4;
extern unsigned int __near ram_45b6;
extern unsigned int __near EFF_SlotActiveFlags[];
extern unsigned int __near DSP_ChipActiveFlags[];
extern unsigned int __near DSP_AlgoChangedFlag;
extern struct e50 __near ram_4940[];
extern int ram_4551a;
extern int ram_453f8;
extern unsigned char DSP_EffectClass_Table[];
extern void DSP_State_ApplyBuf(struct cfg *);
extern int DSP_MixerCoeff_Compute(unsigned int, unsigned int, unsigned int);
extern void DSP_AlgorithmChange(void);
extern void DSP_State_ApplyTask(void);
extern void Kernel_SemaWait(int);
extern void DSP_ScheduleDelay(int);

void DSP_AlgoChange_CheckAndFlag(struct cfg *p)
{
    if (p->f6 != ram_45d0 || p->f2 == 1 || p->f4 == 1)
        DSP_AlgoChangedFlag = 1;
    else
        DSP_AlgoChangedFlag = 0;
}

void DSP_AlgorithmChangeCheck(void)
{
    if (DSP_AlgoChangedFlag == 1)
        DSP_AlgorithmChange();
}

int DSP_Config_DeadTail_SumWords(void)
{
    return ram_4551a + ram_453f8;
}

struct cfg *DSP_GetConfigBuffer(void)
{
    return &DSP_ConfigBuffer;
}

void DSP_MuteLoop(void)
{
    unsigned int i;

    for (i = 0; i < 2; i++)
        if (DSP_ChipActiveFlags[i] == 1)
            DSP_Mute_WithDebug(i);
}

void DSP_ResetLoop(void)
{
    unsigned int i;

    for (i = 0; i < 2; i++)
        DSP_Reset_WithDebug(i);
}

void DSP_ResetTask_NullStub(void)
{
}

void DSP_Set_AcousticIllusionOnOff(unsigned char v)
{
    DSP_ConfigBuffer.f0 = 0;
    ram_453c = v;
    DSP_State_ApplyBuf(&DSP_ConfigBuffer);
}

void DSP_Set_DigitalReverbOnOff(unsigned char v)
{
    DSP_ConfigBuffer.f0 = 0;
    ram_4504 = v;
    DSP_State_ApplyBuf(&DSP_ConfigBuffer);
}

void DSP_Set_EqualizerOnOff(unsigned char v)
{
    DSP_ConfigBuffer.f0 = 0;
    ram_45ac = v;
    DSP_State_ApplyBuf(&DSP_ConfigBuffer);
}

int DSP_Set_FadeLevel(unsigned char v)
{
    ram_45b6 = v;
    return DSP_MixerCoeff_Compute(ram_45b2, ram_45b4, ram_45b6);
    return ram_45b6;
}

void DSP_Set_MicReverbOnOff(unsigned char v)
{
    DSP_ConfigBuffer.f0 = 0;
    ram_4574 = v;
    DSP_State_ApplyBuf(&DSP_ConfigBuffer);
}

int DSP_Set_MixParam_45B4(unsigned char v)
{
    ram_45b4 = v;
    return DSP_MixerCoeff_Compute(ram_45b2, ram_45b4, ram_45b6);
    return ram_45b4;
}

unsigned int DSP_SlotMuteState_ReadAndClear(unsigned int i)
{
    unsigned int r;

    r = DSP_SlotMuteState[i];
    DSP_SlotMuteState[i] = 0;
    return r;
}

unsigned int DSP_State_LookupAlgoIndex(unsigned int i)
{
    return DSP_EffectClass_Table[i];
}

void DSP_UnmuteLoop(void)
{
    unsigned int i;

    for (i = 0; i < 2; i++)
        if (DSP_ChipActiveFlags[i] == 1)
            DSP_Unmute_WithDebug(i);
}



int EFF_ConfigSnapshot_Restore(void)
{
    *(struct cfgimg *)0x46ec = *(struct cfgimg *)0x480e;
    return 0;
}

int EFF_ConfigSnapshot_Save(void)
{
    *(struct cfgimg *)0x480e = *(struct cfgimg *)0x46ec;
    return 0;
}

void EFF_DSPLink_ResetFlags(void)
{
    unsigned int i;

    if (DSP_AlgoChangedFlag == 1) {
        DSP_ChipActiveFlags[0] = 1;
        for (i = 1; i < 2; i++)
            DSP_ChipActiveFlags[i] = 0;
    } else {
        for (i = 0; i < 2; i++)
            DSP_ChipActiveFlags[i] = 0;
    }
}

void EFF_DisconnectLoop(struct cfg *p)
{
    int i;

    for (i = 4; i > -1; i--)
        if (i != 3 && i != 2)
            EFF_Disconnect(i, p->f6);
}

void EFF_MuteLoop(void)
{
    unsigned int i;
    unsigned int muted;

    muted = 0;
    for (i = 0; i < 5; i++) {
        if (EFF_SlotActiveFlags[i] == 1) {
            if (ram_4940[i].f0 == 1 && DSP_EffectClass_Table[ram_45d2[i].type] != 0)
                DSP_SlotMuteState[i] = 1;
            EFF_Mute_WithDebug(i);
            muted = 1;
        }
    }
    if (muted == 1)
        DSP_ScheduleDelay(20);
}

void Task3_EnterDspApplyLoop(void)
{
    DSP_State_ApplyTask();
}

extern void BootROM_DEBUG_OUTPUT_STRING(char *);
extern void BootROM_HEX_BYTE_TO_ASCII(int);

void Debug_Print_Byte(unsigned char b)
{
    BootROM_HEX_BYTE_TO_ASCII(b);
    __WA = 0;
}

void Debug_Print_String(char *s)
{
    BootROM_DEBUG_OUTPUT_STRING(s);
    __WA = 0;
}

extern unsigned char DSP_AlgoInit_NoteOnMsg_Algo1[];
extern unsigned char DSP_AlgoInit_NoteOnMsg_Algo2[];
extern unsigned char DSP_AlgoInit_NoteOnMsg_Default[];
extern unsigned int DSP_State_LookupAlgoIndex(unsigned int);
extern unsigned int DSP_SlotMuteState_ReadAndClear(unsigned int);
extern void MIDI_Dispatch(void);
int __cdecl Audio_CmdHandler_00_1F(int n, const unsigned char *p);

void DSP_SlotState_DisplayRestore(void)
{
    unsigned int s;
    s = DSP_SlotMuteState_ReadAndClear(0);
    if (s == 3) {
        Audio_CmdHandler_00_1F(4, (&(DSP_AlgoInit_NoteOnMsg_Algo2)[0]));
        MIDI_Dispatch();
        return;
    }
    if (s == 2) {
        Audio_CmdHandler_00_1F(4, (&(DSP_AlgoInit_NoteOnMsg_Algo1)[0]));
        MIDI_Dispatch();
        return;
    }
    if (s == 1) {
        Audio_CmdHandler_00_1F(4, (&(DSP_AlgoInit_NoteOnMsg_Default)[0]));
        MIDI_Dispatch();
    }
}

void DSP_WriteAlgoInitPreset(unsigned int x)
{
    x = DSP_State_LookupAlgoIndex(x);
    if (x == 2)
        Audio_CmdHandler_00_1F(4, (&(DSP_AlgoInit_NoteOnMsg_Algo2)[0]));
    else if (x == 1)
        Audio_CmdHandler_00_1F(4, (&(DSP_AlgoInit_NoteOnMsg_Algo1)[0]));
    else
        Audio_CmdHandler_00_1F(4, (&(DSP_AlgoInit_NoteOnMsg_Default)[0]));
    MIDI_Dispatch();
}

extern unsigned long __near ram_1040;
extern unsigned char __tiny ram_3c;
extern char Str_DspTrace_Start[], Str_DspTrace_Stop[];
extern void Debug_Print_String(char *);
extern void Kernel_YieldRotate(int);






