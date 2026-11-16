/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_15m234.c (2026-11-16-107-p6-r21)
   sha256 6e1d9eaaa99c4f6d429820ee84691880395c17d4510629d5a0ad43e43ab5178f (tar-sha256); compiled at -Xr */
extern unsigned char __near SEQ_TRACK;
extern unsigned int __near SEQ_OP_FROM;
extern unsigned int __near SEQ_OP_MEASURES;
extern unsigned char __near ram_2616;
extern unsigned char __near ram_2658;
extern int Seq_ValidatePartNumber();
extern int Seq_ValidateTempoValue(unsigned int);
int Seq_ValidatePartTempoAndRange(void)
{
  if (SEQ_TRACK != 0x11 && Seq_ValidatePartNumber(SEQ_TRACK) != 0) return -1;
  if (Seq_ValidateTempoValue(SEQ_OP_FROM) != 0) return -1;
  if (Seq_ValidateTempoValue(SEQ_OP_MEASURES) != 0) return -1;
  if (ram_2616 > 127 || ram_2658 > 127) return -1;
  return 0;
}
