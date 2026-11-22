/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_Q_20r1m234a.c (2026-11-21-2-p6-r58)
   sha256 df94398bf3afc486701c7f2a11ee90af1cc642366c4c2c6827b6c8c376a9491c (tar-sha256); compiled at -Xr */
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
