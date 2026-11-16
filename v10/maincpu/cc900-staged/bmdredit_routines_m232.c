/* Functions of sequencer/bmdredit_routines.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/

extern unsigned char SeqData_ReadNextByte(void);
extern unsigned int PartCtrl_ReadWord_Off1(unsigned int);
extern unsigned char __near SEQ_ERROR_CODE;
extern unsigned int __near SEQ_DATA_OFFSET;
extern unsigned int __near SEQ_DATA_BLOCK;
extern void SeqData_SetErrorCode(unsigned int);
extern unsigned int PartCtrl_ReadWord(unsigned int);
extern unsigned int __near ram_2772;
extern void SeqData_SkipToNextEvent(void);

void BmDrEdit_ClearAndScanToEnd(void)
{
	unsigned int o, b;

	SEQ_ERROR_CODE = 0;
	do {
		o = SEQ_DATA_OFFSET;
		if (o > 5) {
			SEQ_DATA_OFFSET = o - 1;
		} else {
			b = PartCtrl_ReadWord_Off1(SEQ_DATA_BLOCK);
			if (b == 0) {
				SEQ_ERROR_CODE = 255;
				return;
			}
			SEQ_DATA_BLOCK = b;
			SEQ_DATA_OFFSET = 255;
		}
	} while (!(SeqData_ReadNextByte() & 0x80));
}

/* cc900-name: BmDrEdit_DecrValidateCounter=BmDrEdit_DecrementAndValidateCounter (36 characters) */
int BmDrEdit_DecrValidateCounter(unsigned int *blk, unsigned int *off)
{
	(*off)--;
	if (*off >= 5) return 0;
	*blk = PartCtrl_ReadWord_Off1(*blk);
	if (*blk > 0x4d8) {
		SeqData_SetErrorCode(0xa0);
		return -1;
	}
	*off = 0xff;
	return 0;
}

/* cc900-name: PartCtrl_ReadWordWithBoundsChk=PartCtrl_ReadWordWithBoundsCheck (32 characters) */
int PartCtrl_ReadWordWithBoundsChk(unsigned int *blk, unsigned int *off)
{
	(*off)++;
	if (*off <= 0xff) return 0;
	*blk = PartCtrl_ReadWord(*blk);
	if (*blk > 0x4d8) {
		SeqData_SetErrorCode(0xa1);
		return -1;
	}
	*off = 5;
	return 0;
}

void BmDrEdit_CountMeasuresAndValidate(void)
{
	unsigned char c;

	if (SEQ_ERROR_CODE != 0) SeqData_SetErrorCode(0xd1);
	ram_2772 = 0;
	for (;;) {
		c = SeqData_ReadNextByte();
		if (c == 0x82 || c == 0x84) break;
		if (c == 0x81) ram_2772++;
		SeqData_SkipToNextEvent();
	}
	if (SEQ_ERROR_CODE != 0) SeqData_SetErrorCode(0xce);
}
