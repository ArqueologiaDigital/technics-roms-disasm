/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_20b.c (2026-11-17-16-p6-r31)
   sha256 da15fb2d3ad590bf8711a40ba8747a88ae8018a0fbad8d5c20f7d9a3bf370f65 (tar-sha256); compiled at -O3 -Xr */
extern unsigned char __near SEQ_TRANSPORT_STATE;
extern unsigned int __near SEQ_TRACK_MASK;
extern unsigned int __near SEQ_ACTIVE_PARTS;
extern unsigned char __near DEMO_CONTROL_FLAGS;
extern unsigned char __near ram_28ae;
extern unsigned char __near ram_28a6;
extern unsigned char Part_ReadVoiceByte(unsigned int, unsigned int);
extern void MidiChannel_ResetAndConfigure(void);
extern void SeqBuf_WriteNoteOffEntry(unsigned int);
extern void Chan_SetActiveBit(unsigned int, unsigned int);
extern void VoiceAlloc_ProcessAll(void);
extern void Part_SendVoiceOffAndCCEvents(unsigned int);
extern void Audio_CheckSubsystemReady(void);
extern void SeqBuf_Init(void);
extern void AccWrap_PositionClear(void);
void Part_DeactivateVoiceChannel(unsigned char a)
{
  &a;
  if (Part_ReadVoiceByte(0, a) == 0x0f) {
    ram_28ae &= ~0x80;
    MidiChannel_ResetAndConfigure();
  }
  if (SEQ_TRANSPORT_STATE & 0x04) {
    if (SEQ_TRACK_MASK == 0) {
      SEQ_ACTIVE_PARTS = 0;
      SeqBuf_WriteNoteOffEntry(0x32);
      Chan_SetActiveBit(a, 1);
      VoiceAlloc_ProcessAll();
      SEQ_TRACK_MASK = 0;
      Audio_CheckSubsystemReady();
      Audio_CheckSubsystemReady();
      SeqBuf_Init();
    } else {
      Part_SendVoiceOffAndCCEvents(a);
    }
    goto clear;
  }
  SEQ_ACTIVE_PARTS &= ~(1 << (a - 1));
  if (SEQ_TRACK_MASK == 0) {
    SEQ_ACTIVE_PARTS = 0;
    DEMO_CONTROL_FLAGS &= ~0x80;
    SeqBuf_Init();
clear:
    ram_28a6 &= ~0x01;
    AccWrap_PositionClear();
  }
  Audio_CheckSubsystemReady();
}
