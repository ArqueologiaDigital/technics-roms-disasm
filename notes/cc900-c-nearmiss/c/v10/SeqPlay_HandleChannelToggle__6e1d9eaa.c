/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_15m234.c (2026-11-16-107-p6-r21)
   sha256 6e1d9eaaa99c4f6d429820ee84691880395c17d4510629d5a0ad43e43ab5178f (tar-sha256); compiled at -Xr */
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
