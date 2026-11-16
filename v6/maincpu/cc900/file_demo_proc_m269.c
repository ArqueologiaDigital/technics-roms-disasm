/* Functions of demo/file_demo_proc.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/

extern unsigned char __near SEQ_RTMCFG;
extern void SeqBuf_Init(void);
extern void NoteMap_SendAllNotesOff(void);
extern void Part_ReinitAllActive(void);
extern void AccWrap_PlayModeDispatch(void);
extern void AccompSeq_StopSequence(void);
extern void AudioInit_RefreshToneBank(void);
extern void NoteMap_ProcessAndMerge(void);
extern void Voice_InitializeAll(void);
extern void Voice_InitTablePair(void);
extern void Voice_InitTableGroup(void);
extern void MIDI_SendAllSoundOff(void);
extern void MidiIn_IgnoreClockTransport(void);

void InitializeOperationState(unsigned char a)
{
    SeqBuf_Init();
    NoteMap_SendAllNotesOff();
    Part_ReinitAllActive();
    AccWrap_PlayModeDispatch();
    if (a != 0) SEQ_RTMCFG |= 4;
    AccompSeq_StopSequence();
    AudioInit_RefreshToneBank();
    NoteMap_ProcessAndMerge();
    Voice_InitializeAll();
    Voice_InitTablePair();
    Voice_InitTableGroup();
    MIDI_SendAllSoundOff();
    MidiIn_IgnoreClockTransport();
}
