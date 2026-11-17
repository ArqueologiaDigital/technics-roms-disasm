/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/sequencer_engine_m236.c (2026-11-16-111-p6-r22-staged)
   sha256 e9b7e34b45d02464e7ed04d2c4c026c93e784e9704c878826315d10f39b5777a (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern unsigned char __near SEQ_ERROR_CODE;
extern unsigned int __near SEQOP_SECONDARY_BLOCK;
extern unsigned int __near SEQOP_SECONDARY_OFFSET;
extern unsigned int __near ram_265c;
extern unsigned int __near ram_265e;
extern unsigned long __near ram_25da;
extern void PartCtrl_WriteByte_ZeroExtended(unsigned int, unsigned int, unsigned int);
extern void PartCtrl_ReadWordWithBoundsCheck(unsigned int *, unsigned int *);
void SeqPart_ReplayForward(void)
{
  unsigned long i;
  SEQ_ERROR_CODE = 0;
  SEQOP_SECONDARY_BLOCK = ram_265c;
  SEQOP_SECONDARY_OFFSET = ram_265e;
  ram_25da = ram_25da - 1;
  i = 0;
  while (ram_25da != i) {
    PartCtrl_WriteByte_ZeroExtended(SEQOP_SECONDARY_BLOCK, SEQOP_SECONDARY_OFFSET, 0x81);
    i++;
    PartCtrl_ReadWordWithBoundsCheck(&SEQOP_SECONDARY_BLOCK, &SEQOP_SECONDARY_OFFSET);
    if (SEQ_ERROR_CODE != 0) return;
  }
  PartCtrl_WriteByte_ZeroExtended(SEQOP_SECONDARY_BLOCK, SEQOP_SECONDARY_OFFSET, 0x82);
}
