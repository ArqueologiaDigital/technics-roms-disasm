/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/sequencer_engine_m234.c (2026-11-19-43-p6-r48)
   sha256 4ffdac3458cf888466dbfa38db993c05028061446aa9030585e38e9f11d04b53 (tar-sha256); compiled at -Xr
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
