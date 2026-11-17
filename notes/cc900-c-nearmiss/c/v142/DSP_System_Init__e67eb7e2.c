/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_D_9c.c (2026-11-16-86-sub-r9)
   sha256 e67eb7e2c0c66eb6b52a53b2f206995f13036598ffdb92b26d1921ab65cda84b (name+funcs); compiled at -O1 -Xr */
struct ring4k { unsigned int w, r, n; unsigned char buf[4096]; };
extern struct ring4k __near MIDI_RingBuffer;
extern unsigned char __tiny ram_44;
extern unsigned int Voice_GlobalFlags;
extern unsigned long ToneDB_RelBase;
extern unsigned long *ToneDB_RootPtr;
extern unsigned char *ram_45318;
extern unsigned char ram_a0000[];
extern unsigned char ram_41342[];
extern unsigned char ram_41368[][287];
extern void DSP_Config_Init(void);
extern void DSP_Reset(void);
extern void Voice_Reset_Engine(int);
extern void DSP_ResetWriteBufferPtr(void);
extern void VoiceSlot_ClearAll(void);
extern void Voice_ResetAllControllers(void);
void DSP_System_Init(void)
{
    unsigned int i;
    unsigned char *q;

    for (i = 0, q = ram_41342; i < 0x26; i++)
        *q++ = 0;
    for (i = 0, q = ram_41368[0]; i < 0x1d26; i++)
        *q++ = 0;
    MIDI_RingBuffer.w = MIDI_RingBuffer.r = MIDI_RingBuffer.n = 0;
    if (ram_44 & 8)
        Voice_GlobalFlags &= ~8;
    else
        Voice_GlobalFlags |= 8;
    ToneDB_RelBase = 0x50000;
    ToneDB_RootPtr = (unsigned long *)0x50000;
    ram_45318 = ram_a0000;
    DSP_Config_Init();
    DSP_Reset();
    Voice_Reset_Engine(0);
    DSP_ResetWriteBufferPtr();
    VoiceSlot_ClearAll();
    ram_41342[0] = 0;
    Voice_ResetAllControllers();
}
