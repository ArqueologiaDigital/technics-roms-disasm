/* Functions of core/13_audio_process_dsp_and_effects.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function at -Xr (notes/cc900-c-subcpu-2026-11-16/);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   cc900-options: -Xr */
unsigned int Unsigned_Max_Select(unsigned int a, unsigned int b)
{
    if (b > a) a = b;
    return a;
}

struct st { int w[0x91]; };

void DSP_StateTable_Reset(struct st *p) { *(struct st *)0x45ca = *p; }

struct slot { unsigned int type; int f2; int param[25]; int on; };
struct cfg { unsigned int f0, f2, f4, f6; struct slot s[5]; };
struct e50 { unsigned int f0; char pad[48]; };
struct cfgimg { int w[0x91]; };
extern struct cfg __near ram_448e;
extern struct slot __near ram_45d2[];
extern unsigned int __near ram_45d0;
extern unsigned int __near ram_45bc[];
extern unsigned int __near ram_4504;
extern unsigned int __near ram_453c;
extern unsigned int __near ram_4574;
extern unsigned int __near ram_45ac;
extern unsigned int __near ram_45b2;
extern unsigned int __near ram_45b4;
extern unsigned int __near ram_45b6;
extern unsigned int __near ram_4930[];
extern unsigned int __near ram_493a[];
extern unsigned int __near ram_493e;
extern struct e50 __near ram_4940[];
extern int ram_4551a;
extern int ram_453f8;
extern unsigned char DSP_EffectClass_Table[];

void DSP_AlgoChange_CheckAndFlag(struct cfg *p)
{
    if (p->f6 != ram_45d0 || p->f2 == 1 || p->f4 == 1)
        ram_493e = 1;
    else
        ram_493e = 0;
}

void DSP_AlgorithmChangeCheck(void)
{
    if (ram_493e == 1)
        DSP_AlgorithmChange();
}

int DSP_Config_DeadTail_SumWords(void)
{
    return ram_4551a + ram_453f8;
}

struct cfg *DSP_GetConfigBuffer(void)
{
    return &ram_448e;
}

void DSP_MuteLoop(void)
{
    unsigned int i;

    for (i = 0; i < 2; i++)
        if (ram_493a[i] == 1)
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
    ram_448e.f0 = 0;
    ram_453c = v;
    DSP_State_ApplyBuf(&ram_448e);
}

void DSP_Set_DigitalReverbOnOff(unsigned char v)
{
    ram_448e.f0 = 0;
    ram_4504 = v;
    DSP_State_ApplyBuf(&ram_448e);
}

void DSP_Set_EqualizerOnOff(unsigned char v)
{
    ram_448e.f0 = 0;
    ram_45ac = v;
    DSP_State_ApplyBuf(&ram_448e);
}

int DSP_Set_FadeLevel(unsigned char v)
{
    ram_45b6 = v;
    return DSP_MixerCoeff_Compute(ram_45b2, ram_45b4, ram_45b6);
    return ram_45b6;
}

void DSP_Set_MicReverbOnOff(unsigned char v)
{
    ram_448e.f0 = 0;
    ram_4574 = v;
    DSP_State_ApplyBuf(&ram_448e);
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

    r = ram_45bc[i];
    ram_45bc[i] = 0;
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
        if (ram_493a[i] == 1)
            DSP_Unmute_WithDebug(i);
}

void DSP_WakeAudioTask(void)
{
    Kernel_SemaWait(1);
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

    if (ram_493e == 1) {
        ram_493a[0] = 1;
        for (i = 1; i < 2; i++)
            ram_493a[i] = 0;
    } else {
        for (i = 0; i < 2; i++)
            ram_493a[i] = 0;
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
        if (ram_4930[i] == 1) {
            if (ram_4940[i].f0 == 1 && DSP_EffectClass_Table[ram_45d2[i].type] != 0)
                ram_45bc[i] = 1;
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
