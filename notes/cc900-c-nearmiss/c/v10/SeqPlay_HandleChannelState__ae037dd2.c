/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_21c.c (2026-11-18-1-p6-r33)
   sha256 ae037dd2d8f5c0252176e54e2510e03e43d75db452c4d53f45c42f3399663c27 (tar-sha256); compiled at -O3 -Xr */
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
  unsigned int m, r;
  unsigned char t;
  if (SEQ_TRANSPORT_STATE & 0x04) return;
  ram_2524 = 1;
  m = 1 << (a - 1);
  r = m & SEQ_REC_TRACKS;
  if (r == 0) {
    if ((m & SEQ_TRACK_MASK) == 0) SeqPlay_FindAndActivateVoice(a);
    else { Part_DeactivateChannel(a); SeqVoice_DeactivateAndReinit(a); }
  } else {
    SeqVoice_DeactivateAndReinit(a);
    if (Part_IsVoiceActive(a) != 0) SeqVoice_ActivateWithBarSync(a);
    else Part_DeactivateChannel(a);
  }
  SEQ_RTMCFG &= ~0x08;
  t = CURRENT_TITLE;
  if (t != 0x87 && t != 0x88) {
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
