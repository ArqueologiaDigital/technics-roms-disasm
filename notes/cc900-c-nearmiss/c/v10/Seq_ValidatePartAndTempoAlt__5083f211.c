/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_M_28r1m234a.c (2026-11-22-9-p6-r76)
   sha256 5083f211f7922f9a1b7f87da71ef86f57140bf0ed36197a3351c95473d47c2c9 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern unsigned char __near SEQ_TRACK;
extern unsigned int __near SEQ_OP_FROM;
extern unsigned int __near SEQ_OP_MEASURES;
extern int Seq_ValidatePartNumber(unsigned int);
extern int Seq_ValidateTempoValue(unsigned int);
int Seq_ValidatePartAndTempoAlt(void)
{
	if (SEQ_TRACK != 0x11) {
		if (Seq_ValidatePartNumber(SEQ_TRACK) != 0)
			return -1;
	}
	if (Seq_ValidateTempoValue(SEQ_OP_FROM) != 0)
		return -1;
	if (Seq_ValidateTempoValue(SEQ_OP_MEASURES) != 0)
		return -1;
	return 0;
}
