/* Functions of core/10_dsp_voice_params.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function (notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

struct ring4k { unsigned int w, r, n; unsigned char buf[4096]; };
extern struct ring4k __near MIDI_RingBuffer;
extern unsigned char __tiny ram_44;
extern unsigned int Voice_GlobalFlags;
extern unsigned long ToneDB_RelBase;
extern unsigned long *ToneDB_RootPtr;
extern unsigned char ram_45210[];
extern unsigned char *ram_45318;
extern unsigned char ram_a0000[];
extern unsigned char ram_41342[];
extern unsigned char ram_41368[][287];
extern void WaveSel_StageA1_FindVelSplit(int, int, int, int, int);
extern void DSP_Config_Init(void);
extern void DSP_Reset(void);
extern void Voice_Reset_Engine(int);
extern void DSP_ResetWriteBufferPtr(void);
extern void VoiceSlot_ClearAll(void);
extern void Voice_ResetAllControllers(void);
void DSP_SetCoeff_CopyDirect(unsigned int n);
void DSP_SetCoeff_CopyDirect2(unsigned int n);
void DSP_System_Init(void);
void WaveSel_StageA1_FromToneSlot(unsigned char a, unsigned char *p, unsigned char e, unsigned char s);

/* cc900-module: WaveSel_StageA1_FindVelSplit */
void DSP_SetCoeff_CopyDirect(unsigned int n)
{
    unsigned char *src;
    unsigned int i;
    unsigned int cnt;
    unsigned long off;

    off = ToneDB_RootPtr[32];
    src = (unsigned char *)(ToneDB_RelBase + off);
    cnt = 13;
    for (i = 0; i < cnt; i++)
        ram_45210[i + 6] = src[(unsigned long)n * 16 + i];
}

void DSP_SetCoeff_CopyDirect2(unsigned int n)
{
    unsigned char *src;
    unsigned int i;
    unsigned int cnt;
    unsigned long off;

    off = ToneDB_RootPtr[35];
    src = (unsigned char *)(ToneDB_RelBase + off);
    cnt = 13;
    for (i = 0; i < cnt; i++)
        ram_45210[i + 6] = src[(unsigned long)n * 16 + i];
}

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

void WaveSel_StageA1_FromToneSlot(unsigned char a, unsigned char *p, unsigned char e, unsigned char s)
{
    int x;
    int y;

    x = p[1];
    y = p[2];
    WaveSel_StageA1_FindVelSplit(a, (unsigned char)x, (unsigned char)y, e, s);
}
