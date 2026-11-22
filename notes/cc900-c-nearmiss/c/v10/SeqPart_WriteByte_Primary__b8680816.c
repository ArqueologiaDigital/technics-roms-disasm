/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_R_20r1m234a.c (2026-11-21-3-p6-r59)
   sha256 b86808166a06d60625b10f675d0d7cd1a33d597b82e5099a43dcbbaebf33208e (tar-sha256); compiled at -Xr */
extern unsigned int __near SEQOP_PRIMARY_OFFSET;
extern unsigned int __near SEQOP_PRIMARY_BLOCK;
extern void PartCtrl_WriteByteToBuf(unsigned int, unsigned int, unsigned int);
void SeqPart_WriteByte_Primary(unsigned char v)
{
  PartCtrl_WriteByteToBuf(SEQOP_PRIMARY_BLOCK, (unsigned char)SEQOP_PRIMARY_OFFSET, v);
}
