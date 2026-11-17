/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/sequencer_engine_m236.c (2026-11-16-111-p6-r22-staged)
   sha256 960d6437529a17d34c6b3d67bbabed763976045904e169102aa5e74cd6437bba (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern unsigned char __near SEQ_ERROR_CODE;
extern unsigned int __near SEQOP_SECONDARY_BLOCK;
extern unsigned int __near SEQOP_SECONDARY_OFFSET;
extern unsigned int __near ram_2642;
extern unsigned int __near ram_2644;
extern unsigned long __near ram_25c0;
extern void PartCtrl_WriteByte_ZeroExtended(unsigned int, unsigned int, unsigned int);
extern void PartCtrl_ReadWordWithBoundsCheck(unsigned int *, unsigned int *);
void SeqPart_ReplayForward(void)
{
  unsigned long i;
  SEQ_ERROR_CODE = 0;
  SEQOP_SECONDARY_BLOCK = ram_2642;
  SEQOP_SECONDARY_OFFSET = ram_2644;
  ram_25c0 = ram_25c0 - 1;
  i = 0;
  while (ram_25c0 != i) {
    PartCtrl_WriteByte_ZeroExtended(SEQOP_SECONDARY_BLOCK, SEQOP_SECONDARY_OFFSET, 0x81);
    i++;
    PartCtrl_ReadWordWithBoundsCheck(&SEQOP_SECONDARY_BLOCK, &SEQOP_SECONDARY_OFFSET);
    if (SEQ_ERROR_CODE != 0) return;
  }
  PartCtrl_WriteByte_ZeroExtended(SEQOP_SECONDARY_BLOCK, SEQOP_SECONDARY_OFFSET, 0x82);
}
