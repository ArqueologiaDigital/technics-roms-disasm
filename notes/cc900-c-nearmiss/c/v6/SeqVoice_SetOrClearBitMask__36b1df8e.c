/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/sequencer_engine_m234.c (2026-11-21-5-p6-r60)
   sha256 36b1df8ea4c92bbccf5cdcf5dc069fff0bb7a9bd7aca4727843cf7a201c64896 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern unsigned int __near SEQ_REC_TRACKS;
extern void Audio_CheckSubsystemReady(void);
void SeqVoice_SetOrClearBitMask(unsigned char part, unsigned char on)
{
  int m;
  part--;
  m = 1 << part;
  if (on != 0)
    SEQ_REC_TRACKS |= m;
  else
    SEQ_REC_TRACKS &= ~m;
  Audio_CheckSubsystemReady();
}
