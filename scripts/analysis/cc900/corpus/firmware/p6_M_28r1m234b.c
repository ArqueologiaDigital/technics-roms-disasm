/* lane_p6 helper M, round 28r1, form b: module 234 (sequencer/sequencer_engine.s), the family
   SeqValidate_PartAndTempoCombined / Seq_ValidatePartAndTempoAlt (track 0x11 = all) and
   Seq_ValidateExtended_DataBlock (track 0x7f): unless the track is "all", validate it, then validate
   SEQ_OP_FROM and SEQ_OP_MEASURES as tempo / bar values; -1 on the first failure, else 0.  Form b: the checks joined with && and ||.
   cc900-options: -O3 -Xr
*/
/* cc900-module: Seq_ValidatePartNumber Seq_ValidateTempoValue */
/* cc900-name: SeqValidate_PartAndTempoComb=SeqValidate_PartAndTempoCombined */

extern unsigned char __near SEQ_TRACK;
extern unsigned int __near SEQ_OP_FROM;
extern unsigned int __near SEQ_OP_MEASURES;
extern int Seq_ValidatePartNumber(unsigned int);
extern int Seq_ValidateTempoValue(unsigned int);

int SeqValidate_PartAndTempoComb(void)
{
	if (SEQ_TRACK != 0x11 && Seq_ValidatePartNumber(SEQ_TRACK) != 0)
		return -1;
	if (Seq_ValidateTempoValue(SEQ_OP_FROM) != 0 || Seq_ValidateTempoValue(SEQ_OP_MEASURES) != 0)
		return -1;
	return 0;
}

int Seq_ValidatePartAndTempoAlt(void)
{
	if (SEQ_TRACK != 0x11 && Seq_ValidatePartNumber(SEQ_TRACK) != 0)
		return -1;
	if (Seq_ValidateTempoValue(SEQ_OP_FROM) != 0 || Seq_ValidateTempoValue(SEQ_OP_MEASURES) != 0)
		return -1;
	return 0;
}

int Seq_ValidateExtended_DataBlock(void)
{
	if (SEQ_TRACK != 0x7f && Seq_ValidatePartNumber(SEQ_TRACK) != 0)
		return -1;
	if (Seq_ValidateTempoValue(SEQ_OP_FROM) != 0 || Seq_ValidateTempoValue(SEQ_OP_MEASURES) != 0)
		return -1;
	return 0;
}
