/* Phase 6, helper B, round 15, module 234 of v10's sequencer/sequencer_engine.s (-O3 -Xr):
   Seq_ValidatePartTempoAndRange and SeqPlay_HandleChannelToggle, new.  Their callees are module-local (calr).
   Seq_ValidatePartNumber's caller widens the char argument (extz), so it is declared without a prototype. */
/* cc900-module: Accomp_ValidateAutoPlayChordVoice Part_DeactivateChannel Part_IsVoiceActive SeqPlay_DeactivateChannelFull SeqPlay_HandleChannelSolo SeqPlay_InitStartState SeqVoice_ActivateWithBarSync Seq_ValidatePartNumber Seq_ValidateTempoValue */

extern unsigned char __near SEQ_TRACK;
extern unsigned int __near SEQ_OP_FROM;
extern unsigned int __near SEQ_OP_MEASURES;
extern unsigned char __near ram_2616;
extern unsigned char __near ram_2658;
extern int Seq_ValidatePartNumber();
extern int Seq_ValidateTempoValue(unsigned int);

/* 0 when the part (17 = all), the from / measures values (1..999) and the two note bytes (<= 127) are valid */
int Seq_ValidatePartTempoAndRange(void)
{
  if (SEQ_TRACK != 0x11 && Seq_ValidatePartNumber(SEQ_TRACK) != 0) return -1;
  if (Seq_ValidateTempoValue(SEQ_OP_FROM) != 0) return -1;
  if (Seq_ValidateTempoValue(SEQ_OP_MEASURES) != 0) return -1;
  if (ram_2616 > 127 || ram_2658 > 127) return -1;
  return 0;
}

extern unsigned int __near SEQ_TRACK_MASK;
extern unsigned char __near SEQ_TRANSPORT_STATE;
extern unsigned int __near ram_2838;
extern void SeqPlay_DeactivateChannelFull(unsigned int);
extern int Part_IsVoiceActive(unsigned int);
extern void SeqPlay_HandleChannelSolo(unsigned int);
extern void Part_DeactivateChannel(unsigned int);
extern void SeqVoice_ActivateWithBarSync(unsigned int);
extern void SeqPlay_InitStartState(void);
extern void Accomp_ValidateAutoPlayChordVoice(void);

/* MUTE-style toggle of track a: an active track is switched off, an inactive one with data is switched on (solo
   while the sequencer runs, with a bar-synchronised start otherwise). */
void SeqPlay_HandleChannelToggle(unsigned char a)
{
  unsigned int m = (1 << (a - 1)) & SEQ_TRACK_MASK;
  if (SEQ_TRANSPORT_STATE & 0x04) {
    if (m != 0) SeqPlay_DeactivateChannelFull(a);
    else if (Part_IsVoiceActive(a) != 0) SeqPlay_HandleChannelSolo(a);
  } else {
    if (m != 0) { Part_DeactivateChannel(a); SeqPlay_InitStartState(); }
    else if (Part_IsVoiceActive(a) != 0) { SeqVoice_ActivateWithBarSync(a); SeqPlay_InitStartState(); }
  }
  Accomp_ValidateAutoPlayChordVoice();
  ram_2838 = SEQ_TRACK_MASK;
}
