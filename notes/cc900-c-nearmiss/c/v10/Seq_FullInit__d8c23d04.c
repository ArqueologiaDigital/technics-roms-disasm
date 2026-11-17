/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_6b.c (2026-11-16-45-p6-r9)
   sha256 d8c23d04522aec171aa28df55c10e94ff12aceb37e57c0c9258fc07955f44d2f (tar-sha256); compiled at -O3 -Xr */
extern unsigned char __near ram_413;
extern unsigned char __near ram_422;
extern unsigned char __near ram_473;
extern unsigned char __near ram_bf39;
extern void AudioMix_Init(void);
extern void SeqBuf_Init(void);
extern void TempoRingBuf_Init(void);
extern void SeqMain_InitBuffer(void);
extern void RhythmBuf_Init(void);
extern void SeqBuf_MidiOut_Init(void);
extern void SeqEvtBuf_Init(void);
extern void SeqBuf2_Init(void);
extern void AltEvtBuf_Init(void);
extern void SeqBuf_NoteEvent_Flush(void);
extern void SeqBuf_VoiceMap_Flush(void);
extern void SeqBuf_NoteEvent_InitBuffer(void);
extern void SeqBuf_SoundEdit_Flush(void);
extern void SeqBuf3_Init(void);
extern void SeqBuf_DspSysEx_InitBuffer(void);
void Seq_FullInit(void)
{
    unsigned char f = 0xff;
    ram_413 = f;
    ram_422 = f;
    ram_473 = f;
    AudioMix_Init();
    SeqBuf_Init();
    TempoRingBuf_Init();
    SeqMain_InitBuffer();
    RhythmBuf_Init();
    SeqBuf_MidiOut_Init();
    SeqEvtBuf_Init();
    SeqBuf2_Init();
    AltEvtBuf_Init();
    SeqBuf_NoteEvent_Flush();
    SeqBuf_VoiceMap_Flush();
    SeqBuf_NoteEvent_InitBuffer();
    SeqBuf_SoundEdit_Flush();
    SeqBuf3_Init();
    SeqBuf_DspSysEx_InitBuffer();
    ram_bf39 = 255;
}
