/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/system_handlers_m1_xr.c (2026-11-16-68-p6-r12)
   sha256 6de73bd671a4a2c6064844c17d5d1d52f31e71abc7a8b369999c429fb52670b4 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -Xr */
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
