/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_M_28r1m234b.c (2026-11-22-9-p6-r76)
   sha256 bd164279982ea2a6478c1d7cfc754a2dfb1bb2b8f39a97e703e2747411b9e80b (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern unsigned char __near SEQ_TRACK;
extern unsigned int __near SEQ_OP_FROM;
extern unsigned int __near SEQ_OP_MEASURES;
extern int Seq_ValidatePartNumber(unsigned int);
extern int Seq_ValidateTempoValue(unsigned int);
int Seq_ValidateExtended_DataBlock(void)
{
	if (SEQ_TRACK != 0x7f && Seq_ValidatePartNumber(SEQ_TRACK) != 0)
		return -1;
	if (Seq_ValidateTempoValue(SEQ_OP_FROM) != 0 || Seq_ValidateTempoValue(SEQ_OP_MEASURES) != 0)
		return -1;
	return 0;
}
