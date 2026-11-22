/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/sequencer_engine_m234.c (2026-11-21-5-p6-r60)
   sha256 36b1df8ea4c92bbccf5cdcf5dc069fff0bb7a9bd7aca4727843cf7a201c64896 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern void PartCtrl_WriteByteToBuf(unsigned int, unsigned int, unsigned int);
extern unsigned int __near SEQOP_SECONDARY_OFFSET;
extern unsigned int __near SEQOP_SECONDARY_BLOCK;
void SeqPart_WriteByte_Secondary(unsigned char v)
{
  PartCtrl_WriteByteToBuf(SEQOP_SECONDARY_BLOCK, (unsigned char)SEQOP_SECONDARY_OFFSET, v);
}
