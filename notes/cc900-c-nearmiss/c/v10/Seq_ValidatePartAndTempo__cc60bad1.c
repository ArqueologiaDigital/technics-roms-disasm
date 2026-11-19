/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_N_5m234a.c (2026-11-19-37-p6-r47)
   sha256 cc60bad19ae10448167216037fc218caf5a95e41a3bcf8f414c2d43efdc802c8 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern unsigned char __near SEQ_TRACK;
extern unsigned char __near SEQ_OP_DEST_TRACK;
extern unsigned int __near SEQ_OP_FROM;
extern unsigned int __near SEQ_OP_MEASURES;
extern unsigned int __near SEQ_OP_DEST_MEASURE;
extern int Seq_ValidatePartNumber(unsigned int);
extern int Seq_ValidateTempoValue(unsigned int);
int Seq_ValidatePartAndTempo(void)
{
	if (SEQ_TRACK != 0x7f) {
		if (Seq_ValidatePartNumber(SEQ_TRACK) != 0)
			return -1;
		if (Seq_ValidatePartNumber(SEQ_OP_DEST_TRACK) != 0)
			return -1;
	}
	if (Seq_ValidateTempoValue(SEQ_OP_FROM) != 0)
		return -1;
	if (Seq_ValidateTempoValue(SEQ_OP_MEASURES) != 0)
		return -1;
	if (Seq_ValidateTempoValue(SEQ_OP_DEST_MEASURE) != 0)
		return -1;
	return 0;
}
