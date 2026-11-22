/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_R_20r1m234b.c (2026-11-21-3-p6-r59)
   sha256 bafb1ec50e4615f1aca50e01fb26d5f26fea7966125f481d24e4a421768ec32c (tar-sha256); compiled at -Xr */
extern unsigned int __near SEQOP_PRIMARY_OFFSET;
extern unsigned int __near SEQOP_PRIMARY_BLOCK;
extern void PartCtrl_WriteByteToBuf(unsigned int, unsigned int, unsigned int);
void SeqPart_WriteByte_Primary(unsigned char v)
{
  unsigned int o;
  unsigned char c;
  o = SEQOP_PRIMARY_OFFSET;
  c = o;
  PartCtrl_WriteByteToBuf(SEQOP_PRIMARY_BLOCK, c, v);
}
