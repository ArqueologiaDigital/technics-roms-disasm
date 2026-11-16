/* Functions of core/13_audio_process_dsp_and_effects.s.
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



struct st { int w[0x91]; };



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

































void DSP_WakeAudioTask(void)
{
    Kernel_SemaWait(1);
}













extern void BootROM_DEBUG_OUTPUT_STRING(char *);
extern void BootROM_HEX_BYTE_TO_ASCII(int);





extern unsigned char DSP_AlgoInit_NoteOnMsg_Algo1[];
extern unsigned char DSP_AlgoInit_NoteOnMsg_Algo2[];
extern unsigned char DSP_AlgoInit_NoteOnMsg_Default[];
extern unsigned int DSP_State_LookupAlgoIndex(unsigned int);
extern unsigned int DSP_SlotMuteState_ReadAndClear(unsigned int);
extern void MIDI_Dispatch(void);
int __cdecl Audio_CmdHandler_00_1F(int n, const unsigned char *p);





extern unsigned long __near ram_1040;
extern unsigned char __tiny ram_3c;
extern char Str_DspTrace_Start[], Str_DspTrace_Stop[];
extern void Debug_Print_String(char *);
extern void Kernel_YieldRotate(int);





void DSP_WaitForDelay(unsigned int t)
{
    unsigned long target;

    __XWA = (((unsigned long)t + 1) >> 1) + ram_1040;
    target = __XWA;
    while (ram_1040 < target)
        Kernel_YieldRotate(3);
}
