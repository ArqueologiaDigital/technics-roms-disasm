/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_Q_20r1m234a.c (2026-11-21-2-p6-r58)
   sha256 df94398bf3afc486701c7f2a11ee90af1cc642366c4c2c6827b6c8c376a9491c (tar-sha256); compiled at -O3 -XS -Xr */
extern unsigned char __near CURRENT_TITLE;
extern unsigned char __near ram_28a5;
extern unsigned int __near SEQ_TRACK_MASK;
extern unsigned int SEQ_TRACK_MASK_COPY;
extern void Audio_CheckSubsystemReady(void);
extern void CtrlPanel_SetIndicatorBit(unsigned int);
void Accomp_UpdateModeFlag(void)
{
  if (CURRENT_TITLE == 129 || SEQ_TRACK_MASK != 0)
    ram_28a5 |= 0x01;
  else
    ram_28a5 &= ~0x01;
  SEQ_TRACK_MASK = SEQ_TRACK_MASK_COPY;
  Audio_CheckSubsystemReady();
  CtrlPanel_SetIndicatorBit(0x4c);
}
