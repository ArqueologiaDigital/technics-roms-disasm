/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/system_handlers_xr.c (2026-11-16-55-p6-r10)
   sha256 160be0488bf9197d413edfeece0ef97f95227c20a2d17f3b4d429be143f7131d (tar-sha256); compiled at -O3 -Xr
   cc900-options: -Xr */
extern unsigned char __near ram_413;
extern unsigned char __near ram_422;
extern unsigned char __near ram_473;
extern unsigned char __near ram_bf39;
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
