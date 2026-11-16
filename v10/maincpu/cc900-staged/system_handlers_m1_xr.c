/* Functions of boot/system_handlers.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

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
