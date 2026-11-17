/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_20c.c (2026-11-17-16-p6-r31)
   sha256 7d3e44df5e3fc9cd5496e97dca74919be33076be617222a25535753dca33ad9e (tar-sha256); compiled at -O3 -Xr */
extern unsigned char __near SEQ_TRANSPORT_STATE;
extern unsigned int __near SEQ_TRACK_MASK;
extern unsigned int __near SEQ_REC_TRACKS;
extern unsigned char __near SEQ_RTMCFG;
extern unsigned char __near SEQ_CYCLE_FLAGS;
extern unsigned char __near CURRENT_TITLE;
extern unsigned int __near SEQ_START_MEASURE;
extern unsigned char __near ram_2524;
extern unsigned int __near ram_2520;
extern unsigned int __near ram_2838;
extern void SeqPlay_FindAndActivateVoice(unsigned int);
extern void Part_DeactivateChannel(unsigned int);
extern void SeqVoice_DeactivateAndReinit(unsigned int);
extern int Part_IsVoiceActive(unsigned int);
extern void SeqVoice_ActivateWithBarSync(unsigned int);
extern void NoteEditSy_SendModeScrollReset(void);
extern void SeqPlay_InitStartState(void);
extern void Accomp_ValidateAutoPlayChordVoice(void);
void SeqPlay_HandleChannelState(unsigned char a)
{
  unsigned int m;
  if (SEQ_TRANSPORT_STATE & 0x04) return;
  ram_2524 = 1;
  m = 1 << (a - 1);
  if (!(m & SEQ_REC_TRACKS)) {
    if (!(m & SEQ_TRACK_MASK)) SeqPlay_FindAndActivateVoice(a);
    else { Part_DeactivateChannel(a); SeqVoice_DeactivateAndReinit(a); }
  } else {
    SeqVoice_DeactivateAndReinit(a);
    if (Part_IsVoiceActive(a)) SeqVoice_ActivateWithBarSync(a);
    else Part_DeactivateChannel(a);
  }
  SEQ_RTMCFG &= ~0x08;
  if (CURRENT_TITLE != 0x87 && CURRENT_TITLE != 0x88) {
    if (!(SEQ_CYCLE_FLAGS & 0x02)) SEQ_START_MEASURE = 1;
    else {
      SEQ_START_MEASURE = ram_2520;
      if (SEQ_START_MEASURE != 1) SEQ_RTMCFG |= 0x08;
    }
  }
  NoteEditSy_SendModeScrollReset();
  SeqPlay_InitStartState();
  Accomp_ValidateAutoPlayChordVoice();
  ram_2838 = SEQ_TRACK_MASK;
}
