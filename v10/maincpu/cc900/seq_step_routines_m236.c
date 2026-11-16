/* Functions of sequencer/seq_step_routines.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/

extern void PartCtrl_AdvanceReadPos(void);
extern unsigned char SeqPart_ReadByte_Secondary(void);
extern unsigned char __near SEQ_ERROR_CODE;
extern unsigned int PartCtrl_ReadWord_Off1(unsigned int);
extern unsigned int __near SQSTEP_SCAN_OFFSET;
extern unsigned int __near SQSTEP_SCAN_BLOCK;

int SeqStep_SkipThreeEvents(void)
{
	PartCtrl_AdvanceReadPos();
	if (SEQ_ERROR_CODE != 0) goto err;
	PartCtrl_AdvanceReadPos();
	if (SEQ_ERROR_CODE != 0) goto err;
	PartCtrl_AdvanceReadPos();
	if (SEQ_ERROR_CODE != 0) goto err;
	if (SeqPart_ReadByte_Secondary() == 0) goto ok;
err:
	return -1;
ok:
	return 0;
}

int SeqStep_WalkReadNext(void)
{
	unsigned int o, b;

	o = SQSTEP_SCAN_OFFSET;
	if (o == 5) {
		b = PartCtrl_ReadWord_Off1(SQSTEP_SCAN_BLOCK);
		if (b == 0) return -1;
		SQSTEP_SCAN_BLOCK = b;
		SQSTEP_SCAN_OFFSET = 255;
	} else {
		SQSTEP_SCAN_OFFSET = o + 1;
	}
	return 0;
}
