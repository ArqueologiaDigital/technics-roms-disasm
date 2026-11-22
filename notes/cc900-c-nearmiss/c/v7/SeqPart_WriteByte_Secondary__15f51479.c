/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/sequencer_engine_m234.c (2026-11-21-5-p6-r60)
   sha256 15f514792784218d6324aaffa1819a5100483d5fb93a728abd903425e8bfa977 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern void PartCtrl_WriteByteToBuf(unsigned int, unsigned int, unsigned int);
extern unsigned int __near SEQOP_SECONDARY_OFFSET;
extern unsigned int __near SEQOP_SECONDARY_BLOCK;
void SeqPart_WriteByte_Secondary(unsigned char v)
{
  PartCtrl_WriteByteToBuf(SEQOP_SECONDARY_BLOCK, (unsigned char)SEQOP_SECONDARY_OFFSET, v);
}
