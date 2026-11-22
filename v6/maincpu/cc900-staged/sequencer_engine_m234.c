/* Functions of sequencer/sequencer_engine.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: Seq_ValidatePartNumber Seq_ValidateTempoValue */   /* scripts/analysis/cc900/module_calls.py v10 */

extern unsigned char __near SEQ_TRACK;
extern unsigned int __near SEQ_OP_FROM;
extern unsigned int __near SEQ_OP_MEASURES;
extern int Seq_ValidatePartNumber(unsigned int);
extern int Seq_ValidateTempoValue(unsigned int);
extern int SeqValidate_PartAndTempoComb(void);
extern int Seq_ValidateExtended_DataBlock(void);
extern int Seq_ValidatePartAndTempoAlt(void);

/* cc900-name: SeqValidate_PartAndTempoComb=SeqValidate_PartAndTempoCombined */
int SeqValidate_PartAndTempoComb(void)
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

int Seq_ValidateExtended_DataBlock(void)
{
	if (SEQ_TRACK != 0x7f) {
		if (Seq_ValidatePartNumber(SEQ_TRACK) != 0)
			return -1;
	}
	if (Seq_ValidateTempoValue(SEQ_OP_FROM) != 0)
		return -1;
	if (Seq_ValidateTempoValue(SEQ_OP_MEASURES) != 0)
		return -1;
	return 0;
}

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
